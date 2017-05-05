
//
//  SSJChargeCIrcleSelectVIew.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/2/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJChargeCircleSelectView.h"

@interface SSJChargeCircleSelectView()
@property (nonatomic,strong) UIPickerView *pickerView;
@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *closeButton;
@property (nonatomic,strong) UIButton *comfirmButton;
@property (nonatomic, copy) NSString *selectedPeriod;
@end

@implementation SSJChargeCircleSelectView{
    NSArray *_titleArray;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        _titleArray = @[@"每天",@"每个工作日",@"每个周末(六、日)",@"每周",@"每月",@"每月最后一天",@"每年"];
        _selectCircleType = 0;
        [self addSubview:self.pickerView];
        [self addSubview:self.topView];
        [self sizeToFit];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.topView.size = CGSizeMake(self.width, 50);
    self.topView.leftTop = CGPointMake(0, 0);
    self.titleLabel.center = CGPointMake(self.topView.width / 2, self.topView.height / 2);
    self.closeButton.centerY = self.topView.height / 2;
    self.closeButton.left = 10;
    self.comfirmButton.centerY = self.topView.height / 2;
    self.comfirmButton.right = self.width - 10;
    self.pickerView.top = self.topView.bottom;
}

- (void)show {
    if (self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    self.top = keyWindow.height;
    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.3 target:self touchAction:@selector(dismissIfNeeded) animation:^{
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
        if (_dismissAction) {
            _dismissAction(self);
        }
    }];
}

-(CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake([UIApplication sharedApplication].keyWindow.width, self.pickerView.height + 50);
}

-(UIPickerView *)pickerView{
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, self.width, 300)];
        _pickerView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
        _pickerView.showsSelectionIndicator=YES;
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
    }
    return _pickerView;
}

-(UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc]init];
        _topView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
        _titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [_topView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        [_topView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_topView ssj_setBorderWidth:1];
        [_titleLabel sizeToFit];
        [_topView addSubview:_titleLabel];
        _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
        [_closeButton setImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _closeButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor];
        [_closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:_closeButton];
        _comfirmButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
        [_comfirmButton setImage:[[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _comfirmButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor];
        [_comfirmButton addTarget:self action:@selector(comfirmButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:_comfirmButton];
    }
    return _topView;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _titleArray.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.width;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _selectCircleType = row - 1;
    _selectedPeriod = [_titleArray ssj_safeObjectAtIndex:(_selectCircleType + 1)];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 50;
}

//-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    return [_titleArray objectAtIndex:row];
//}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc]init];
    label.text = [_titleArray objectAtIndex:row];
    label.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_3);
    label.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    [label sizeToFit];
    return label;
}

-(void)closeButtonClicked:(id)sender{
    [self dismiss];
}

-(void)setSelectCircleType:(NSInteger)selectCircleType{
    _selectCircleType = selectCircleType;
    _selectedPeriod = [_titleArray ssj_safeObjectAtIndex:(_selectCircleType)];
    [self.pickerView selectRow:_selectCircleType inComponent:0 animated:NO];
}

-(void)setIncomeOrExpenture:(BOOL)incomeOrExpenture{
    _incomeOrExpenture = incomeOrExpenture;
    if (!_incomeOrExpenture) {
        self.titleLabel.text = @"周期支出";
    }else{
        self.titleLabel.text = @"周期收入";
    }
    [self.titleLabel sizeToFit];
}

-(void)comfirmButtonClicked:(id)sender{
    if (self.chargeCircleSelectBlock) {
        self.chargeCircleSelectBlock(_selectCircleType + 1);
    }
    [self dismissIfNeeded];
}

- (void)dismissIfNeeded {
    BOOL shouldDismiss = YES;
    if (_shouldDismissWhenSureButtonClick) {
        shouldDismiss = _shouldDismissWhenSureButtonClick(self);
    }
    if (shouldDismiss) {
        [self dismiss];
    }
}

-(void)setTitle:(NSString *)title{
    _title = title;
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
}

@end
