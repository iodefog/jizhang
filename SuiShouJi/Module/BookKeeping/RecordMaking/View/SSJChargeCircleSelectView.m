
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
@end

@implementation SSJChargeCircleSelectView{
    NSArray *_titleArray;
    NSInteger _selectedCircle;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        _titleArray = @[@"仅一次",@"每天",@"每个工作日",@"每个周末(六、日)",@"每周",@"每月",@"每年",@"每月最后一天"];
        [self addSubview:self.pickerView];
        [self addSubview:self.topView];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.pickerView.bottom = self.height;
    self.topView.size = CGSizeMake(self.width, 50);
    self.topView.leftTop = CGPointMake(0, self.pickerView.top);
    self.titleLabel.center = CGPointMake(self.topView.width / 2, self.topView.height / 2);
    self.closeButton.centerY = self.topView.height / 2;
    self.closeButton.left = 10;
    self.comfirmButton.centerY = self.topView.height / 2;
    self.comfirmButton.right = self.width - 10;
}

-(UIPickerView *)pickerView{
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, self.width, 300)];
        _pickerView.backgroundColor = [UIColor whiteColor];
        _pickerView.showsSelectionIndicator=YES;
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
    }
    return _pickerView;
}

-(UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc]init];
        _topView.backgroundColor = [UIColor whiteColor];
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"定期收入/支出";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        [_topView ssj_setBorderColor:[UIColor ssj_colorWithHex:@"cccccc"]];
        [_topView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_topView ssj_setBorderWidth:1];
        [_titleLabel sizeToFit];
        [_topView addSubview:_titleLabel];
        _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 23, 23)];
        [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:_closeButton];
        _comfirmButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 23, 23)];
        [_comfirmButton setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
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
    _selectedCircle = row - 1;
    NSLog(@"%ld",_selectedCircle);
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 50;
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_titleArray objectAtIndex:row];
}

-(void)closeButtonClicked:(id)sender{
    [self removeFromSuperview];
}

-(void)setSelectCircleType:(NSInteger)selectCircleType{
    _selectCircleType = selectCircleType;
    [self.pickerView selectRow:_selectCircleType + 1 inComponent:0 animated:NO];
}

-(void)comfirmButtonClicked:(id)sender{
    if (self.chargeCircleSelectBlock) {
        self.chargeCircleSelectBlock(_selectedCircle);
    }
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
