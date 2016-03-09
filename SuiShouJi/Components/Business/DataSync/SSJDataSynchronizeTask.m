//
//  SSJDataSynchronizeTask.m
//  SuiShouJi
//
//  Created by old lang on 16/2/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDataSynchronizeTask.h"
#import "SSJUserBillSyncTable.h"
#import "SSJFundInfoSyncTable.h"
#import "SSJUserChargeSyncTable.h"
#import "SSJUserChargePeriodConfigSyncTable.h"
#import "SSJUserBudgetSyncTable.h"

#import "SSJSyncTable.h"
#import "SSJFundAccountTable.h"
#import "SSJDailySumChargeTable.h"

#import "SSJDatabaseQueue.h"
#import "SSZipArchive.h"
#import "AFNetworking.h"

#import "SSJUserTableManager.h"
#import "SSJRegularManager.h"

#import <ZipZap/ZipZap.h>

//  同步文件名称
static NSString *const kSyncFileName = @"sync_data.json";

//  压缩文件名称
static NSString *const kSyncZipFileName = @"sync_data.zip";

@interface SSJDataSynchronizeTask ()

@property (nonatomic) int64_t lastSuccessSyncVersion;

@end

@implementation SSJDataSynchronizeTask

@synthesize syncQueue;

- (void)startSyncWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    __block NSError *tError = nil;
    
    //  获取上次同步成功的版本号
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        self.lastSuccessSyncVersion = [SSJSyncTable lastSuccessSyncVersionInDatabase:db];
        if (self.lastSuccessSyncVersion == SSJ_INVALID_SYNC_VERSION) {
            tError = [db lastError];
        }
    }];
    
    if (tError) {
        if (failure) {
            failure(tError);
        }
        return;
    }
    
    //  查询要同步的数据
    NSData *data = [self getDataToSyncWithError:&tError];
    if (tError) {
        if (failure) {
            failure(tError);
        }
        return;
    }
    
    if (!data) {
        SSJPRINT(@"there is no data to be uploaded");
        if (success) {
            success();
        }
        return;
    }
    
    //  压缩文件，准备上传
    NSData *zipData = [self zipData:data error:&tError];
    
    if (tError) {
        SSJPRINT(@">>> SSJ warning:an error occured when zip json data \n error:%@", tError);
        if (failure) {
            failure(tError);
        }
        return;
    }
    
    //  上传数据
    [self uploadData:zipData completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        //  因为请求回调是在主线程队列中执行，所以在放到同步队列里执行以下操作
        dispatch_async(self.syncQueue, ^{
            
            if (error) {
                if (failure) {
                    failure(error);
                }
                return;
            }
            
            NSHTTPURLResponse *tResponse = (NSHTTPURLResponse *)response;
            //            SSJPRINT(@">>> SSJ sync response headers:%@", tResponse.allHeaderFields);
            NSString *contentType = tResponse.allHeaderFields[@"Content-Type"];
            
            //  返回的是json数据格式
            if ([contentType isEqualToString:@"text/json;charset=UTF-8"]) {
                NSDictionary *responseInfo = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&tError];
                NSInteger code = [responseInfo[@"code"] integerValue];
                NSString *desc = responseInfo[@"desc"];
                tError = [NSError errorWithDomain:SSJErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:desc}];
                
                //                SSJPRINT(@">>> SSJ sync response data:%@", responseObject);
                if (failure) {
                    failure(tError);
                }
                return;
            }
            
            //  返回的是zip压缩包
            if ([contentType isEqualToString:@"APPLICATION/OCTET-STREAM"]) {
                
                //  将数据解压
                NSError *tError = nil;
                NSData *jsonData = [self unzipData:responseObject error:&tError];
                
                if (tError) {
                    SSJPRINT(@">>> SSJ warning:an error occured when unzip response data\n error:%@", tError);
                    if (failure) {
                        failure(tError);
                    }
                    return;
                }
                
                //  合并数据
                if ([self mergeJsonData:jsonData error:&tError]) {
                    //  合并数据完成后
                    [SSJRegularManager supplementBookkeepingIfNeededForUserId:SSJCurrentSyncDataUserId()];
                    [SSJRegularManager supplementBudgetIfNeededForUserId:SSJCurrentSyncDataUserId()];
                    if (success) {
                        success();
                    }
                } else {
                    if (failure) {
                        failure(tError);
                    }
                }
                return;
            }
            
            //  返回未知数据
            SSJPRINT(@">>> SSJ warning:sync response unknown content type:%@", contentType);
            tError = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"sync response unknown content type"}];
            if (failure) {
                failure(tError);
            }
        });
    }];
}

//  获取要上传的数据
- (NSData *)getDataToSyncWithError:(NSError * __autoreleasing *)error {
    __block NSArray *userChargeRecords = nil;
    __block NSArray *fundInfoRecords = nil;
    __block NSArray *userBillRecords = nil;
    __block NSString *userId = nil;
    
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        
        //  把当前同步的版本号插入到BK_SYNC表中
        if (![SSJSyncTable insertUnderwaySyncVersion:(self.lastSuccessSyncVersion + 1) inDatabase:db]) {
            *error = [db lastError];
            return;
        }
        
        SSJUpdateSyncVersion(self.lastSuccessSyncVersion + 2);
        
        //  查询需要同步的表中 版本号（IVERSION）大于上次同步成功版本号（lastSyncVersion）的记录，
        userBillRecords = [SSJUserBillSyncTable queryRecordsNeedToSyncInDatabase:db error:error];
        fundInfoRecords = [SSJFundInfoSyncTable queryRecordsNeedToSyncInDatabase:db error:error];
        userChargeRecords = [SSJUserChargeSyncTable queryRecordsNeedToSyncInDatabase:db error:error];
        userId = [SSJUserTableManager unregisteredUserIdInDatabase:db error:error];
    }];
    
    if (*error) {
        return nil;
    }
    
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
    if (userId.length && !SSJIsUserLogined()) {
        [jsonObject setObject:@[@{@"cuserid":userId,
                                  @"cimei":[UIDevice currentDevice].identifierForVendor.UUIDString,
                                  @"isource":SSJDefaultSource()}] forKey:@"bk_user"];
    }
    
    //    SSJPRINT(@">>> sync upload data:%@", jsonObject);
    
    //  将查询得到的结果放入字典中，转换成json数据
    NSData *syncData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:error];
    if (*error) {
        SSJPRINT(@">>> SSJ warning:an error occured when parse json data \n error:%@", *error);
        return nil;
    }
    
#ifdef DEBUG
    [syncData writeToFile:@"/Users/oldlang/Desktop/sync_data.txt" atomically:YES];
#endif
    
    return syncData;
}

//  上传文件流
- (void)uploadData:(NSData *)data completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    
    //  创建请求
    NSString *urlString = [[NSURL URLWithString:@"/sync/syncdata.go" relativeToURL:[NSURL URLWithString:SSJBaseURLString]] absoluteString];
    
    NSError *tError = nil;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSString *fileName = [NSString stringWithFormat:@"ios_sync_data_%ld.zip", (long)[NSDate date].timeIntervalSince1970];
        [formData appendPartWithFileData:data name:@"zip" fileName:fileName mimeType:@"application/zip"];
    } error:&tError];
    
    if (tError) {
        if (completionHandler) {
            completionHandler(nil, nil, tError);
        }
        return;
    }
    
    //  封装参数，传入请求头
    NSString *userId = SSJCurrentSyncDataUserId();
    NSString *imei = [UIDevice currentDevice].identifierForVendor.UUIDString;
    NSString *timestamp = [NSString stringWithFormat:@"%f", [NSDate date].timeIntervalSince1970];
    NSString *source = SSJDefaultSource();
    NSString *iversion = [NSString stringWithFormat:@"%lld", self.lastSuccessSyncVersion];
    NSString *signStr = [[NSString stringWithFormat:@"%@%@%@%@%@%@", userId, imei, timestamp, source, iversion, kSignKey] ssj_md5HexDigest];
    
    NSDictionary *parameters = @{@"cuserId":userId,
                                 @"imei":imei,
                                 @"timestamp":timestamp,
                                 @"source":source,
                                 @"iversion":iversion,
                                 @"md5Code":data.md5Hash,
                                 @"sign":signStr,
                                 @"appVersion":SSJAppVersion()};
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    
    //  开始上传
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //    NSProgress *progress = nil;
    NSURLSessionUploadTask *task = [manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:completionHandler];
    [task resume];
}

//  合并json数据
- (BOOL)mergeJsonData:(NSData *)jsonData error:(NSError **)error {
    
    //  解析json数据
    NSDictionary *tableInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:error];
    if (*error) {
        SSJPRINT(@">>> SSJ warning:an error occured when parse json data\n error:%@", *error);
        return NO;
    }
    
    //    SSJPRINT(@">>> sync response data:%@", tableInfo);
    
    NSInteger errorCode = [tableInfo[@"code"] integerValue];
    if (errorCode != 1) {
        *error = [NSError errorWithDomain:SSJErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey:tableInfo[@"desc"]}];
        SSJPRINT(@">>> SSJ warning:server response an error:%@", *error);
        return NO;
    }
    
    NSString *versinStr = tableInfo[@"syncversion"];
    
    //  存储当前同步用户数据
    NSArray *userArr = tableInfo[@"bk_user"];
    for (NSDictionary *userInfo in userArr) {
        NSString *userId = userInfo[@"cuserid"];
        if (![userId isEqualToString:SSJCurrentSyncDataUserId()]) {
            continue;
        }
        NSString *mobileNo = userInfo[@"cmobileno"];
        NSString *icon = userInfo[@"cicon"];
        [SSJUserTableManager saveUserInfo:@{SSJUserIdKey:userId ?: @"",
                                            SSJUserMobileNoKey:mobileNo ?: @"",
                                            SSJUserIconKey:icon ?: @""} error:nil];
    }
    
    //  合并顺序：1.收支类型 2.资金帐户 3.定期记账 4.记账流水 5.预算
    __block BOOL mergeSuccess = YES;
    __block BOOL updateVersionSuccess = YES;
    
    //  收支类型
    [[SSJDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (![SSJUserBillSyncTable mergeRecords:tableInfo[@"bk_user_bill"] inDatabase:db error:error]) {
            *rollback = YES;
            mergeSuccess = NO;
            return;
        }
        
        if ([versinStr length] && ![SSJUserBillSyncTable updateSyncVersionOfRecordModifiedDuringSynchronizationToNewVersion:[versinStr longLongValue] inDatabase:db error:error]) {
            updateVersionSuccess = NO;
        }
    }];
    
    if (!mergeSuccess) {
        return NO;
    }
    
    //  资金帐户
    [[SSJDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (![SSJFundInfoSyncTable mergeRecords:tableInfo[@"bk_fund_info"] inDatabase:db error:error]) {
            *rollback = YES;
            mergeSuccess = NO;
            return;
        }
        
        if ([versinStr length] && ![SSJFundInfoSyncTable updateSyncVersionOfRecordModifiedDuringSynchronizationToNewVersion:[versinStr longLongValue] inDatabase:db error:error]) {
            updateVersionSuccess = NO;
        }
    }];
    
    if (!mergeSuccess) {
        return NO;
    }
    
    //  定期记账
    [[SSJDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (![SSJUserChargePeriodConfigSyncTable mergeRecords:tableInfo[@"bk_charge_period_config"] inDatabase:db error:error]) {
            *rollback = YES;
            mergeSuccess = NO;
            return;
        }
        
        if ([versinStr length] && ![SSJUserChargePeriodConfigSyncTable updateSyncVersionOfRecordModifiedDuringSynchronizationToNewVersion:[versinStr longLongValue] inDatabase:db error:error]) {
            updateVersionSuccess = NO;
        }
    }];
    
    if (!mergeSuccess) {
        return NO;
    }
    
    //  记账流水
    [[SSJDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (![SSJUserChargeSyncTable mergeRecords:tableInfo[@"bk_user_charge"] inDatabase:db error:error]) {
            *rollback = YES;
            mergeSuccess = NO;
            return;
        }
        
        //  根据流水表计算资金帐户余额表和每日流水统计表
        if (![SSJFundAccountTable updateBalanceInDatabase:db]
            || ![SSJDailySumChargeTable updateDailySumChargeInDatabase:db]) {
            *rollback = YES;
            mergeSuccess = NO;
            *error = [db lastError];
            return;
        }
        
        if ([versinStr length] && ![SSJUserChargeSyncTable updateSyncVersionOfRecordModifiedDuringSynchronizationToNewVersion:[versinStr longLongValue] inDatabase:db error:error]) {
            updateVersionSuccess = NO;
        }
    }];
    
    if (!mergeSuccess) {
        return NO;
    }
    
    //  预算
    [[SSJDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (![SSJUserBudgetSyncTable mergeRecords:tableInfo[@"bk_user_budget"] inDatabase:db error:error]) {
            *rollback = YES;
            mergeSuccess = NO;
            return;
        }
        
        if ([versinStr length] && ![SSJUserBudgetSyncTable updateSyncVersionOfRecordModifiedDuringSynchronizationToNewVersion:[versinStr longLongValue] inDatabase:db error:error]) {
            updateVersionSuccess = NO;
        }
    }];
    
    if (!mergeSuccess) {
        return NO;
    }
    
    //  所有数据合并成功、版本号更新成功后，插入一个新的记录到BK_SYNC中
    if (updateVersionSuccess) {
        __block BOOL tSuccess = YES;
        [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
            tSuccess = [SSJSyncTable insertSuccessSyncVersion:[versinStr longLongValue] inDatabase:db];
        }];
        
        if (tSuccess) {
            SSJUpdateSyncVersion([versinStr longLongValue] + 1);
        }
    }
    
    return mergeSuccess;
}

//  将data进行zip压缩
- (NSData *)zipData:(NSData *)data error:(NSError **)error {
    NSString *zipPath = [SSJDocumentPath() stringByAppendingPathComponent:kSyncZipFileName];
    ZZArchive *newArchive = [[ZZArchive alloc] initWithURL:[NSURL fileURLWithPath:zipPath]
                                                   options:@{ZZOpenOptionsCreateIfMissingKey:@YES}
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
    
    return [NSData dataWithContentsOfFile:zipPath options:NSDataReadingUncached error:error];
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
