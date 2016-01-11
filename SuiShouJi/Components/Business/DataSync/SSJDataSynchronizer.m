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
#import "SSJDatabaseQueue.h"
#import "SSZipArchive.h"
#import "AFNetworking.h"

static NSString *const kSyncFileName = @"sync_json.text";
static NSString *const kSyncZipFileName = @"sync_json.zip";

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
    }
    return self;
}

- (void)startSync {
    if (self.task == nil) {
        lastSyncVersion = SSJ_INVALID_SYNC_VERSION;
        [self startSyncData];
    }
}

- (void)startSyncData {
    dispatch_async(self.syncQueue, ^{
        __block NSInteger currentSyncVersion;
        
        __block NSArray *userChargeRecords = nil;
        __block NSArray *fundInfoRecords = nil;
        __block NSArray *userBillRecords = nil;
        
        [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
            
            //  获取上次同步成功的版本号
            [SSJSyncTable lastSuccessSyncVersionInDatabase:db];
            if (lastSyncVersion == SSJ_INVALID_SYNC_VERSION) {
                return;
            }
            
            //  设置当前同步的版本号
            currentSyncVersion = lastSyncVersion + 1;
            
            //  把当前同步的版本号插入到BK_SYNC表中
            if (![db executeUpdate:@"insert into BK_SYNC values (?, 1)", @(currentSyncVersion)]) {
                SSJPRINT(@">>>SSJ warning\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
                return;
            }
            
            //  查询需要同步的表中 版本号（IVERSION）大于上次同步成功版本号（lastSyncVersion）的记录，
            userBillRecords = [SSJUserBillSyncTable queryRecordsForSyncInDatabase:db];
            fundInfoRecords = [SSJFundInfoSyncTable queryRecordsForSyncInDatabase:db];
            userChargeRecords = [SSJUserChargeSyncTable queryRecordsForSyncInDatabase:db];
            
            
        }];
        
        //  将查询得到的结果放入字典中，转换成json数据
        NSError *error = nil;
        NSData *syncData = [NSJSONSerialization dataWithJSONObject:@{@"BK_USER_BILL":userBillRecords, @"BK_FUND_INFO":fundInfoRecords, @"BK_USER_CHARGE":userChargeRecords} options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            SSJPRINT(@">>>SSJ warning\n error:%@", error);
            return;
        }
        
        //  将json写入文件，并进行zip压缩
        NSString *filePath = [SSJDocumentPath() stringByAppendingPathComponent:kSyncFileName];
        NSString *zipPath = [SSJDocumentPath() stringByAppendingPathComponent:kSyncZipFileName];
        
        if (![syncData writeToFile:filePath atomically:YES]) {
            return;
        }
        
        if (![SSZipArchive createZipFileAtPath:zipPath withContentsOfDirectory:filePath]) {
            return;
        }
        
        //  读取压缩好的文件，上传到服务端
        NSData *zipData = [NSData dataWithContentsOfFile:zipPath options:NSDataReadingMappedIfSafe error:&error];
        if (error) {
            SSJPRINT(@">>>SSJ warning\n error:%@", error);
            return;
        }
        
        AFHTTPSessionManager *session = [[AFHTTPSessionManager alloc] init];
        self.task = [session POST:@"" parameters:@{} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            [formData appendPartWithFileData:zipData name:@"zip" fileName:kSyncZipFileName mimeType:@"application/zip"];
            
        } success:^(NSURLSessionDataTask *task, id responseObject) {
            
            //  因为请求回调是在主线程队列中执行，所以在放到同步队列里执行以下操作
            dispatch_async(self.syncQueue, ^{
                //  上传成功后，将数据解压，并解析json数据
                if (![responseObject isKindOfClass:[NSData class]]) {
                    SSJPRINT(@">>>SSJ warning:responseObject is not NSData type");
                    return;
                }
                
                if (![responseObject writeToFile:zipPath atomically:YES]) {
                    SSJPRINT(@">>>SSJ warning:an error occured when write to file");
                    return;
                }
                
                if (![SSZipArchive unzipFileAtPath:zipPath toDestination:filePath]) {
                    SSJPRINT(@">>>SSJ warning:an error occured when unzip file");
                    return;
                }
                
                NSError *error = nil;
                NSData *jsonData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
                
                if (error) {
                    SSJPRINT(@">>>SSJ warning\n error:%@", error);
                    return;
                }
                
                NSDictionary *tableInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
                if (error) {
                    SSJPRINT(@">>>SSJ warning\n error:%@", error);
                    return;
                }
                
                int syncSuccessVersion;
                __block BOOL shouldInsertNewSyncVersion = YES;
                
                //  开启一个事务，将版本号（IVERSION）大于当前同步版本（currentSyncVersion）的记录的版本号改成服务端返回的版本号＋1（syncSuccessVersion + 1），保证所有在同步过程中修改的数据可以在下一次同步中提交到服务器
                [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
                    if (![SSJUserBillSyncTable updateSyncVersionToServerSyncVersion:syncSuccessVersion inDatabase:db]
                        || ![SSJFundInfoSyncTable updateSyncVersionToServerSyncVersion:syncSuccessVersion inDatabase:db]
                        || ![SSJUserChargeSyncTable updateSyncVersionToServerSyncVersion:syncSuccessVersion inDatabase:db]) {
                        
                        *rollback = YES;
                        shouldInsertNewSyncVersion = NO;
                    }
                }];
                
                //  合并数据，合并顺序：1.收支类型 2.资金帐户 3.记账流水
                [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
                    if (![SSJUserBillSyncTable mergeRecords:tableInfo[@"BK_USER_BILL"] inDatabase:db]
                        || ![SSJFundInfoSyncTable mergeRecords:tableInfo[@"BK_FUND_INFO"] inDatabase:db]
                        || ![SSJUserChargeSyncTable mergeRecords:tableInfo[@"BK_USER_CHARGE"] inDatabase:db]) {
                        
                        *rollback = YES;
                        shouldInsertNewSyncVersion = NO;
                        return;
                    }
                    
                    //  根据流水表计算资金帐户余额
                    if (![SSJFundAccountTable updateBalanceInDatabase:db]) {
                        *rollback = YES;
                        shouldInsertNewSyncVersion = NO;
                    }
                }];
                
                if (shouldInsertNewSyncVersion) {
                    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
                        if (![db executeUpdate:@"insert into BK_SYNC (VERSION, TYPE, CUSERID) values(?, 0, ?)", @(syncSuccessVersion), SSJUSERID()]) {
                            SSJPRINT(@">>>SSJ warning\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
                        }
                    }];
                }
            });
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    });
}

@end
