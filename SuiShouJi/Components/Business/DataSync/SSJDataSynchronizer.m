//
//  SSJDataSynchronizer.m
//  SuiShouJi
//
//  Created by old lang on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDataSynchronizer.h"
#import "SSJUserBillSyncTable.h"
#import "SSJFundInfoSyncTable.h"
#import "SSJUserChargeSyncTable.h"
#import "SSJFundAccountTable.h"
#import "SSJDailySumChargeTable.h"
#import "SSJDatabaseQueue.h"
#import "SSZipArchive.h"
#import "AFNetworking.h"

#import <ZipZap/ZipZap.h>

//  同步文件名称
static NSString *const kSyncFileName = @"sync_data.json";

//  压缩文件名称
static NSString *const kSyncZipFileName = @"sync_data.zip";

//  加密密钥字符串
static NSString *const kSignKey = @"accountbook";

static const void * kSSJDataSynchronizerSpecificKey = &kSSJDataSynchronizerSpecificKey;

@interface SSJDataSynchronizer ()

@property (nonatomic, weak) NSURLSessionDataTask *task;
@property (nonatomic, strong) dispatch_queue_t syncQueue;

@end

@implementation SSJDataSynchronizer

+ (instancetype)shareInstance {
    static SSJDataSynchronizer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[SSJDataSynchronizer alloc] init];
        }
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.syncQueue = dispatch_queue_create("com.ShuiShouJi.SSJDataSync", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(self.syncQueue, kSSJDataSynchronizerSpecificKey, (__bridge void *)self, NULL);
    }
    return self;
}

- (void)startSyncWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    if (self.task == nil) {
        lastSyncVersion = SSJ_INVALID_SYNC_VERSION;
        
        SSJDataSynchronizer *currentSynchronizer = (__bridge id)dispatch_get_specific(kSSJDataSynchronizerSpecificKey);
        if (currentSynchronizer == self) {
            [self syncDataWithSuccess:success failure:failure];
        } else {
            dispatch_async(self.syncQueue, ^{
                [self syncDataWithSuccess:success failure:failure];
            });
        }
    }
}

- (void)syncDataWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    __block int64_t currentSyncVersion;
    
    __block NSArray *userChargeRecords = nil;
    __block NSArray *fundInfoRecords = nil;
    __block NSArray *userBillRecords = nil;
    
    __block BOOL databaseSuccess = YES;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        
        //  获取上次同步成功的版本号
        [SSJSyncTable lastSuccessSyncVersionInDatabase:db];
        if (lastSyncVersion == SSJ_INVALID_SYNC_VERSION) {
            lastSyncVersion = SSJDefaultSyncVersion;
        }
        
        //  设置当前同步的版本号
        currentSyncVersion = lastSyncVersion + 1;
        
        //  把当前同步的版本号插入到BK_SYNC表中
        if (![db executeUpdate:@"insert into BK_SYNC (VERSION, TYPE, CUSERID) values (?, 1, ?)", @(currentSyncVersion), SSJUSERID()]) {
            SSJPRINT(@">>>SSJ warning\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
            databaseSuccess = NO;
            return;
        }
        
        SSJUpdateSyncVersion(currentSyncVersion + 1);
        
        //  查询需要同步的表中 版本号（IVERSION）大于上次同步成功版本号（lastSyncVersion）的记录，
        userBillRecords = [SSJUserBillSyncTable queryRecordsForSyncInDatabase:db];
        fundInfoRecords = [SSJFundInfoSyncTable queryRecordsForSyncInDatabase:db];
        userChargeRecords = [SSJUserChargeSyncTable queryRecordsForSyncInDatabase:db];
    }];
    
    if (!databaseSuccess) {
        failure(nil);
        return;
    }
    
    NSArray *userRecords = @[@{@"cuserid":SSJUSERID(),
                               @"imei":[UIDevice currentDevice].identifierForVendor.UUIDString,
                               @"source":SSJDefaultSource()}];
    
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    if (userBillRecords.count) {
        [jsonObject setObject:userBillRecords forKey:@"bk_user_bill"];
    }
    if (fundInfoRecords.count) {
        [jsonObject setObject:fundInfoRecords forKey:@"bk_fund_info"];
    }
    if (userChargeRecords.count) {
        [jsonObject setObject:userChargeRecords forKey:@"bk_user_charge"];
    }
    if (userRecords.count) {
        [jsonObject setObject:userRecords forKey:@"bk_user"];
    }
    
    //  将查询得到的结果放入字典中，转换成json数据
    NSError *error = nil;
    NSData *syncData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (error) {
        SSJPRINT(@">>>SSJ warning\n error:%@", error);
        failure(error);
        return;
    }
    
    //  读取压缩好的文件，上传到服务端
    NSData *zipData = [self zipData:syncData error:&error];
    
    if (error) {
        SSJPRINT(@">>>SSJ warning\n error:%@", error);
        failure(error);
        return;
    }
    
    //  创建请求
    NSString *urlString = [[NSURL URLWithString:@"/sync/syncdata.go" relativeToURL:[NSURL URLWithString:SSJBaseURLString]] absoluteString];
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:zipData name:@"zip" fileName:kSyncZipFileName mimeType:@"application/x-zip-compressed"];
    } error:&serializationError];
    
    //  封装参数，传入请求头
    NSString *userId = SSJUSERID();
    NSString *imei = [UIDevice currentDevice].identifierForVendor.UUIDString;
    NSString *timestamp = [NSString stringWithFormat:@"%f", [NSDate date].timeIntervalSince1970];
    NSString *source = SSJDefaultSource();
    NSString *iversion = [NSString stringWithFormat:@"%lld", lastSyncVersion];
    NSString *signStr = [[NSString stringWithFormat:@"%@%@%@%@%@%@", userId, imei, timestamp, source, iversion, kSignKey] ssj_md5HexDigest];
    
    NSDictionary *parameters = @{@"cuserId":userId,
                                 @"imei":imei,
                                 @"timestamp":timestamp,
                                 @"source":source,
                                 @"iversion":iversion,
                                 @"md5Code":zipData.md5Hash,
                                 @"sign":signStr};
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    
    if (serializationError) {
        failure(serializationError);
        return;
    }
    
    //  开始上传
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    self.task = [manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        
        //  因为请求回调是在主线程队列中执行，所以在放到同步队列里执行以下操作
        dispatch_async(self.syncQueue, ^{
            
            if (error) {
                failure(error);
                return;
            }
            
            //  上传成功后，如果返回是字典类型，就有错误，解析错误信息
            if (![responseObject isKindOfClass:[NSData class]]) {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    NSInteger code = [responseObject[@"code"] integerValue];
                    NSString *desc = responseObject[@"desc"];
                    NSError *error = [NSError errorWithDomain:SSJErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:desc}];
                    failure(error);
                } else {
                    SSJPRINT(@">>>SSJ warning:responseObject is not NSData or NSDictionary type");
                    failure(nil);
                }
                return;
            }
            
            //  将数据解压
            NSError *tError = nil;
            NSData *jsonData = [self unzipData:responseObject error:&tError];
            
            if (tError) {
                SSJPRINT(@">>>SSJ warning:error:%@", tError);
                failure(tError);
                return;
            }
            
            //  解析json数据
            NSDictionary *tableInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&tError];
            if (tError) {
                SSJPRINT(@">>>SSJ warning:error:%@", tError);
                failure(tError);
                return;
            }
            
            NSInteger errorCode = [tableInfo[@"code"] integerValue];
            if (errorCode != 1) {
                tError = [NSError errorWithDomain:SSJErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey:tableInfo[@"desc"]}];
                SSJPRINT(@">>>SSJ warning:error:%@", tError);
                failure(tError);
                return;
            }
            
            NSString *versinStr = tableInfo[@"syncversion"];
            int64_t syncSuccessVersion = versinStr.length > 0 ? [versinStr longLongValue] : SSJ_INVALID_SYNC_VERSION;
            __block BOOL shouldGoNext = YES;
            
            //  合并顺序：1.收支类型 2.资金帐户 3.记账流水
            [[SSJDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
                NSLog(@"1");
                if (![SSJUserBillSyncTable mergeRecords:tableInfo[@"BK_USER_BILL"] inDatabase:db]
                    || ![SSJUserBillSyncTable updateSyncVersionToServerSyncVersion:syncSuccessVersion inDatabase:db]) {
                    *rollback = YES;
                    shouldGoNext = NO;
                }
            }];
            
            if (!shouldGoNext) {
                failure(nil);
                return;
            }
            
            [[SSJDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
                NSLog(@"2");
                if (![SSJFundInfoSyncTable mergeRecords:tableInfo[@"BK_FUND_INFO"] inDatabase:db]
                    || ![SSJFundInfoSyncTable updateSyncVersionToServerSyncVersion:syncSuccessVersion inDatabase:db]) {
                    *rollback = YES;
                    shouldGoNext = NO;
                }
            }];
            
            if (!shouldGoNext) {
                failure(nil);
                return;
            }
            
            [[SSJDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
                NSLog(@"3");
                if (![SSJUserChargeSyncTable mergeRecords:tableInfo[@"BK_USER_CHARGE"] inDatabase:db]
                    || ![SSJUserChargeSyncTable updateSyncVersionToServerSyncVersion:syncSuccessVersion inDatabase:db]) {
                    *rollback = YES;
                    shouldGoNext = NO;
                    return;
                }
                
                //  根据流水表计算资金帐户余额表和每日流水统计表
                if (![SSJFundAccountTable updateBalanceInDatabase:db]
                    || ![SSJDailySumChargeTable updateDailySumChargeInDatabase:db]) {
                    *rollback = YES;
                    shouldGoNext = NO;
                }
            }];
            
            if (!shouldGoNext) {
                failure(nil);
                return;
            }
            
            //  所有数据合并、更新成功后，插入一个新的记录到BK_SYNC中
            if (shouldGoNext) {
                [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
                    if (![db executeUpdate:@"insert into BK_SYNC (VERSION, TYPE, CUSERID) values(?, 0, ?)", @(syncSuccessVersion), SSJUSERID()]) {
                        SSJPRINT(@">>>SSJ warning\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
                        failure(nil);
                    }
                }];
            }
            
            success();
        });
    }];
    
    [self.task resume];
}

//  将data进行zip压缩
- (NSData *)zipData:(NSData *)data error:(NSError **)error {
    NSString *zipPath = [SSJDocumentPath() stringByAppendingPathComponent:kSyncZipFileName];
    ZZArchive *newArchive = [[ZZArchive alloc] initWithURL:[NSURL fileURLWithPath:zipPath]
                                                   options:@{ZZOpenOptionsCreateIfMissingKey : @YES}
                                                     error:error];
    
//    ZZArchive *newArchive = [[ZZArchive alloc] initWithData:data options:@{ZZOpenOptionsCreateIfMissingKey:@YES} error:error];
    
    ZZArchiveEntry *entry = [ZZArchiveEntry archiveEntryWithFileName:kSyncFileName
                                                            compress:YES
                                                           dataBlock:^(NSError **error) {
                                                               return data;
                                                           }];
    
    if (![newArchive updateEntries:@[entry] error:error]) {
        return nil;
    }
    
//    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[zipPath pathExtension], NULL);
//    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    
    return [NSData dataWithContentsOfFile:@"/Users/oldlang/Desktop/test/new.zip" options:NSDataReadingUncached error:error];
}

//  将data进行解压
- (NSData *)unzipData:(NSData *)data error:(NSError **)error {
//    ZZArchive *archive = [ZZArchive archiveWithURL:[NSURL fileURLWithPath:@"/Users/oldlang/Desktop/test/sync_data.txt.zip"] error:error];
    ZZArchive *archive = [ZZArchive archiveWithData:data error:error];
    if (archive.entries.count > 0) {
        ZZArchiveEntry *entry = archive.entries[0];
        return [entry newDataWithError:error];
    }
    
    return nil;
}

@end
