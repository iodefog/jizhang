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
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
        self.selectedDay = day;
        self.selectedMonth = month;
        self.selectedYear = year;
        [self addSubview:self.calendarView];
        [self addSubview:self.titleView];
        [self addSubview:self.dateChangeView];
        [self sizeToFit];
    }
    return self;
}

-(void)layoutSubviews{
    self.titleView.leftTop = CGPointMake(0, 0);
    self.closeButton.left = 10;
    self.dateLabel.center = CGPointMake(self.dateChangeView.width / 2, self.dateChangeView.height / 2);
    self.plusButton.left = self.dateLabel.right + 10;
    self.minusButton.right = self.dateLabel.left - 10;
    self.plusButton.centerY = self.dateChangeView.height / 2;
    self.minusButton.centerY = self.dateChangeView.height / 2;
    self.closeButton.centerY = self.titleView.height / 2;
    self.titleLabel.center = CGPointMake(self.titleView.width / 2, self.titleView.height / 2);
    self.dateChangeView.top = self.titleView.bottom;
    self.calendarView.size = CGSizeMake(self.width, 270);
    self.calendarView.top = self.dateChangeView.bottom;
}

-(CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake([UIApplication sharedApplication].keyWindow.width, 360);
}

- (void)show {
    if (self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    self.top = keyWindow.height;
    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.3 target:self touchAction:@selector(dismiss) animation:^{
        self.bottom = keyWindow.height;
    } timeInterval:0.25 fininshed:NULL];
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [self.superview ssj_hideBackViewForView:self animation:^{
        self.top = keyWindow.bottom;
    } timeInterval:0.25 fininshed:^(BOOL complation) {
        if (_dismissBlock) {
            _dismissBlock();
        }
    }];
}


-(SSJCalendarView*)calendarView{
    if (!_calendarView) {
        NSString *dateStr = [NSString stringWithFormat:@"%04ld-%02ld-%02ld",self.selectedYear,self.selectedMonth,self.selectedDay];
        _calendarView = [[SSJCalendarView alloc]initWithFrame:CGRectMake(0, 0, self.width, 270)];
        _calendarView.calendar.backgroundColor = [UIColor clearColor];
        _calendarView.isSelectOnly = YES;
        _calendarView.selectedYear = self.selectedYear;
        _calendarView.selectedMonth = self.selectedMonth;
        _calendarView.year = self.selectedYear;
        _calendarView.month = self.selectedMonth;
        _calendarView.day = self.selectedDay;
        _calendarView.selectDateStr = dateStr;
    }
    return _calendarView;
}

-(UIView*)titleView{
    if (_titleView == nil) {
        _titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 45)];
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.text = @"选择日期";
        _titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        [_titleLabel sizeToFit];
        _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 23, 23)];
        [_closeButton setImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _closeButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor];
        [_closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_titleView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_titleView ssj_setBorderWidth:1];
        [_titleView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        [_titleView addSubview:_closeButton];
        [_titleView addSubview:_titleLabel];
    }
    return _titleView;
}

-(UIView *)dateChangeView{
    if (!_dateChangeView) {
        _dateChangeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 45)];
        [_dateChangeView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_dateChangeView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        _dateChangeView.backgroundColor = [UIColor clearColor];
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.text = [NSString stringWithFormat:@"%ld年%ld月",self.selectedYear,self.selectedMonth];
        _dateLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _dateLabel.font = [UIFont systemFontOfSize:18];
        [_dateLabel sizeToFit];
        _plusButton = [[UIButton alloc]init];
        _plusButton.frame = CGRectMake(0, 0, 20, 29);
        [_plusButton setImage:[[UIImage imageNamed:@"reportForms_right"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _plusButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor];
        [_plusButton addTarget:self action:@selector(plusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _plusButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_plusButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _minusButton = [[UIButton alloc]init];
        _minusButton.frame = CGRectMake(0, 0, 20, 28);
        [_minusButton setImage:[[UIImage imageNamed:@"reportForms_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _minusButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor];
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
    [self.calendarView reloadCalender];
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
    [self.calendarView reloadCalender];
}

-(void)closeButtonClicked:(UIButton*)button{
    [self dismiss];
}

-(void)getCurrentDate{
    NSDate *now = [NSDate date];
    _currentYear = now.year;
    _currentDay = now.day;
    _currentMonth = now.month;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
