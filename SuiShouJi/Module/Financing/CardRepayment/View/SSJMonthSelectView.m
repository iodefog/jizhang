
//
//  SSJMonthSelectView.m
//  SuiShouJi
//
//  Created by ricky on 2016/12/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMonthSelectView.h"

@interface SSJMonthSelectView()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic,strong) UIPickerView *datePicker;

@property (nonatomic,strong) UIView *topView;

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) UIButton *closeButton;

@property (nonatomic,strong) UIButton *comfirmButton;

@property(nonatomic, strong) NSMutableArray *years;

@end

@implementation SSJMonthSelectView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.maxDate = [NSDate dateWithYear:2999 month:12 day:31];
        self.minimumDate = [NSDate dateWithYear:1000 month:1 day:1];
        [self addSubview:self.datePicker];
        [self addSubview:self.topView];
        [self getYearsArray];
        [self.datePicker reloadAllComponents];
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
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
    self.topView.leftTop = CGPointMake(0, 0);
    self.titleLabel.center = CGPointMake(self.topView.width / 2, self.topView.height / 2);
    self.closeButton.centerY = self.topView.height / 2;
    self.closeButton.left = 10;
    self.comfirmButton.centerY = self.topView.height / 2;
    self.comfirmButton.right = self.width - 10;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.years.count;
    }
    return 12;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.width  / 2;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        NSString *year = [self.years objectAtIndex:row];
        self.currentDate = [NSDate dateWithYear:[year integerValue] month:self.currentDate.month day:self.currentDate.day];
    }
    if (component == 1) {
        NSString *month = [[self monthArray] objectAtIndex:row];
        self.currentDate = [NSDate dateWithYear:self.currentDate.year month:[month integerValue] day:self.currentDate.day];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 50;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc]init];
    if (component == 0) {
        label.text = [self.years objectAtIndex:row];
        label.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        label.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        label.textAlignment = NSTextAlignmentRight;
        [label sizeToFit];
    }else{
        label.text = [[self monthArray] objectAtIndex:row];
        label.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        label.textColor = [UIColor ssj_colorWithHex:@"#393939"];
        label.textAlignment = NSTextAlignmentLeft;
        [label sizeToFit];
    }
    return label;
}


-(UIPickerView *)datePicker{
    if (!_datePicker) {
        _datePicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, self.width, 300)];
        _datePicker.delegate = self;
        _datePicker.dataSource = self;
    }
    return _datePicker;
}

-(UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc]init];
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
        [_closeButton setTitleColor:[UIColor ssj_colorWithHex:@"#eb4a64"] forState:UIControlStateNormal];
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

- (void)setCurrentDate:(NSDate *)currentDate{
    _currentDate = currentDate;
    if (_currentDate) {
        [self.datePicker selectRow:_currentDate.year - self.minimumDate.year inComponent:0 animated:NO];
        [self.datePicker selectRow:_currentDate.month - 1 inComponent:1 animated:NO];
    }
}

- (void)closeButtonClicked:(id)sender{
    [self dismiss];
}

- (void)comfirmButtonClicked:(id)sender{
    [self dismiss];
    if (self.timerSetBlock) {
        self.timerSetBlock(self.currentDate);
    }
}

- (NSArray *)monthArray{
    return @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12"];
}

- (void)getYearsArray{
    self.years = [NSMutableArray arrayWithCapacity:0];
    for (NSInteger i = self.minimumDate.year; i < self.maxDate.year; i ++) {
        [self.years addObject:[NSString stringWithFormat:@"%ld",(long)i]];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
