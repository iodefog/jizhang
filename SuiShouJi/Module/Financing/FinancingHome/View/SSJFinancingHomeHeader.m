//
//  SSJFinancingHomeHeader.m
//  SuiShouJi
//
//  Created by ricky on 16/5/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFinancingHomeHeader.h"

@interface SSJFinancingHomeHeader()

@property(nonatomic, strong) UILabel *balanceLabel;

@property(nonatomic, strong) UILabel *balanceTitleLab;
@end

@implementation SSJFinancingHomeHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self addSubview:self.balanceLabel];
        [self addSubview:self.balanceTitleLab];
        [self addSubview:self.transferButton];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.balanceLabel.bottom = self.height;
    self.balanceLabel.left = 25;
    self.transferButton.size = CGSizeMake(60, 24);
    self.transferButton.bottom = self.height;
    self.transferButton.right = self.width - 34;
    [self.transferButton ssj_relayoutBorder];
    [self.transferButton ssj_layoutContent];
}

-(UILabel *)balanceLabel{
    if (!_balanceLabel) {
        _balanceLabel = [[UILabel alloc]init];
        _balanceLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _balanceLabel.font = [UIFont systemFontOfSize:22];
    }
    return _balanceLabel;
}

-(UIButton *)transferButton{
    if (!_transferButton) {
        _transferButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 24)];
        _transferButton.layer.cornerRadius = 12;
        _transferButton.layer.borderWidth = 1.f;
        _transferButton.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor].CGColor;
        _transferButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        [_transferButton setTitle:@"转账" forState:UIControlStateNormal];
        [_transferButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
        _transferButton.titleLabel.font = [UIFont systemFontOfSize:20];
        [_transferButton ssj_setBorderStyle:SSJBorderStyleLeft];
        [_transferButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    }
    return _transferButton;
}

- (UILabel *)balanceTitleLab {
    if (!_balanceTitleLab) {
        _balanceTitleLab = [[UILabel alloc] init];
        _balanceTitleLab.font = [UIFont systemFontOfSize:12];
        _balanceTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _balanceTitleLab.text = @"结余";
        [_balanceTitleLab sizeToFit];
    }
    return _balanceTitleLab;
}

-(void)setBalanceAmount:(NSString *)balanceAmount{
    _balanceAmount = balanceAmount;
    self.balanceLabel.text = _balanceAmount;
    [self.balanceLabel sizeToFit];
}

- (void)updateAfterThemeChange{
    self.balanceLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.transferButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    _transferButton.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor].CGColor;
    [self.transferButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
    [self.transferButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
