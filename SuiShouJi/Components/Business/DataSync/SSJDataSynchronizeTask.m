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
#import "SSJUserRemindSyncTable.h"
#import "SSJLoanSyncTable.h"
#import "SSJUserCreditSyncTable.h"
#import "SSJCreditRepaymentSyncTable.h"
#import "SSJTransferCycleSyncTable.h"
#import "SSJUserTable.h"
#import "SSJShareBooksMemberSyncTable.h"
#import "SSJShareBooksSyncTable.h"
#import "SSJShareBooksFriendMarkSyncTable.h"
#import "SSJBooksTypeStore.h"

#import "SSJSyncTable.h"

#import "SSJDatabaseQueue.h"
#import "AFNetworking.h"
#import "SSJFinancingGradientColorItem.h"

#import "SSJRegularManager.h"

#import "SSJLocalNotificationStore.h"
#import "SSJLocalNotificationHelper.h"
#import "SSJDomainManager.h"

#import "ZipArchive.h"

//
static const NSTimeInterval kTimeoutInterval = 30;

static NSString *const kSyncFileDirectory = @"sync_files";

// 上传的同步文件名称
static NSString *const kUploadSyncFileName = @"upload_sync_data.json";

static NSString *const kDownloadSyncFileDirectory = @"download_sync_files";

// 上传的压缩文件名称
static NSString *const kUploadSyncZipFileName = @"upload_sync_data.zip";

static NSString *const kDownloadSyncZipFileName = @"download_sync_data.zip";

@interface SSJDataSynchronizeTask ()

@property (nonatomic) int64_t lastSuccessSyncVersion;

// 需要同步的表
@property (nonatomic, strong) NSArray *syncTableClasses;

@end

@implementation SSJDataSynchronizeTask

- (instancetype)init {
    if (self = [super init]) {
        NSSet *firstLayer = [NSSet setWithObjects:[SSJUserRemindSyncTable class],
                                                  [SSJBooksTypeSyncTable class],
                                                  [SSJMemberSyncTable class],
                                                  [SSJBillTypeSyncTable class], nil];
        
        NSSet *secondLayer = [NSSet setWithObjects:[SSJFundInfoSyncTable class],
                                                   [SSJUserCreditSyncTable class],
                                                   [SSJCreditRepaymentSyncTable class],
                                                   [SSJUserBillSyncTable class],
                                                   [SSJUserBudgetSyncTable class], nil];
        
        NSSet *thirdLayer = [NSSet setWithObjects:[SSJUserChargePeriodConfigSyncTable class],
                                                  [SSJTransferCycleSyncTable class],
                                                  [SSJLoanSyncTable class],
                                                  [SSJShareBooksSyncTable class],
                                                  [SSJShareBooksMemberSyncTable class],
                                                  [SSJShareBooksFriendMarkSyncTable class], nil];
        
        NSSet *fourthLayer = [NSSet setWithObjects:[SSJUserChargeSyncTable class], nil];
        
        NSSet *fifthLayer = [NSSet setWithObjects:[SSJMemberChargeSyncTable class], nil];
        
        
        self.syncTableClasses = @[firstLayer, secondLayer, thirdLayer, fourthLayer, fifthLayer];
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
        // 因为请求回调是在主线程队列中执行，所以在放到同步队列里执行以下操作
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
            
            // 返回的是json数据格式
            if ([contentType isEqualToString:@"text/json;charset=UTF-8"]) {
                NSDictionary *responseInfo = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&tError];
                NSInteger code = [responseInfo[@"code"] integerValue];
                NSString *desc = responseInfo[@"desc"];
                tError = [NSError errorWithDomain:SSJErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey:desc}];
                
                SSJPRINT(@">>> SSJ Wanings:同步失败-----code:%ld desc:%@", (long)code, desc);
                
                if (failure) {
                    failure(tError);
                }
                return;
            }
            
            //  返回未知数据
            if (![contentType isEqualToString:@"APPLICATION/OCTET-STREAM"]) {
                SSJPRINT(@">>> SSJ warning:sync response unknown content type:%@", contentType);
                tError = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeDataSyncFailed userInfo:@{NSLocalizedDescriptionKey:@"sync response unknown content type"}];
                if (failure) {
                    failure(tError);
                }
                return;
            }
            
            
            //  返回的是zip压缩包
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
            
            //  解析json数据
            NSDictionary *tableInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&tError];
            if (tError) {
                SSJPRINT(@">>> SSJ warning:an error occured when parse json data\n error:%@", tError);
                if (failure) {
                    failure(tError);
                }
                return;
            }
            
            //    SSJPRINT(@">>> sync response data:%@", tableInfo);
            
            NSInteger errorCode = [tableInfo[@"code"] integerValue];
            if (errorCode != 1) {
                tError = [NSError errorWithDomain:SSJErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey:tableInfo[@"desc"]}];
                SSJPRINT(@">>> SSJ warning:server response an error:%@", tError);
                if (failure) {
                    failure(tError);
                }
                return;
            }
            
            //  合并数据
            if (![self mergeData:tableInfo error:&tError]) {
                tError = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:[tError localizedDescription]}];
                SSJPRINT(@">>> SSJ warning:server response an error:%@", tError);
                if (failure) {
                    failure(tError);
                }
                return;
            }
            
            [self extraProcessAfterMerge];
            
            if (success) {
                SSJPRINT(@"<<< --------- SSJ Sync Data Success! --------- >>>");
                success();
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
        
        //  更新当前的版本号
        SSJUpdateSyncVersion(self.lastSuccessSyncVersion + 2);
        
        for (NSSet *layer in self.syncTableClasses) {
            for (Class syncTable in layer) {
                NSArray *syncRecords = [syncTable queryRecordsNeedToSyncWithUserId:self.userId inDatabase:db error:error];
                if (syncRecords.count) {
                    [jsonObject setObject:syncRecords forKey:[syncTable tableName]];
                }
            }
        }
    }];
    
    if (self.userId.length) {
        [jsonObject setObject:@[[SSJUserTable syncDataWithUserId:self.userId]] forKey:@"bk_user"];
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
    [syncData writeToFile:[SSJDocumentPath() stringByAppendingPathComponent:@"sync_data.txt"] atomically:YES];
#endif
    
    return syncData;
}

//  上传文件
- (void)uploadData:(NSData *)data completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    
    //  创建请求
    NSError *tError = nil;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:SSJURLWithAPI(@"/sync/syncdata.go") parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSString *fileName = [NSString stringWithFormat:@"ios_sync_data_%lld.zip", SSJMilliTimestamp()];
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
    NSString *timestamp = [NSString stringWithFormat:@"%lld", SSJMilliTimestamp()];
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
    
    NSURLSessionUploadTask *task = [self.sessionManager uploadTaskWithStreamedRequest:request progress:nil completionHandler:completionHandler];
    [task resume];
}

//  合并json数据
- (BOOL)mergeData:(NSDictionary *)tableInfo error:(NSError **)error {
    
    if (![tableInfo isKindOfClass:[NSDictionary class]]) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"服务端返回的数据格式错误"}];
        }
        return NO;
    }
    
    NSString *versinStr = tableInfo[@"syncversion"];
    
    // 存储当前同步用户数据
    NSArray *userArr = tableInfo[@"bk_user"];
    if (userArr && ![userArr isKindOfClass:[NSArray class]]) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"服务端返回的bk_user数据格式错误"}];
        }
        return NO;
    }
    
    for (NSDictionary *userInfo in userArr) {
        if (![userInfo isKindOfClass:[NSDictionary class]]) {
            if (error) {
                *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"服务端返回的bk_user数据格式错误"}];
            }
            return NO;
        }
        
        NSString *userId = userInfo[@"cuserid"];
        if (![userId isEqualToString:self.userId]) {
            continue;
        }
        [SSJUserTable mergeData:userInfo];
        
    }
    
    // 合并顺序：1.收支类型 2.资金账户 3.定期记账 4.记账流水 5.预算
    __block BOOL mergeSuccess = YES;
    __block BOOL updateVersionSuccess = YES;
    
    for (NSSet *layer in self.syncTableClasses) {
        for (Class syncTable in layer) {
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
    }
    
    // 所有数据合并成功、版本号更新成功后，插入一个新的记录到BK_SYNC中
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

- (void)extraProcessAfterMerge {
    // 如果用户当前账本已删除，就切换成日常账本
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        int operatorType = [db intForQuery:@"select bt.operatortype from bk_books_type as bt, bk_user as u where u.cuserid = ? and bt.cuserid = u.cuserid and u.ccurrentbooksid = bt.cbooksid", self.userId];
        if (operatorType == 2) {
            [db executeUpdate:@"update bk_user set ccurrentbooksid = ?", self.userId];
            SSJDispatchMainAsync(^{
                [[NSNotificationCenter defaultCenter] postNotificationName:SSJBooksTypeDidChangeNotification object:nil];
            });
        }
    }];
    
    // 如果当前的账本已经被踢,那切换回默认账本
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        
        NSString *currentBooksid = [db stringForQuery:@"select ccurrentbooksid from bk_user where cuserid = ?",self.userId];
        
        if ([db boolForQuery:@"select count(1) from bk_share_books where cbooksid = ?",currentBooksid]) {
            
            NSInteger currentBooksStatus = [db intForQuery:@"select istate from bk_share_books_member where cbooksid = ? and cmemberid = ?",currentBooksid,self.userId];
            if (currentBooksStatus != SSJShareBooksMemberStateNormal) {
                [db executeUpdate:@"update bk_user set ccurrentbooksid = ?",self.userId];
                SSJDispatchMainSync(^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:SSJBooksTypeDidChangeNotification object:NULL];
                });
            }
        }
        
    }];
    
    // 合并数据完成后补充周期记账、周期转账、预算；即使补充失败，也不影响同步，在其他时机可以再次补充
    [SSJRegularManager supplementCycleRecordsForUserId:self.userId];
    
    // 用户流水表中存在，但是成员流水表中不存在的流水插入到成员流水表中，默认就是用户自己的
    [[SSJDatabaseQueue sharedInstance] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        BOOL success = [db executeUpdate:@"insert into bk_member_charge (ichargeid, cmemberid, imoney, iversion, cwritedate, operatortype) select a.ichargeid, ?, a.imoney, ?, ?, 0 from bk_user_charge as a left join bk_member_charge as b on a.ichargeid = b.ichargeid where b.ichargeid is null and a.operatortype <> 2 and a.cuserid = ?", [NSString stringWithFormat:@"%@-0", self.userId], @(SSJSyncVersion()), [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"], self.userId];
        if (!success) {
            *rollback = YES;
        }
    }];
    
    // 根据用户的提醒表中的记录注册本地通知
    [SSJLocalNotificationHelper cancelLocalNotificationWithKey:SSJReminderNotificationKey];
    [SSJLocalNotificationStore queryForreminderListForUserId:self.userId WithSuccess:^(NSArray<SSJReminderItem *> *result) {
        for (SSJReminderItem *item in result) {
            [SSJLocalNotificationHelper registerLocalNotificationWithremindItem:item];
        }
    } failure:^(NSError *error) {
        SSJPRINT(@"警告：同步后注册本地通知失败 error:%@", [error localizedDescription]);
    }];
    
    // 因为老版本没有同步账本图标，老版本同步过来的数据图表为空，所以这里把图标加上
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSString *booksID1 = self.userId;
        NSString *booksID2 = [NSString stringWithFormat:@"%@-1", self.userId];
        NSString *booksID3 = [NSString stringWithFormat:@"%@-2", self.userId];
        NSString *booksID4 = [NSString stringWithFormat:@"%@-3", self.userId];
        NSString *booksID5 = [NSString stringWithFormat:@"%@-4", self.userId];
        
        [db executeUpdate:@"update bk_books_type set cicoin = 'bk_moren' where cbooksid = ? and cuserid = ? and (length(cicoin) == 0 or cicoin is null)", booksID1, self.userId];
        [db executeUpdate:@"update bk_books_type set cicoin = 'bk_shengyi' where cbooksid = ? and cuserid = ? and (length(cicoin) == 0 or cicoin is null)", booksID2, self.userId];
        [db executeUpdate:@"update bk_books_type set cicoin = 'bk_jiehun' where cbooksid = ? and cuserid = ? and (length(cicoin) == 0 or cicoin is null)", booksID3, self.userId];
        [db executeUpdate:@"update bk_books_type set cicoin = 'bk_zhuangxiu' where cbooksid = ? and cuserid = ? and (length(cicoin) == 0 or cicoin is null)", booksID4, self.userId];
        [db executeUpdate:@"update bk_books_type set cicoin = 'bk_lvxing' where cbooksid = ? and cuserid = ? and (length(cicoin) == 0 or cicoin is null)", booksID5, self.userId];
        
        NSString *sqlStr = [NSString stringWithFormat:@"update bk_books_type set cicoin = 'bk_moren' where cbooksid not in ('%@', '%@', '%@', '%@', '%@') and cuserid = '%@' and (length(cicoin) == 0 or cicoin is null)", booksID1, booksID2, booksID3, booksID4, booksID5, self.userId];
        [db executeUpdate:sqlStr];
    }];
    
    // 将没有新加字段cdetaildate的流水补上
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:@"update bk_user_charge set cdetaildate = '00:00' where ichargetype = ?", @(SSJChargeIdTypeCircleConfig)];
        
        [db executeUpdate:@"update bk_user_charge set cdetaildate = (select substr(clientadddate,12,5) from bk_user_charge where length(cdetaildate) = 0 or cdetaildate is null) where length(clientadddate) > 0 and ichargetype <> ? and (length(cdetaildate) = 0 or cdetaildate is null)", @(SSJChargeIdTypeCircleConfig)];
        
        [db executeUpdate:@"update bk_user_charge set cdetaildate = (select substr(cwritedate,12,5) from bk_user_charge where length(cdetaildate) = 0 or cdetaildate is null) where length(cdetaildate) = 0 or cdetaildate is null"];
        
    }];
    
    // 将没有渐变色的数据改成渐变色
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:@"select cfundid ,iorder from bk_fund_info where (length(cstartcolor) = 0 or cstartcolor is null) and cparent <> 'root' and operatortype <> 2"];
        
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        
        NSString *cwriteDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        NSArray *colors = [SSJFinancingGradientColorItem defualtColors];
        
        while ([result next]) {
            NSString *fundid = [result stringForColumn:@"cfundid"];
            NSString *order = [result stringForColumn:@"iorder"] ?: @"";
            NSDictionary *dic = @{@"fundid":fundid,
                                  @"order":order};
            [tempArr addObject:dic];
        };
        
        for (NSDictionary *dict in tempArr) {
            NSString *fundid = [dict objectForKey:@"fundid"];
            NSString *order = [dict objectForKey:@"order"];
            NSInteger index = [order integerValue];
            if (index > 1) {
                index --;
            }
            index = index - index / 7 * 7;
            SSJFinancingGradientColorItem *item = [colors objectAtIndex:index];
            [db executeUpdate:@"update bk_fund_info set cstartcolor = ? , cendcolor = ?, cwritedate = ?, iversion = ?, operatortype = 1 where cfundid = ?",item.startColor,item.endColor,cwriteDate,@(SSJSyncVersion()),fundid];
        }
    }];
    
    
    // 删除已经退出的账本中的share_books,share_books_friends_mark
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:@"delete from bk_share_books where cbooksid in (select cbooksid from bk_share_books_member where cmemberid = ? and istate != ?)",self.userId,@(SSJShareBooksMemberStateNormal)];
        
        [db executeUpdate:@"delete from bk_share_books_friends_mark where cbooksid in (select cbooksid from bk_share_books_member where cmemberid = ? and istate != ?)",self.userId,@(SSJShareBooksMemberStateNormal)];
    }];
    
    
    // 将一个收支类别的账本补充一套收支类别
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        NSMutableArray *booksResult = [NSMutableArray arrayWithCapacity:0];
        
        FMResultSet *shareBooksResult = [db executeQuery:@"select sb.iparenttype ,ub.cbooksid ,ub.cuserid , count(ub.cbillid) from bk_share_books sb, bk_share_books_member sbm left join bk_user_bill ub on sbm.cbooksid = ub.cbooksid and ub.cuserid = sbm.cmemberid where length(ub.cbillid) < 10 and ub.cuserid = ? and sb.cbooksid = ub.cbooksid group by ub.cbooksid, ub.cuserid having count(ub.cbillid) = 0",self.userId];
        
        while ([shareBooksResult next]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
            NSString *booksId = [shareBooksResult stringForColumn:@"cbooksid"];
            NSInteger parentType = [shareBooksResult intForColumn:@"iparenttype"];
            [dic setObject:booksId forKey:@"cbooksid"];
            [dic setObject:@(parentType) forKey:@"iparenttype"];
            [booksResult addObject:dic];
        }
        
        [shareBooksResult close];
        
        FMResultSet *normalBooksResult = [db executeQuery:@"select bt.iparenttype, ub.cbooksid, ub.cuserid, count(ub.cbillid) from bk_books_type bt left join bk_user_bill ub on bt.cbooksid = ub.cbooksid and ub.cuserid = bt.cuserid where length(ub.cbillid) < 10 and ub.cuserid = ? group by ub.cbooksid, ub.cuserid having count(ub.cbillid) = 0",self.userId];
        
        while ([normalBooksResult next]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
            NSString *booksId = [normalBooksResult stringForColumn:@"cbooksid"];
            NSInteger parentType = [normalBooksResult intForColumn:@"iparenttype"];
            [dic setObject:booksId forKey:@"cbooksid"];
            [dic setObject:@(parentType) forKey:@"iparenttype"];
            [booksResult addObject:dic];
        }
        
        [shareBooksResult close];
        
        for (NSDictionary *dic in booksResult) {
            NSString *booksId = [dic objectForKey:@"cbooksid"];
            NSInteger parentType = [[dic objectForKey:@"iparenttype"] integerValue];
            SSJBooksTypeItem *item = [[SSJBooksTypeItem alloc] init];
            item.booksId = booksId;
            item.booksParent = parentType;
            [SSJBooksTypeStore generateBooksTypeForBooksItem:item indatabase:db forUserId:self.userId];
        }
    }];

}


//  将data进行zip压缩
- (NSData *)zipData:(NSData *)data error:(NSError **)error {
    NSString *syncFilePath = [[self syncFileDirectory] stringByAppendingPathComponent:kUploadSyncFileName];
    if (![data writeToFile:syncFilePath options:NSDataWritingAtomic error:error]) {
        return nil;
    }
    
    NSString *zipPath = [[self syncFileDirectory] stringByAppendingPathComponent:kUploadSyncZipFileName];
    if (![SSZipArchive createZipFileAtPath:zipPath withFilesAtPaths:@[syncFilePath]]) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"压缩文件发生错误"}];
        }
        return nil;
    }
    
    return [NSData dataWithContentsOfFile:zipPath];
}

//  将data进行解压
- (NSData *)unzipData:(NSData *)data error:(NSError **)error {
    NSString *zipFilePath = [[self syncFileDirectory] stringByAppendingPathComponent:kDownloadSyncZipFileName];
    if (![data writeToFile:zipFilePath options:NSDataWritingAtomic error:error]) {
        return nil;
    }
    
    NSString *unzipDirectory = [[self syncFileDirectory] stringByAppendingPathComponent:kDownloadSyncFileDirectory];
    if (![SSZipArchive unzipFileAtPath:zipFilePath toDestination:unzipDirectory overwrite:NO password:nil error:error]) {
        return nil;
    }
    
    NSArray *tempFileList = [[NSArray alloc] initWithArray:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:unzipDirectory error:nil]];
    NSString *jsonFileName = [tempFileList lastObject];
    if (![jsonFileName.pathExtension isEqualToString:@"json"]) {
        [[NSFileManager defaultManager] removeItemAtPath:unzipDirectory error:nil];
        return nil;
    }
    
    NSData *unzipData = [NSData dataWithContentsOfFile:[unzipDirectory stringByAppendingPathComponent:jsonFileName]];
    [[NSFileManager defaultManager] removeItemAtPath:unzipDirectory error:nil];
    
    return unzipData;
}

- (NSString *)syncFileDirectory {
    NSString *directory = [SSJDocumentPath() stringByAppendingPathComponent:kSyncFileDirectory];
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return directory;
}

@end

#import "SSJDataClearHelper.h"

@implementation SSJDataSynchronizeTask (Simulation)

+ (void)simulateUserSync:(NSString *)userId {
    [[[[[self updateUserId:userId] then:^RACSignal *{
        return [self pullUserData];
    }] then:^RACSignal *{
        return [self mergeUserData];
    }] then:^RACSignal *{
        return [self clearSyncVersion];
    }] subscribeError:^(NSError *error) {
        SSJDispatchMainAsync(^{
            [SSJAlertViewAdapter showError:error];
        });
    } completed:^{
        SSJDispatchMainAsync(^{
            [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"模拟用户数据成功" action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
        });
    }];
}

+ (RACSignal *)updateUserId:(NSString *)userId {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
            BOOL successful = YES;
            if (![db boolForQuery:@"select count(*) from bk_user where cuserid = ?", userId]) {
                successful = [db executeUpdate:@"insert into bk_user (cuserid, cregisterstate) values (?, 1)", userId];
                successful = successful && SSJSetUserId(userId) && SSJSaveUserLogined(YES);
            }
            
            if (successful) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:[db lastError]];
            }
        }];
        return nil;
    }];
}

+ (RACSignal *)pullUserData {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJDataClearHelper clearLocalDataWithSuccess:^{
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        } failure:^(NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

+ (RACSignal *)clearSyncVersion {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(SSJDatabase *db) {
            if ([db executeUpdate:@"delete from bk_sync where cuserid = ?", SSJUSERID()]) {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            } else {
                [subscriber sendError:[db lastError]];
            }
        }];
        return nil;
    }];
}

+ (RACSignal *)mergeUserData {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError *error = nil;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"sync_data" ofType:@"json"];
        NSData *jsonData = [NSData dataWithContentsOfFile:path];
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        
        SSJDataSynchronizeTask *task = [SSJDataSynchronizeTask task];
        task.userId = SSJUSERID();
        //  合并数据
        if ([task mergeData:data error:&error]) {
            [task extraProcessAfterMerge];
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        } else {
            [subscriber sendError:error];
        }
        
        return nil;
    }];
}

@end
