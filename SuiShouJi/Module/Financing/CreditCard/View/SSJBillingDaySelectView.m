//
//  SSJBillingDaySelectView.m
//  SuiShouJi
//
//  Created by ricky on 16/8/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBillingDaySelectView.h"

@interface SSJBillingDaySelectView()<UIPickerViewDelegate,UIPickerViewDataSource>

@property(nonatomic, strong) UIPickerView *dateSelect;

@property (nonatomic,strong) UIView *topView;

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) UIButton *closeButton;

@property (nonatomic,strong) UIButton *comfirmButton;

@property(nonatomic, strong) NSArray *shortArr;

@property(nonatomic, strong) NSArray *longtArr;

@property(nonatomic, strong) NSArray *aliArr;

@property(nonatomic, strong) NSArray *dateArr;

@property(nonatomic, strong) NSString *selectDate;

@end

@implementation SSJBillingDaySelectView

- (instancetype)initWithFrame:(CGRect)frame Type:(SSJDateSelectViewType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.shortArr = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28"];
        self.longtArr = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31"];
        self.aliArr = @[@"9",@"10"];
        if (type == SSJDateSelectViewTypeFullMonth) {
            self.dateArr = self.longtArr;
        } else if (type == SSJDateSelectViewTypeAlipay) {
            self.dateArr = self.aliArr;
        } else {
            self.dateArr = self.shortArr;
        }
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
        [self addSubview:self.dateSelect];
        [self addSubview:self.topView];
        [self sizeToFit];
    }
    return self;
}

-(CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake([UIApplication sharedApplication].keyWindow.width, self.dateSelect.height + 50);
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
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dateArr.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.width;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _currentDate = [[self.dateArr ssj_safeObjectAtIndex:row] integerValue];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 50;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc]init];
    label.text = [_dateArr objectAtIndex:row];
    label.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    label.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    [label sizeToFit];
    return label;
}


-(UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc]init];
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"选择日期";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [_topView ssj_setBorderColor:[UIColor ssj_colorWithHex:@"#cccccc"]];
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

-(UIPickerView *)dateSelect{
    if (!_dateSelect) {
        _dateSelect = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, self.width, 300)];
        _dateSelect.delegate = self;
        _dateSelect.dataSource = self;
    }
    return _dateSelect;
}

-(void)comfirmButtonClicked:(id)sender{
    if (self.dateSetBlock) {
        self.dateSetBlock(self.currentDate);
    }
    [self dismiss];
}

-(void)closeButtonClicked:(id)sender{
    [self dismiss];
}

-(void)setCurrentDate:(NSInteger)currentDate{
    _currentDate = currentDate;
    NSInteger currentIndex = [self.dateArr indexOfObject:[NSString stringWithFormat:@"%ld",currentDate]];
    [self.dateSelect selectRow:currentIndex inComponent:0 animated:NO];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
