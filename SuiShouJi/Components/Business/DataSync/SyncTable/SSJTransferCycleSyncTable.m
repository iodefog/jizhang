//
//  SSJTransferCycleSyncTable.m
//  SuiShouJi
//
//  Created by old lang on 17/2/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJTransferCycleSyncTable.h"

@implementation SSJTransferCycleSyncTable

+ (NSString *)tableName {
    return @"bk_transfer_cycle";
}

+ (NSArray *)columns {
    return @[@"icycleid",
             @"cuserid",
             @"ctransferinaccountid",
             @"ctransferoutaccountid",
             @"imoney",
             @"cmemo",
             @"icycletype",
             @"cbegindate",
             @"cenddate",
             @"istate",
             @"clientadddate",
             @"cwritedate",
             @"iversion",
             @"operatortype"];
}

+ (NSArray *)primaryKeys {
    return @[@"icycleid"];
}

+ (BOOL)subjectToDeletion {
    return NO;
}

@end
