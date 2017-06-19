//
//  SSJBookkeepingTreeHelpCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/4/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"
#import "SSJBookkeepingTreeHelper.h"

@interface SSJBookkeepingTreeHelpCellItem : SSJBaseCellItem

@property (nonatomic, copy, readonly) NSString *imageName;

@property (nonatomic, copy, readonly) NSString *treeLevelName;

@property (nonatomic, copy, readonly) NSString *treeLevelDays;

@property (nonatomic, readonly) SSJBookkeepingTreeLevel level;

+ (instancetype)itemWithTreeLevel:(SSJBookkeepingTreeLevel)level;

@end
