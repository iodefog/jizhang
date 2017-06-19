
//
//  SSJHomeBudgetButton.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJHomeBudgetButton.h"
#import "SSJBudgetWaveWaterView.h"
#import "SSJShareBookItem.h"

@interface SSJHomeBudgetButton()

@end

@implementation SSJHomeBudgetButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.button];
        [self addSubview:self.seperatorLine];
        [self sizeToFit];
    }
    return self;
}

-(CGSize)sizeThatFits:(CGSize)size{
    if ([self.button.titleLabel.text isEqualToString:@"添加预算"]) {
        return CGSizeMake(200, 44);
    }
    if ([self.model isKindOfClass:[SSJShareBookItem class]]) {
        return CGSizeMake(115, 44);
    }
    return CGSizeMake([self.button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4]}].width + 20, 44);
}

-(void)layoutSubviews{
    if ([self.button.titleLabel.text isEqualToString:@"添加预算"]) {
        self.button.size = CGSizeMake(120, 26);
    }else{
        self.button.size = CGSizeMake(self.width, 26);
    }
    self.button.bottom = self.height;
    self.button.centerX = self.width / 2;
    self.button.centerY = self.height / 2;
    self.seperatorLine.size = CGSizeMake(1, self.height - self.button.bottom);
    self.seperatorLine.top = self.button.bottom;
    self.seperatorLine.centerX = self.button.centerX;
}

-(UIButton *)button{
    if (!_button) {
        _button = [[UIButton alloc]init];
        [_button setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];
        _button.layer.cornerRadius = 13.f;
        _button.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor].CGColor;
        _button.layer.borderWidth = 1.f;
        _button.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [_button addTarget:self action:@selector(budgetButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

-(UIView *)seperatorLine{
    if (!_seperatorLine) {
        _seperatorLine = [[UIView alloc]init];
        _seperatorLine.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor];
    }
    return _seperatorLine;
}

-(void)setModel:(id)model{
    
    _model = model;
    self.button.enabled = YES;
    if (model == nil) {
        [self.button setTitle:@"添加预算" forState:UIControlStateNormal];
        self.button.backgroundColor = [UIColor clearColor];
        self.button.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor].CGColor;
        [self.button setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];
    }
    if ([model isKindOfClass:[SSJBudgetModel class]]) {
        SSJBudgetModel *currentModel = (SSJBudgetModel *)model;
        [self.button setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];
        [self.button setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha]];
        self.button.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor].CGColor;
        if (_model == nil) {
            [self.button setTitle:@"添加预算" forState:UIControlStateNormal];
            self.button.backgroundColor = [UIColor clearColor];
            self.button.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor].CGColor;
            [self.button setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];
        }else{
            if (currentModel.budgetMoney >= currentModel.payMoney) {
                [self.button setTitle:[NSString stringWithFormat:@"剩余 %.2f",currentModel.budgetMoney - currentModel.payMoney] forState:UIControlStateNormal];
            }else{
                [self.button setTitle:[NSString stringWithFormat:@"超支 %.2f",currentModel.payMoney - currentModel.budgetMoney] forState:UIControlStateNormal];
            }
        }
    } else if ([model isKindOfClass:[SSJShareBookItem class]]){
        SSJShareBookItem *currentModel = (SSJShareBookItem *)model;
        [self.button setTitle:[NSString stringWithFormat:@"%ld 人", (long)currentModel.memberCount] forState:UIControlStateNormal];
        self.button.backgroundColor = [UIColor clearColor];
        self.button.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor].CGColor;
        [self.button setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];
    }
    [self sizeToFit];
    [self setNeedsLayout];
}

-(void)setCurrentBalance:(double)currentBalance{
    _currentBalance = currentBalance;
    self.button.enabled = NO;
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
    [self sizeToFit];
    [self setNeedsLayout];
}

-(void)setCurrentMonth:(long)currentMonth{
    _currentMonth = currentMonth;
}

-(void)budgetButtonClick:(id)sender{
    if (self.budgetButtonClickBlock) {
        self.budgetButtonClickBlock(self.model);
    }
}

- (void)updateAfterThemeChange{
    [self.button setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];
    [self.button setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha]];
    self.button.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor].CGColor;
    self.seperatorLine.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
