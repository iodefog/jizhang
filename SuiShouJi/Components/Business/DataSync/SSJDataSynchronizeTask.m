//
//  SSJDataSynchronizeTask.m
//  SuiShouJi
//
//  Created by old lang on 16/2/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDataSynchronizeTask.h"
#import "SSJBillTypeSyncTable.h"
#import "SSJUserBillSyncTable.h"
#import "SSJFundInfoSyncTable.h"
#import "SSJUserChargeSyncTable.h"
#import "SSJUserChargePeriodConfigSyncTable.h"
#import "SSJUserBudgetSyncTable.h"
#import "SSJBooksTypeSyncTable.h"
#import "SSJMemberSyncTable.h"
#import "SSJMemberChargeSyncTable.h"

#import "SSJSyncTable.h"

#import "SSJDatabaseQueue.h"
#import "AFNetworking.h"

#import "SSJUserTableManager.h"
#import "SSJRegularManager.h"

#import <ZipZap/ZipZap.h>

#import "SSJLoginViewController+SSJCategory.h"

//
static const NSTimeInterval kTimeoutInterval = 30;

//  同步文件名称
static NSString *const kSyncFileName = @"sync_data.json";

//  压缩文件名称
static NSString *const kSyncZipFileName = @"sync_data.zip";

@interface SSJDataSynchronizeTask ()

@property (nonatomic) int64_t lastSuccessSyncVersion;

// 需要同步的表
@property (nonatomic, strong) NSArray *syncTableClasses;

@end

@implementation SSJDataSynchronizeTask

- (instancetype)init {
    if (self = [super init]) {
        self.syncTableClasses = @[[SSJBooksTypeSyncTable class],
                                  [SSJBillTypeSyncTable class],
                                  [SSJUserBillSyncTable class],
                                  [SSJFundInfoSyncTable class],
                                  [SSJUserChargePeriodConfigSyncTable class],
                                  [SSJUserChargeSyncTable class],
                                  [SSJUserBudgetSyncTable class],
                                  [SSJMemberSyncTable class],
                                  [SSJMemberChargeSyncTable class]];
    }
    return self;
}

- (void)startSyncWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    __block NSError *tError = nil;
    
    //  获取上次同步成功的版本号
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        self.lastSuccessSyncVersion = [SSJSyncTable lastSuccessSyncVersionForUserId:self.userId inDatabase:db];
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
                
                SSJPRINT(@">>> SSJ Wanings:同步失败-----code:%ld desc:%@", (long)code, desc);
                
                // -5555是用户格式化后原userid被注销了，需要用户重新登陆获取新的userid
                if (code == -5555) {
                    [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"数据已格式化成功，请重新登录！" action:[SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction * _Nonnull action) {
                        [SSJLoginViewController reloginIfNeeded];
                    }], nil];
                } else {
                    if (failure) {
                        failure(tError);
                    }
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
                    
                    //  合并数据完成后根据定期记账和定期预算进行补充；即使补充失败，也不影响同步，在其他时机可以再次补充
                    [SSJRegularManager supplementBookkeepingIfNeededForUserId:self.userId];
                    [SSJRegularManager supplementBudgetIfNeededForUserId:self.userId];
                    
                    // 用户流水表中存在，但是成员流水表中不存在的流水插入到成员流水表中，默认就是用户自己的
                    [[SSJDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
                        BOOL success = [db executeUpdate:@"insert into bk_member_charge (ichargeid, cmemberid, imoney, iversion, cwritedate, operatortype) select a.ichargeid, ?, a.imoney, ?, ?, 0 from bk_user_charge as a left join bk_member_charge as b on a.ichargeid = b.ichargeid where b.ichargeid is null and a.operatortype <> 2 and a.cuserid = ?", [NSString stringWithFormat:@"%@-0", self.userId], @(SSJSyncVersion()), [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], self.userId];
                        if (!success) {
                            *rollback = YES;
                        }
                    }];
                    
                    if (success) {
                        SSJPRINT(@"<<< --------- SSJ Sync Data Success! --------- >>>");
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
            tError = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeDataSyncFailed userInfo:@{NSLocalizedDescriptionKey:@"sync response unknown content type"}];
            if (failure) {
                failure(tError);
            }
        });
    }];
}

//  获取要上传的数据
- (NSData *)getDataToSyncWithError:(NSError * __autoreleasing *)error {
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    
    //  查询要同步的表中的数据
//    __block NSString *userId = nil;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        
//        //  把当前同步的版本号插入到BK_SYNC表中
//        if (![SSJSyncTable insertUnderwaySyncVersion:(self.lastSuccessSyncVersion + 1) forUserId:self.userId inDatabase:db]) {
//            *error = [db lastError];
//            return;
//        }
        
        //  更新当前的版本号
        SSJUpdateSyncVersion(self.lastSuccessSyncVersion + 2);
        
        for (Class syncTable in self.syncTableClasses) {
            NSArray *syncRecords = [syncTable queryRecordsNeedToSyncWithUserId:self.userId inDatabase:db error:error];
            if (syncRecords.count) {
                [jsonObject setObject:syncRecords forKey:[syncTable tableName]];
            }
        }
        
//        userId = [SSJUserTableManager unregisteredUserIdInDatabase:db error:error];
    }];
    
    if (self.userId.length) {
        SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"nickName", @"signature",@"writeDate"] forUserId:self.userId];
        [jsonObject setObject:@[@{@"cuserid":self.userId,
                                  @"crealname":userItem.nickName ?: @"",
                                  @"usersignature":userItem.signature ?: @"",
                                  @"cimei":[UIDevice currentDevice].identifierForVendor.UUIDString,
                                  @"isource":SSJDefaultSource(),
                                  @"operatortype":@1,
                                  @"cwritedate":userItem.writeDate ?: @""}] forKey:@"bk_user"];
    }
    
    if (*error) {
        return nil;
    }
    
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
    NSString *userId = self.userId;
    NSString *imei = [UIDevice currentDevice].identifierForVendor.UUIDString;
    NSString *timestamp = [NSString stringWithFormat:@"%f", [NSDate date].timeIntervalSince1970];
    NSString *source = SSJDefaultSource();
    NSString *iversion = [NSString stringWithFormat:@"%lld", self.lastSuccessSyncVersion];
    NSString *signStr = [[NSString stringWithFormat:@"%@%@%@%@%@%@", userId, imei, timestamp, source, iversion, SSJSyncPrivateKey] ssj_md5HexDigest];
    
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
    
    request.timeoutInterval = kTimeoutInterval;
    
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
        if (![userId isEqualToString:self.userId]) {
            continue;
        }
        
        SSJUserItem *userItem = [[SSJUserItem alloc] init];
        userItem.userId = userId;
        userItem.mobileNo = userInfo[@"cmobileno"];
        userItem.nickName = userInfo[@"crealname"]; // 第三方登录时，服务器返回的crealname就是用户昵称
        userItem.signature = userInfo[@"usersignature"];
        userItem.icon = userInfo[@"cicons"];
        [SSJUserTableManager saveUserItem:userItem];
    }
    
    //  合并顺序：1.收支类型 2.资金帐户 3.定期记账 4.记账流水 5.预算
    __block BOOL mergeSuccess = YES;
    __block BOOL updateVersionSuccess = YES;
    
    for (Class syncTable in self.syncTableClasses) {
        [[SSJDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
            if (![syncTable mergeRecords:tableInfo[[syncTable tableName]] forUserId:self.userId inDatabase:db error:error]) {
                *rollback = YES;
                mergeSuccess = NO;
                return;
            }
            
            if ([versinStr length] && ![syncTable updateSyncVersionOfRecordModifiedDuringSynchronizationToNewVersion:[versinStr longLongValue] + 1 forUserId:self.userId inDatabase:db error:error]) {
                updateVersionSuccess = NO;
            }
        }];
        
        if (!mergeSuccess) {
            return NO;
        }
    }
    
    //  所有数据合并成功、版本号更新成功后，插入一个新的记录到BK_SYNC中
    if (updateVersionSuccess) {
        __block BOOL tSuccess = YES;
        [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
            tSuccess = [SSJSyncTable insertSuccessSyncVersion:[versinStr longLongValue] forUserId:self.userId inDatabase:db];
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
