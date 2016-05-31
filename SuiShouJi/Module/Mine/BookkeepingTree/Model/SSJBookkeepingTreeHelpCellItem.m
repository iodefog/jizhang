//
//  SSJBookkeepingTreeHelpCellItem.m
//  SuiShouJi
//
//  Created by old lang on 16/4/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookkeepingTreeHelpCellItem.h"
#import "SSJBookkeepingTreeHelper.h"

@interface SSJBookkeepingTreeHelpCellItem ()

@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, copy) NSString *treeLevelName;

@property (nonatomic, copy) NSString *treeLevelDays;

@property (nonatomic) SSJBookkeepingTreeLevel level;

@end

@implementation SSJBookkeepingTreeHelpCellItem

+ (instancetype)itemWithImageName:(NSString *)imageName levelName:(NSString *)levelName levelDays:(NSString *)levelDays {
    SSJBookkeepingTreeHelpCellItem *item = [[SSJBookkeepingTreeHelpCellItem alloc] init];
    item.imageName = imageName;
    item.treeLevelName = levelName;
    item.treeLevelDays = levelDays;
    return item;
}

+ (instancetype)itemWithTreeLevel:(SSJBookkeepingTreeLevel)level {
    SSJBookkeepingTreeHelpCellItem *item = [[SSJBookkeepingTreeHelpCellItem alloc] init];
    item.level = level;
    item.imageName = [self treeImageNameForLevel:level];
    item.treeLevelName = [SSJBookkeepingTreeHelper treeLevelNameForLevel:level];
    item.treeLevelDays = [self treeLevelDaysForLevel:level];
    return item;
}

+ (NSString *)treeImageNameForLevel:(SSJBookkeepingTreeLevel)level {
    switch (level) {
        case SSJBookkeepingTreeLevelSeed:           return @"help_tree_level_1";
        case SSJBookkeepingTreeLevelSapling:        return @"help_tree_level_2";
        case SSJBookkeepingTreeLevelSmallTree:      return @"help_tree_level_3";
        case SSJBookkeepingTreeLevelStrongTree:     return @"help_tree_level_4";
        case SSJBookkeepingTreeLevelBigTree:        return @"help_tree_level_5";
        case SSJBookkeepingTreeLevelSilveryTree:    return @"help_tree_level_6";
        case SSJBookkeepingTreeLevelGoldTree:       return @"help_tree_level_7";
        case SSJBookkeepingTreeLevelDiamondTree:    return @"help_tree_level_8";
        case SSJBookkeepingTreeLevelCrownTree:      return @"help_tree_level_9";
    }
}

+ (NSString *)treeLevelDaysForLevel:(SSJBookkeepingTreeLevel)level {
    switch (level) {
        case SSJBookkeepingTreeLevelSeed:           return @"0-7天";
        case SSJBookkeepingTreeLevelSapling:        return @"8-30天";
        case SSJBookkeepingTreeLevelSmallTree:      return @"31-50天";
        case SSJBookkeepingTreeLevelStrongTree:     return @"51-100天";
        case SSJBookkeepingTreeLevelBigTree:        return @"101-180天";
        case SSJBookkeepingTreeLevelSilveryTree:    return @"181-300天";
        case SSJBookkeepingTreeLevelGoldTree:       return @"301-450天";
        case SSJBookkeepingTreeLevelDiamondTree:    return @"451-599天";
        case SSJBookkeepingTreeLevelCrownTree:      return @"600天以上";
    }
}

@end
