
//
//  SSJHomeBudgetButton.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJHomeBudgetButton.h"
#import "SSJBudgetWaveWaterView.h"

@interface SSJHomeBudgetButton()

@end
@implementation SSJHomeBudgetButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.button];
        [self sizeToFit];
    }
    return self;
}

-(CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake(200, 44);
}

-(void)layoutSubviews{
    self.button.size = CGSizeMake(120, 26);
    self.button.bottom = self.height;
    self.button.centerX = self.width / 2;
}

-(UIButton *)button{
    if (!_button) {
        _button = [[UIButton alloc]init];
        [_button setTitleColor:[UIColor ssj_colorWithHex:@"a7a7a7"] forState:UIControlStateNormal];
        _button.layer.cornerRadius = 13.f;
        _button.layer.borderColor = [UIColor ssj_colorWithHex:@"a7a7a7"].CGColor;
        _button.layer.borderWidth = 1.f;
        _button.titleLabel.font = [UIFont systemFontOfSize:14];
        [_button addTarget:self action:@selector(budgetButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

-(void)setModel:(SSJBudgetModel *)model{
    _model = model;
    [self.button setTitleColor:[UIColor ssj_colorWithHex:@"a7a7a7"] forState:UIControlStateNormal];
    [self.button setBackgroundColor:[UIColor whiteColor]];
    self.button.layer.borderColor = [UIColor ssj_colorWithHex:@"a7a7a7"].CGColor;
    if (_model == nil) {
        [self.button setTitle:@"添加预算" forState:UIControlStateNormal];
    }else{
        if (_model.budgetMoney > _model.payMoney) {
            [self.button setTitle:[NSString stringWithFormat:@"剩余 %.2f",_model.budgetMoney - _model.payMoney] forState:UIControlStateNormal];
        }else{
            [self.button setTitle:[NSString stringWithFormat:@"超支 %.2f",_model.payMoney - _model.budgetMoney] forState:UIControlStateNormal];
        }
    }
}

-(void)setCurrentBalance:(double)currentBalance{
    _currentBalance = currentBalance;
    if (self.currentMonth == 0) {
        [self.button setTitle:[NSString stringWithFormat:@"结余 %.2f",_currentBalance] forState:UIControlStateNormal];
    }else{
        [self.button setTitle:[NSString stringWithFormat:@"%ld月结余 %.2f",self.currentMonth,_currentBalance] forState:UIControlStateNormal];
    }
    if (_currentBalance > 0) {
        [self.button setTitleColor:[UIColor ssj_colorWithHex:@"fc5252"] forState:UIControlStateNormal];
        [self.button setBackgroundColor:[UIColor ssj_colorWithHex:@"ffdddd"]];
        self.button.layer.borderColor = [UIColor ssj_colorWithHex:@"fc5252"].CGColor;
    }else{
        [self.button setTitleColor:[UIColor ssj_colorWithHex:@"59ae65"] forState:UIControlStateNormal];
        [self.button setBackgroundColor:[UIColor ssj_colorWithHex:@"d7fddd"]];
        self.button.layer.borderColor = [UIColor ssj_colorWithHex:@"59ae65"].CGColor;
    }
}

-(void)setCurrentMonth:(long)currentMonth{
    _currentMonth = currentMonth;
}

-(void)budgetButtonClick:(id)sender{
    if (self.budgetButtonClickBlock) {
        self.budgetButtonClickBlock(self.model);
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
