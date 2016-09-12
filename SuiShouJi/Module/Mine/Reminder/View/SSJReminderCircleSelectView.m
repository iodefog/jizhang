//
//  SSJReminderCircleSelectView.m
//  SuiShouJi
//
//  Created by ricky on 16/9/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReminderCircleSelectView.h"

@interface SSJReminderCircleSelectView()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic,strong) UIPickerView *pickerView;

@property (nonatomic,strong) UIView *topView;

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) UIButton *closeButton;

@property (nonatomic,strong) UIButton *comfirmButton;

@property (nonatomic, copy) NSString *selectedPeriod;

@end

@implementation SSJReminderCircleSelectView{
    NSArray *_titleArray;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        _titleArray = @[@"每天",@"仅一次",@"每个工作日",@"每个周末(六、日)",@"每周",@"每月",@"每月最后一天",@"每年"];
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
        _titleLabel.font = [UIFont systemFontOfSize:18];
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
    switch (row) {
        case 0:
            _selectCircleType = 0;
            break;
            
        case 1:
            _selectCircleType = 7;
            break;
            
        case 2:
            _selectCircleType = 1;
            break;
            
        case 3:
            _selectCircleType = 2;
            break;
            
        case 4:
            _selectCircleType = 3;
            break;
            
        case 5:
            _selectCircleType = 4;
            break;
            
        case 6:
            _selectCircleType = 5;
            break;
            
        case 7:
            _selectCircleType = 6;
            break;
            
        default:
            break;
    }
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
    label.font = [UIFont systemFontOfSize:18];
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
    switch (_selectCircleType) {
        case 0:
            [self.pickerView selectRow:0 inComponent:0 animated:NO];
            break;
            
        case 1:
            [self.pickerView selectRow:2 inComponent:0 animated:NO];
            break;
            
        case 2:
            [self.pickerView selectRow:3 inComponent:0 animated:NO];
            break;
            
        case 3:
            [self.pickerView selectRow:4 inComponent:0 animated:NO];
            break;
            
        case 4:
            [self.pickerView selectRow:5 inComponent:0 animated:NO];
            break;
            
        case 5:
            [self.pickerView selectRow:6 inComponent:0 animated:NO];
            break;
            
        case 6:
            [self.pickerView selectRow:7 inComponent:0 animated:NO];
            break;
            
        case 7:
            [self.pickerView selectRow:1 inComponent:0 animated:NO];
            break;
            
        default:
            break;
    }
}

-(void)comfirmButtonClicked:(id)sender{
    if (self.chargeCircleSelectBlock) {
        self.chargeCircleSelectBlock(_selectCircleType);
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
