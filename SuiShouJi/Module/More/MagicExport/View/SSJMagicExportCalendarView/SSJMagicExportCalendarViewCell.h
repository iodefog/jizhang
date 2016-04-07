//
//  SSJMagicExportCalendarViewCell.h
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@class SSJMagicExportCalendarViewCellItem;

@interface SSJMagicExportCalendarViewCell : SSJBaseTableViewCell

@property (nonatomic, strong) NSArray<SSJMagicExportCalendarViewCellItem *> *dateItems;

@end

NS_ASSUME_NONNULL_END