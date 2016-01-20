//
//  SSJDataSyncHelper.m
//  SuiShouJi
//
//  Created by old lang on 16/1/20.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDataSyncHelper.h"

NSString *SSJSplicePrimaryKeyAndValue(NSArray *primaryKeys, NSDictionary *recordInfo) {
    NSMutableArray *conditions = [NSMutableArray arrayWithCapacity:primaryKeys.count];
    for (NSString *primaryKey in primaryKeys) {
        id value = recordInfo[primaryKey];
        if (!value) {
            SSJPRINT(@">>>SSJ warning: merge record lack of primary key '%@'\n record:%@", primaryKey, recordInfo);
            return nil;
        }
        
        if ([value isKindOfClass:[NSString class]]) {
            [conditions addObject:[NSString stringWithFormat:@"%@ = '%@'", primaryKey, value]];
        } else {
            [conditions addObject:[NSString stringWithFormat:@"%@ = %@", primaryKey, value]];
        }
    }
    return [conditions componentsJoinedByString:@" and "];
}
