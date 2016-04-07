//
//  SSJMagicExportCalendarDateView.h
//  SuiShouJi
//
//  Created by old lang on 16/4/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSJMagicExportCalendarViewCellItem;

@interface SSJMagicExportCalendarDateView : UIView

@property (nonatomic, strong) SSJMagicExportCalendarViewCellItem *item;

@property (nonatomic, copy) void (^clickBlcok)(SSJMagicExportCalendarDateView *);

- (void)update;

@end
