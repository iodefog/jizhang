//
//  SSJMagicExportCalendarViewCell.h
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@class SSJMagicExportCalendarDateView;
@class SSJMagicExportCalendarViewCell;
@class SSJMagicExportCalendarDateViewItem;

@interface SSJMagicExportCalendarViewCell : SSJBaseTableViewCell

@property (nonatomic, strong) NSArray<SSJMagicExportCalendarDateViewItem *> *dateItems;

@property (nonatomic, copy) void(^clickBlock)(SSJMagicExportCalendarViewCell *, SSJMagicExportCalendarDateView *);

@end

NS_ASSUME_NONNULL_END
