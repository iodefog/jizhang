//
//  SSJReminderDateSelectView.m
//  SuiShouJi
//
//  Created by ricky on 16/8/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReminderDateSelectView.h"
#import "SSJReminderWeekDaySelectView.h"

@interface SSJReminderDateSelectView()

@property(nonatomic, strong) UIDatePicker *dateSelect;

@property (nonatomic,strong) UIView *topView;

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) UIButton *closeButton;

@property (nonatomic,strong) UIButton *comfirmButton;

@property(nonatomic, strong) SSJReminderWeekDaySelectView *weekView;

@end

@implementation SSJReminderDateSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.dateSelect];
        [self addSubview:self.topView];
        [self addSubview:self.weekView];
        [self sizeToFit];
    }
    return self;
}

-(CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake([UIApplication sharedApplication].keyWindow.width, self.dateSelect.height + 90);
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
    } timeInterval:0.25 fininshed:NULL];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.dateSelect.bottom = self.height;
    self.topView.size = CGSizeMake(self.width, 50);
    self.topView.leftTop = CGPointMake(0, 0);
    self.titleLabel.center = CGPointMake(self.topView.width / 2, self.topView.height / 2);
    self.closeButton.centerY = self.topView.height / 2;
    self.closeButton.left = 10;
    self.comfirmButton.centerY = self.topView.height / 2;
    self.comfirmButton.right = self.width - 10;
    self.weekView.top = self.topView.bottom;
    self.weekView.centerX = self.width / 2;
}


-(UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc]init];
        _topView.backgroundColor = [UIColor whiteColor];
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"选择日期";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        [_topView ssj_setBorderColor:[UIColor ssj_colorWithHex:@"cccccc"]];
        [_topView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_topView ssj_setBorderWidth:1];
        [_titleLabel sizeToFit];
        [_topView addSubview:_titleLabel];
        _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
        [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:_closeButton];
        _comfirmButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
        [_comfirmButton setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
        [_comfirmButton addTarget:self action:@selector(comfirmButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:_comfirmButton];
    }
    return _topView;
}

-(UIDatePicker *)dateSelect{
    if (!_dateSelect) {
        _dateSelect = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0, self.width, 380)];
        _dateSelect.datePickerMode = UIDatePickerModeDate;
        _dateSelect.minimumDate = [NSDate date];
        _dateSelect.backgroundColor = [UIColor whiteColor];
    }
    return _dateSelect;
}

-(SSJReminderWeekDaySelectView *)weekView{
    if (!_weekView) {
        _weekView = [[SSJReminderWeekDaySelectView alloc]initWithFrame:CGRectMake(0, 0, self.width, 40)];
        _weekView.backgroundColor = [UIColor whiteColor];
    }
    return _weekView;
}

-(void)comfirmButtonClicked:(id)sender{
    if (self.dateSetBlock) {
        self.dateSetBlock([self.dateSelect date]);
    }
    [self dismiss];
}

-(void)closeButtonClicked:(id)sender{
    [self dismiss];
}

-(void)setCurrentDate:(NSDate *)currentDate{
    _currentDate = currentDate;
    self.dateSelect.date = _currentDate;
    self.weekView.currentDate = _currentDate;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
