//
//  SSJDataSync.m
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDataSync.h"
#import "SSJUserChargeModel.h"
#import "SSJFundInfoModel.h"
#import "SSJBillTypeModel.h"
#import "SSJDatabaseQueue.h"
#import "MJExtension.h"
#import "SSZipArchive.h"
#import "AFNetworking.h"

#import <objc/runtime.h>

static NSString *const kSyncFileName = @"sync_json.text";
static NSString *const kSyncZipFileName = @"sync_json.zip";

@interface SSJDataSync ()

@property (nonatomic, weak) NSURLSessionDataTask *task;
@property (nonatomic, strong) dispatch_queue_t syncQueue;

@end

@implementation SSJDataSync

+ (instancetype)shareInstance {
    static SSJDataSync *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[SSJDataSync alloc] init];
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
        [self startSyncData];
    }
}

- (void)startSyncData {
    dispatch_async(self.syncQueue, ^{
        
        __block NSInteger lastSyncVersion;
        __block NSInteger currentSyncVersion;
        
        __block NSArray *userChargeRecords = nil;
        __block NSArray *fundInfoRecords = nil;
        __block NSArray *billTypeRecords = nil;
        
        [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
            
            //  获取上次同步成功的版本号
            lastSyncVersion = [self queryLastSyncVersionInDatabase:db];
            if (lastSyncVersion == NSIntegerMin) {
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
            userChargeRecords = [self executeQuery:[NSString stringWithFormat:@"select * from BK_USER_CHARGE where IVERSION > %@", @(lastSyncVersion)] inDatabase:db modelCalss:[SSJUserChargeModel class]];
            
            fundInfoRecords = [self executeQuery:[NSString stringWithFormat:@"select * from BK_FUND_INFO where IVERSION > %@ and CPARENT <> 'root'", @(lastSyncVersion)] inDatabase:db modelCalss:[SSJFundInfoModel class]];
            
            billTypeRecords = [self executeQuery:[NSString stringWithFormat:@"select * from BK_USER_BILL where IVERSION > %@", @(lastSyncVersion)] inDatabase:db modelCalss:[SSJBillTypeModel class]];
            
        }];
        
        //  将查询得到的结果放入字典中，转换成json数据
        NSMutableDictionary *syncTable = [NSMutableDictionary dictionaryWithCapacity:3];
        [syncTable setObject:[SSJUserChargeModel mj_keyValuesArrayWithObjectArray:userChargeRecords] forKey:@"BK_USER_CHARGE"];
        [syncTable setObject:[SSJFundInfoModel mj_keyValuesArrayWithObjectArray:fundInfoRecords] forKey:@"BK_FUND_INFO"];
        [syncTable setObject:[SSJBillTypeModel mj_keyValuesArrayWithObjectArray:billTypeRecords] forKey:@"BK_USER_BILL"];
        
        NSError *error = nil;
        NSData *syncData = [NSJSONSerialization dataWithJSONObject:syncTable options:NSJSONWritingPrettyPrinted error:&error];
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
                
                NSInteger syncSuccessVersion;
                
                //  开启一个事务，将版本号（IVERSION）大于当前同步版本（currentSyncVersion）的记录的版本号改成同步成功的版本号＋1（syncSuccessVersion + 1），保证所有在同步过程中修改的数据可以在下一次同步中提交到服务器
                [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
                    if (![db executeUpdate:@"update BK_USER_CHARGE set IVERSION = ? where IVERSION > ?", @(syncSuccessVersion + 1), @(currentSyncVersion)]
                        || ![db executeUpdate:@"update BK_FUND_INFO set IVERSION = ? where IVERSION > ? and CPARENT <> 'root'", @(syncSuccessVersion + 1), @(currentSyncVersion)]
                        || ![db executeUpdate:@"update BK_USER_BILL set IVERSION = ? where IVERSION > ?", @(syncSuccessVersion + 1), @(currentSyncVersion)]
                        || ![db executeUpdate:@"insert into BK_SYNC (VERSION, TYPE) values(?, 0)", @(syncSuccessVersion)]) {
                        
                        SSJPRINT(@">>>SSJ warning\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
                        *rollback = YES;
                        return;
                    }
                }];
                
                //  合并数据，合并顺序：1.收支类型 2.资金帐户 3.记账流水
                [[SSJDatabaseQueue sharedInstance] asyncInTransaction:^(FMDatabase *db, BOOL *rollback) {
                    NSArray *billTypeRecords = tableInfo[@"BK_USER_BILL"];
                    NSArray *billTypeModels = [SSJBillTypeModel mj_objectArrayWithKeyValuesArray:billTypeRecords];
                    [self mergeTable:@"BK_USER_BILL" records:billTypeModels inDatabase:db];
                    
                    NSArray *fundInfoRecords = tableInfo[@"BK_FUND_INFO"];
                    NSArray *fundInfoModels = [SSJFundInfoModel mj_objectArrayWithKeyValuesArray:fundInfoRecords];
                    [self mergeTable:@"BK_FUND_INFO" records:fundInfoModels inDatabase:db];
                    
                    NSArray *userChargeRecords = tableInfo[@"BK_USER_CHARGE"];
                    NSArray *userChargeModels = [SSJBillTypeModel mj_objectArrayWithKeyValuesArray:userChargeRecords];
                    [self mergeTable:@"BK_USER_CHARGE" records:userChargeModels inDatabase:db];
                }];
            });
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    });
}

//  查询同步表，去最后一条同步成功的版本号
- (NSInteger)queryLastSyncVersionInDatabase:(FMDatabase *)db {
    FMResultSet *lastSyncResultSet = [db executeQuery:@"select VERSION from (select * from BK_SYNC where TYPE = 1) limit 1 offset (select count(*) from BK_SYNC where TYPE = 1)"];
    
    if (!lastSyncResultSet) {
        SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
        return NSIntegerMin;
    }
    
    int lastSyncVersion = 0;
    
    while ([lastSyncResultSet next]) {
        lastSyncVersion = [lastSyncResultSet intForColumnIndex:0];
    }
    return lastSyncVersion;
}

- (NSArray *)executeQuery:(NSString *)query inDatabase:(FMDatabase *)db modelCalss:(Class)class {
    if (!query || !class) {
        return nil;
    }
    
    FMResultSet *userChargeResult = [db executeQuery:query];
    
    if (!userChargeResult) {
        SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
        return nil;
    }
    
    NSMutableArray *syncRecords = [NSMutableArray array];
    while ([userChargeResult next]) {
        SSJDataSyncModel *userChargeModel = [class modelWithResultSet:userChargeResult];
        [syncRecords addObject:userChargeModel];
    }
    return syncRecords;
}

//  根据表名、记录动态合并
- (void)mergeTable:(NSString *)tableName records:(NSArray *)records inDatabase:(FMDatabase *)db {
    for (SSJDataSyncModel *model in records) {
        if (![model isKindOfClass:[SSJDataSyncModel class]]) {
            SSJPRINT(@">>>SSJ warning: model is not subclass of SSJDataSyncModel\n model:%@", model);
            continue;
        }
        
        //
        if (![model.CUSERID isEqualToString:SSJUSERID()]) {
            return;
        }
        
        if ([model isKindOfClass:[SSJUserChargeModel class]]) {
            SSJUserChargeModel *userChargeModel = (SSJUserChargeModel *)model;
            if (![userChargeModel.CUSERID isEqualToString:SSJUSERID()]) {
                return;
            }
            
            FMResultSet *result = [db executeQuery:@"select count(*) from BK_FUND_INFO where CFUNDID = ?", userChargeModel.IFID];
            if (!result) {
                SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
                return;
            }
            
            [result next];
            if ([result intForColumnIndex:0] <= 0) {
                return;
            }
            
            result = [db executeQuery:@"select count(*) from BK_USER_BILL where CBILLID = ?", userChargeModel.IBILLID];
            if (!result) {
                SSJPRINT(@">>>SSJ warning:\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
                return;
            }
            
            [result next];
            if ([result intForColumnIndex:0] <= 0) {
                return;
            }
        }
        
        //  动态设置set子句
        NSMutableString *set = [NSMutableString stringWithString:@"set"];
        NSArray *properties = [[model class] getAllProperties];
        NSMutableArray *propertyKeyValues = [NSMutableArray arrayWithCapacity:properties.count];
        for (NSString *property in properties) {
            [propertyKeyValues addObject:[NSString stringWithFormat:@" %@ = %@", property, [model valueForKey:property]]];
        }
        [set appendString:[propertyKeyValues componentsJoinedByString:@","]];
        
        //  动态设置条件子句
        NSMutableString *condition = [NSMutableString stringWithString:@"where"];
        NSArray *primaryKeys = [[model class] primaryKeys];
        if (primaryKeys.count == 0) {
            SSJPRINT(@">>>SSJ warning: %@未返回主键", NSStringFromClass([model class]));
            return;
        }
        NSMutableArray *primaryKeyValues = [NSMutableArray arrayWithCapacity:primaryKeys.count];
        for (NSString *key in primaryKeys) {
            [primaryKeyValues addObject:[NSString stringWithFormat:@" %@ = %@ ", key, [model valueForKey:key]]];
        }
        [condition appendString:[primaryKeyValues componentsJoinedByString:@"and"]];
        [condition appendFormat:@"and CWRITEDATE < %@", model.CWRITEDATE];
        
        if (![db executeUpdate:[NSString stringWithFormat:@"update %@ %@ %@", tableName, set, condition]]) {
            SSJPRINT(@">>>SSJ warning\n message:%@\n error:%@", [db lastErrorMessage], [db lastError]);
            return;
        }
    }
}

@end
