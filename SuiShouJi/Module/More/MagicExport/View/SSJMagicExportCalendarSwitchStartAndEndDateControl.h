//
//  SSJMagicExportCalendarSwitchStartAndEndDateControl.h
//  SuiShouJi
//
//  Created by old lang on 16/5/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJMagicExportCalendarSwitchStartAndEndDateControl : UIView

@property (nonatomic, strong) NSDate *beginDate;

@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, copy) void(^clickBeginDateAction)();

@property (nonatomic, copy) void(^clickEndDateAction)();

@end
