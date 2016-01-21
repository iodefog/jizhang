//
//  dateSelectedView.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/22.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJDateSelectedView.h"
#import "SSJCalendarCollectionViewCell.h"

@interface SSJDateSelectedView()
@property (nonatomic,strong) UIView *titleView;
@property (nonatomic,strong) UIView *dateChangeView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *closeButton;
@property (nonatomic,strong) UILabel *dateLabel;
@property (nonatomic,strong) UIButton *plusButton;
@property (nonatomic,strong) UIButton *minusButton;
@end
@implementation SSJDateSelectedView{
    long _currentYear;
    long _currentMonth;
    long _currentDay;
    
}
- (instancetype)initWithFrame:(CGRect)frame forYear:(long)year Month:(long)month Day:(long)day
{
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedDay = day;
        self.selectedMonth = month;
        self.selectedYear = year;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        [self addSubview:self.calendarView];
        [self addSubview:self.titleView];
        [self addSubview:self.dateChangeView];
    }
    return self;
}

-(void)layoutSubviews{
    self.calendarView.frame = CGRectMake(0, 0, self.width, 270);
    self.calendarView.bottom = self.height;
    self.dateChangeView.bottom = self.calendarView.top;
    self.dateLabel.center = CGPointMake(self.dateChangeView.width / 2, self.dateChangeView.height / 2);
    self.titleView.bottom = self.dateChangeView.top;
    self.closeButton.left = 10;
    self.plusButton.left = self.dateLabel.right + 10;
    self.minusButton.right = self.dateLabel.left - 10;
    self.plusButton.centerY = self.dateChangeView.height / 2;
    self.minusButton.centerY = self.dateChangeView.height / 2;
    self.closeButton.centerY = self.titleView.height / 2;
    self.titleLabel.center = CGPointMake(self.titleView.width / 2, self.titleView.height / 2);
}

-(SSJCalendarView*)calendarView{
    if (!_calendarView) {
        _calendarView = [[SSJCalendarView alloc]initWithFrame:CGRectMake(0, 0, self.width, 270)];
        _calendarView.selectedYear = self.selectedYear;
        _calendarView.selectedMonth = self.selectedMonth;
        _calendarView.year = self.selectedYear;
        _calendarView.month = self.selectedMonth;
        _calendarView.day = self.selectedDay;
    }
    return _calendarView;
}

-(UIView*)titleView{
    if (_titleView == nil) {
        _titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 45)];
        _titleView.backgroundColor = [UIColor whiteColor];
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.text = @"选择日期";
        _titleLabel.font = [UIFont systemFontOfSize:18];
        [_titleLabel sizeToFit];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 23, 23)];
        [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_titleView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_titleView ssj_setBorderWidth:1];
        [_titleView ssj_setBorderColor:[UIColor ssj_colorWithHex:@"cccccc"]];
        [_titleView addSubview:_closeButton];
        [_titleView addSubview:_titleLabel];
    }
    return _titleView;
}

-(UIView *)dateChangeView{
    if (!_dateChangeView) {
        _dateChangeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 45)];
        [_dateChangeView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_dateChangeView ssj_setBorderColor:[UIColor ssj_colorWithHex:@"e8e8e8"]];
        _dateChangeView.backgroundColor = [UIColor whiteColor];
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.text = [NSString stringWithFormat:@"%ld年%ld月",self.selectedYear,self.selectedMonth];
        _dateLabel.font = [UIFont systemFontOfSize:18];
        [_dateLabel sizeToFit];
        _plusButton = [[UIButton alloc]init];
        _plusButton.frame = CGRectMake(0, 0, 20, 29);
        [_plusButton setImage:[UIImage imageNamed:@"reportForms_right"] forState:UIControlStateNormal];
        [_plusButton addTarget:self action:@selector(plusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _plusButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_plusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _minusButton = [[UIButton alloc]init];
        _minusButton.frame = CGRectMake(0, 0, 20, 28);
        [_minusButton setImage:[UIImage imageNamed:@"reportForms_left"] forState:UIControlStateNormal];
        [_minusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _minusButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_minusButton addTarget:self action:@selector(minusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_dateChangeView addSubview:_dateLabel];
        [_dateChangeView addSubview:_plusButton];
        [_dateChangeView addSubview:_minusButton];
    }
    return _dateChangeView;
}

-(void)plusButtonClicked:(UIButton*)button{
    self.selectedMonth = self.selectedMonth + 1;
    if (self.selectedMonth == 13) {
        self.selectedMonth = 1;
        self.selectedYear = self.selectedYear + 1;
    }
    self.dateLabel.text = [NSString stringWithFormat:@"%ld年%ld月",self.selectedYear,self.selectedMonth];
    [self.dateLabel  sizeToFit];
    self.calendarView.year = self.selectedYear;
    self.calendarView.month = self.selectedMonth;
    [self.calendarView.calendar reloadData];
}

-(void)minusButtonClicked:(UIButton*)button{
    self.selectedMonth = self.selectedMonth - 1;
    if (self.selectedMonth == 0) {
        self.selectedMonth = 12;
        self.selectedYear = self.selectedYear - 1;
    }
    self.dateLabel.text = [NSString stringWithFormat:@"%ld年%ld月",self.selectedYear,self.selectedMonth];
    [self.dateLabel  sizeToFit];
    self.calendarView.year = self.selectedYear;
    self.calendarView.month = self.selectedMonth;
    [self.calendarView.calendar reloadData];
}

-(void)closeButtonClicked:(UIButton*)button{
    for (int i = 0; i < [self.calendarView.calendar.visibleCells count]; i ++) {
        if ([((SSJCalendarCollectionViewCell*)[self.calendarView.calendar.visibleCells objectAtIndex:i]).currentDay integerValue] == _currentDay && ((SSJCalendarCollectionViewCell*)[self.calendarView.calendar.visibleCells objectAtIndex:i]).selectable == YES) {
            ((SSJCalendarCollectionViewCell*)[self.calendarView.calendar.visibleCells objectAtIndex:i]).isSelected = YES;
        }else if([((SSJCalendarCollectionViewCell*)[self.calendarView.calendar.visibleCells objectAtIndex:i]).currentDay integerValue] == self.selectedDay && self.calendarView.month == self.selectedMonth &&self.calendarView.year == self.selectedYear && ((SSJCalendarCollectionViewCell*)[self.calendarView.calendar.visibleCells objectAtIndex:i]).selectable == YES){
            ((SSJCalendarCollectionViewCell*)[self.calendarView.calendar.visibleCells objectAtIndex:i]).isSelected = YES;
        }else{
            ((SSJCalendarCollectionViewCell*)[self.calendarView.calendar.visibleCells objectAtIndex:i]).isSelected = NO;
        }
    }
    [self removeFromSuperview];
}

-(void)getCurrentDate{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    _currentYear = [dateComponent year];
    _currentDay = [dateComponent day];
    _currentMonth = [dateComponent month];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
