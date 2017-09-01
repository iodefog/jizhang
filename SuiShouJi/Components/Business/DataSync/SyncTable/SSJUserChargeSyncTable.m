//
//  SSJUserChargeSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserChargeSyncTable.h"

@interface SSJUserChargeSyncTable ()

@property (nonatomic, strong) NSMutableArray *quitBooks;

@end

@implementation SSJUserChargeSyncTable

+ (NSString *)tableName {
    return @"bk_user_charge";
}

+ (NSSet *)columns {
    return [NSSet setWithObjects:
            @"ichargeid",
            @"imoney",
            @"ibillid",
            @"ifunsid",
            @"ioldmoney",
            @"ibalance",
            @"cbilldate",
            @"cuserid",
            @"cimgurl",
            @"thumburl",
            @"cmemo",
            @"cbooksid",
            @"clientadddate",
            @"cwritedate",
            @"iversion",
            @"ichargetype",
            @"cid",
            @"operatortype",
            @"cdetaildate",
            nil];
}

+ (NSSet *)primaryKeys {
    return [NSSet setWithObject:@"ichargeid"];
}

- (instancetype)init {
    if (self = [super init]) {
        self.quitBooks = [NSMutableArray array];
    }
    return self;
}

- (BOOL)mergeRecords:(NSArray *)records
           forUserId:(NSString *)userId
          inDatabase:(FMDatabase *)db
               error:(NSError **)error {
    
    FMResultSet *rs = [db executeQuery:@"select cbooksid from bk_share_books_member where cmemberid = ? and istate != ?", userId, @(SSJShareBooksMemberStateNormal)];
    while ([rs next]) {
        [self.quitBooks addObject:[rs stringForColumn:@"cbooksid"]];
    }
    [rs close];
    
    return [super mergeRecords:records forUserId:userId inDatabase:db error:error];
}

- (BOOL)shouldMergeRecord:(NSDictionary *)record
                forUserId:(NSString *)userId
               inDatabase:(FMDatabase *)db
                    error:(NSError *__autoreleasing *)error {
    
    if ([record[@"ichargetype"] integerValue] > SSJChargeIdTypeFixedFinance) {
        return NO;
    }
    
    NSString *billId = record[@"ibillid"];
    NSString *fundId = record[@"ifunsid"];
    NSString *configId = record[@"cid"];  //  定期记账配置id可已为空（仅一次）
    SSJChargeIdType idtype = [record[@"ichargetype"] integerValue];
    if (!billId || !fundId) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"流水合并失败，服务端返回的ibillid或者fundId为nil"}];
        }
        return NO;
    }
    
    //  如果返回了定期配置id，就查询定期配置表中是否有这个id
    if (configId.length && idtype == SSJChargeIdTypeCircleConfig) {
        //  定期配置表中没有对应id的记录
        if (![db boolForQuery:@"select count(*) from bk_charge_period_config where iconfigid = ? and cuserid = ?", configId, userId]) {
            return NO;
        }
        
        NSInteger operatortype = [record[@"operatortype"] integerValue];
        if (operatortype != 2) {
            //  查询本地是否有相同configid和billdate的其它有效流水
            FMResultSet *resultSet = [db executeQuery:@"select ichargeid, operatortype, cwritedate from bk_user_charge where cbilldate = ? and cid = ? and ichargetype = ? and cuserid = ? and ichargeid <> ? and operatortype <> 2", record[@"cbilldate"], record[@"cid"], @(SSJChargeIdTypeCircleConfig) , userId, record[@"ichargeid"]];
            if (!resultSet) {
                return NO;
            }
            
            //  本地有相同configid和billdate的流水
            while ([resultSet next]) {
                //  本地记录修改时间晚于将要合并数据的修改时间，保留本地记录，忽略合并记录
                NSString *localDateStr = [resultSet stringForColumn:@"cwritedate"];
                NSDate *localDate = [NSDate dateWithString:localDateStr formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
                NSDate *mergeDate = [NSDate dateWithString:record[@"cwritedate"] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
                if ([mergeDate compare:localDate] == NSOrderedAscending) {
                    [resultSet close];
                    return NO;
                }
                
                //  合并数据的修改时间更晚，合并此记录，删除本地记录
                [db executeUpdate:@"update bk_user_charge set operatortype = 2 where ichargeid = ?", [resultSet stringForColumn:@"ichargeid"]];
            }
            
            [resultSet close];
        }
    }
    
    return YES;
}

- (BOOL)updateRecord:(NSDictionary *)record
           condition:(NSString *)condition
           forUserId:(NSString *)userId
          inDatabase:(FMDatabase *)db
               error:(NSError **)error {
    
    int chargeType = [record[@"ichargetype"] intValue];
    BOOL isBookQuitted = [self.quitBooks containsObject:record[@"cbooksid"]];
    BOOL isOtherMemberCharge = ![record[@"cuserid"] isEqualToString:userId];
    
    if (chargeType == SSJChargeIdTypeShareBooks && (isBookQuitted || isOtherMemberCharge)) {
        self.subjectToDeletion = NO;
    } else {
        self.subjectToDeletion = YES;
    }
    
    return [super updateRecord:record condition:condition forUserId:userId inDatabase:db error:error];
}

@end
