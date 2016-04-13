//
//  SSJBookkeepingTreeHelper.h
//  SuiShouJi
//
//  Created by old lang on 16/4/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJBookkeepingTreeHelper : NSObject

+ (NSString *)treeImageNameForDays:(NSInteger)days;

+ (NSString *)treeLevelNameForDays:(NSInteger)days;

+ (NSString *)treeLevelDaysForDays:(NSInteger)days;

@end
