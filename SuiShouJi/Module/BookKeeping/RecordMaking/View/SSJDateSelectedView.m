//
//  dateSelectedView.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/22.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJDateSelectedView.h"
#import "SSJCalendarView.h"

@interface SSJDateSelectedView()
@property (nonatomic,strong) SSJCalendarView *calendarView;
@end
@implementation SSJDateSelectedView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        [self addSubview:self.calendarView];
    }
    return self;
}

-(void)layoutSubviews{
    self.calendarView.frame = CGRectMake(0, 0, self.width, 270);
    self.calendarView.bottom = self.height;
}

-(SSJCalendarView*)calendarView{
    if (!_calendarView) {
        _calendarView = [[SSJCalendarView alloc]initWithFrame:CGRectMake(0, 0, self.width, 270)];
        _calendarView.currentDate = [NSDate date];
    }
    return _calendarView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
