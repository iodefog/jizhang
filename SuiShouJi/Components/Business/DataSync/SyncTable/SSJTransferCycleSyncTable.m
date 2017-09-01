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

+ (NSSet *)columns {
    return [NSSet setWithObjects:
            @"icycleid",
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
            @"operatortype",
            nil];
}

+ (NSSet *)primaryKeys {
    return [NSSet setWithObject:@"icycleid"];
}

- (instancetype)init {
    if (self = [super init]) {
        self.subjectToDeletion = NO;
    }
    return self;
}

@end
