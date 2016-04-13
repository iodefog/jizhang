//
//  SSJBookkeepingTreeHelper.m
//  SuiShouJi
//
//  Created by old lang on 16/4/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookkeepingTreeHelper.h"

@implementation SSJBookkeepingTreeHelper

+ (NSString *)treeImageNameForDays:(NSInteger)days {
    if (days >= 0 && days <= 7) {
        return @"tree_level_1";
    } else if (days >= 8 && days <= 30) {
        return @"tree_level_2";
    } else if (days >= 31 && days <= 50) {
        return @"tree_level_3";
    } else if (days >= 51 && days <= 100) {
        return @"tree_level_4";
    } else if (days >= 101 && days <= 180) {
        return @"tree_level_5";
    } else if (days >= 181 && days <= 300) {
        return @"tree_level_6";
    } else if (days >= 301 && days <= 450) {
        return @"tree_level_7";
    } else if (days >= 451 && days <= 599) {
        return @"tree_level_8";
    } else if (days >= 600) {
        return @"tree_level_9";
    } else {
        return @"";
    }
}

+ (NSString *)treeLevelNameForDays:(NSInteger)days {
    if (days >= 0 && days <= 7) {
        return @"种子";
    } else if (days >= 8 && days <= 30) {
        return @"树苗";
    } else if (days >= 31 && days <= 50) {
        return @"小树";
    } else if (days >= 51 && days <= 100) {
        return @"壮树";
    } else if (days >= 101 && days <= 180) {
        return @"大树";
    } else if (days >= 181 && days <= 300) {
        return @"银树";
    } else if (days >= 301 && days <= 450) {
        return @"金树";
    } else if (days >= 451 && days <= 599) {
        return @"钻石树";
    } else if (days >= 600) {
        return @"皇冠树";
    } else {
        return @"";
    }
}

+ (NSString *)treeLevelDaysForDays:(NSInteger)days {
    if (days >= 0 && days <= 7) {
        return @"0-7";
    } else if (days >= 8 && days <= 30) {
        return @"8-30";
    } else if (days >= 31 && days <= 50) {
        return @"31-50";
    } else if (days >= 51 && days <= 100) {
        return @"51-100";
    } else if (days >= 101 && days <= 180) {
        return @"101-180";
    } else if (days >= 181 && days <= 300) {
        return @"181-300";
    } else if (days >= 301 && days <= 450) {
        return @"301-450";
    } else if (days >= 451 && days <= 599) {
        return @"451-599";
    } else if (days >= 600) {
        return @"600-inf";
    } else {
        return @"";
    }
}

@end
