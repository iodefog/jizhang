//
//  SSJMemberChargeSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 16/7/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMemberChargeSyncTable.h"

@implementation SSJMemberChargeSyncTable

+ (NSString *)tableName {
    return @"bk_member_charge";
}

+ (NSArray *)columns {
    return @[@"ichargeid", @"cmemberid", @"imoney", @"cwritedate", @"operatortype", @"iversion"];
}

+ (BOOL)mergeRecords:(NSArray *)records forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
    NSMutableArray *chargeIds = [NSMutableArray array];
    for (NSDictionary *recordInfo in records) {
        NSString *chargeId = recordInfo[@"ichargeid"];
        if (!chargeId) {
            continue;
        }
        if (![chargeIds containsObject:chargeId]) {
            [chargeIds addObject:chargeId];
        }
    }
    
    NSString *chargeIdStr = [chargeIds componentsJoinedByString:@","];
    
    if (![db executeUpdate:@"delete from bk_member_charge where ichargeid in (?)", chargeIdStr]) {
        return NO;
    }
    
    for (NSDictionary *recordInfo in records) {
//        [db executeUpdate:@"insert into bk_member_charge ()"]
    }
    return YES;
}


//+ (BOOL)shouldMergeRecord:(NSDictionary *)record forUserId:(NSString *)userId inDatabase:(FMDatabase *)db error:(NSError **)error {
//    
//    if (![db boolForQuery:@"select count(*) from bk_user_charge where ichargeid = ?", record[@"ichargeid"]]) {
//        return NO;
//    }
//    
//    if (![db boolForQuery:@"select count(*) from bk_member where cmemberid = ?", record[@"cmemberid"]]) {
//        return NO;
//    }
//    
//    if (<#condition#>) {
//        <#statements#>
//    }
//}

@end
