    
//
//  SSJChargeCircleTimeSelectView.m
//  SuiShouJi
//
//  Created by ricky on 16/6/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJChargeCircleTimeSelectView.h"

@interface SSJChargeCircleTimeSelectView()
@property (nonatomic,strong) UIDatePicker *datePicker;
@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *closeButton;
@property (nonatomic,strong) UIButton *comfirmButton;
@end

@implementation SSJChargeCircleTimeSelectView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.needClearButtonOrNot = NO;
        [self addSubview:self.datePicker];
        [self addSubview:self.topView];
        [self sizeToFit];
    }
    return self;
}

-(CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake([UIApplication sharedApplication].keyWindow.width, self.datePicker.height + 50);
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
    self.datePicker.bottom = self.height;
    self.topView.size = CGSizeMake(self.width, 50);
    self.topView.leftTop = CGPointMake(0, self.datePicker.top);
    self.titleLabel.center = CGPointMake(self.topView.width / 2, self.topView.height / 2);
    self.closeButton.centerY = self.topView.height / 2;
    self.closeButton.left = 10;
    self.comfirmButton.centerY = self.topView.height / 2;
    self.comfirmButton.right = self.width - 10;
}

-(UIDatePicker *)datePicker{
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0, self.width, 300)];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        _datePicker.backgroundColor = [UIColor whiteColor];
    }
    return _datePicker;
}

-(UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc]init];
        _topView.backgroundColor = [UIColor whiteColor];
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"选择日期";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        [_topView ssj_setBorderColor:[UIColor ssj_colorWithHex:@"cccccc"]];
        [_topView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_topView ssj_setBorderWidth:1];
        [_titleLabel sizeToFit];
        [_topView addSubview:_titleLabel];
        _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
        [_closeButton setTitleColor:[UIColor ssj_colorWithHex:@"#EE4F4F"] forState:UIControlStateNormal];
        _closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
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


-(void)closeButtonClicked:(id)sender{
    if (_needClearButtonOrNot) {
        if (self.clearButtonClickBlcok) {
            self.clearButtonClickBlcok();
        }
    }
    [self dismiss];
}

-(void)comfirmButtonClicked:(id)sender{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString* dateStr = [dateFormatter stringFromDate:[self.datePicker date]];
    if (self.maxDate) {
        if ([self.datePicker.date isLaterThan:self.maxDate]) {
            [self.datePicker setDate:self.maxDate animated:YES];
            if (self.timeIsTooLateBlock) {
                self.timeIsTooLateBlock();
            }
            return;
        }
    }
    if (self.minimumDate) {
        if ([self.datePicker.date isEarlierThan:self.minimumDate]) {
            [self.datePicker setDate:self.minimumDate animated:YES];
            if (self.timeIsTooEarlyBlock) {
                self.timeIsTooEarlyBlock();
            }
            return;
        }
    }
    if (self.timerSetBlock) {
        self.timerSetBlock(dateStr);
    }
    [self dismiss];
}

- (void)setMaxDate:(NSDate *)maxDate{
    _maxDate = maxDate;
}

- (void)setMinimumDate:(NSDate *)minimumDate{
    _minimumDate = minimumDate;
}

- (void)setNeedClearButtonOrNot:(BOOL)needClearButtonOrNot{
    _needClearButtonOrNot = needClearButtonOrNot;
    if (!_needClearButtonOrNot) {
        [self.closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [self.closeButton setTitle:@"" forState:UIControlStateNormal];
        self.closeButton.size = CGSizeMake(35, 35);
    }else{
        [self.closeButton setImage:nil forState:UIControlStateNormal];
        [self.closeButton setTitle:@"清空" forState:UIControlStateNormal];
        self.closeButton.size = CGSizeMake(100, 35);
    }
}

-(void)setCurrentDate:(NSDate *)currentDate{
    _currentDate = currentDate;
    self.datePicker.date = _currentDate;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
