//
//  SSJBookkeepingTreeHelpCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/4/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

typedef NS_ENUM(NSInteger, SSJBookkeepingTreeLevel) {
    SSJBookkeepingTreeLevelSeed,            // 种子
    SSJBookkeepingTreeLevelSapling,         // 树苗
    SSJBookkeepingTreeLevelSmallTree,       // 小树
    SSJBookkeepingTreeLevelStrongTree,      // 壮树
    SSJBookkeepingTreeLevelBigTree,         // 大树
    SSJBookkeepingTreeLevelSilveryTree,     // 银树
    SSJBookkeepingTreeLevelGoldTree,        // 金树
    SSJBookkeepingTreeLevelDiamondTree,     // 钻石树
    SSJBookkeepingTreeLevelCrownTree        // 皇冠树
};

@interface SSJBookkeepingTreeHelpCellItem : SSJBaseItem

@property (nonatomic, copy, readonly) NSString *imageName;

@property (nonatomic, copy, readonly) NSString *treeLevelName;

@property (nonatomic, copy, readonly) NSString *treeLevelDays;

@property (nonatomic, readonly) SSJBookkeepingTreeLevel level;

+ (instancetype)itemWithTreeLevel:(SSJBookkeepingTreeLevel)level;

@end
