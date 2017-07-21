//
//  dateSelectedView.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/22.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJCalendarView.h"

SSJ_DEPRECATED
@interface SSJDateSelectedView : UIView
@property (nonatomic) long selectedYear;
@property (nonatomic) long selectedMonth;
@property (nonatomic) long selectedDay;
@property (nonatomic,strong) SSJCalendarView *calendarView;



@property (nonatomic, copy) void(^dismissBlock)();

- (instancetype)initWithFrame:(CGRect)frame forYear:(long)year Month:(long)month Day:(long)day;

- (void)show;

- (void)dismiss;

@end
