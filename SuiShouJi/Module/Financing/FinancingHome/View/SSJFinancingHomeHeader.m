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
@end

@implementation SSJFinancingHomeHeader
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self addSubview:self.balanceLabel];
        [self addSubview:self.transferButton];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.balanceLabel.centerY = self.height / 2;
    self.balanceLabel.left = 10;
    self.transferButton.size = CGSizeMake(100, 50);
    self.transferButton.centerY = self.height / 2;
    self.transferButton.right = self.width;
    [self.transferButton ssj_relayoutBorder];
    [self.transferButton ssj_layoutContent];
}

-(UILabel *)balanceLabel{
    if (!_balanceLabel) {
        _balanceLabel = [[UILabel alloc]init];
        _balanceLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _balanceLabel;
}

-(UIButton *)transferButton{
    if (!_transferButton) {
        _transferButton = [[UIButton alloc]init];
        _transferButton.contentLayoutType = SSJButtonLayoutTypeDefault;
        _transferButton.spaceBetweenImageAndTitle = 10;
        [_transferButton setImage:[[UIImage imageNamed:@"zhuanzhang"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        _transferButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        [_transferButton setTitle:@"转账" forState:UIControlStateNormal];
        [_transferButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
        _transferButton.titleLabel.font = [UIFont systemFontOfSize:20];
        [_transferButton ssj_setBorderStyle:SSJBorderStyleLeft];
        [_transferButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    }
    return _transferButton;
}

-(void)setBalanceAmount:(NSString *)balanceAmount{
    _balanceAmount = balanceAmount;
    NSString *balanceStr = [NSString stringWithFormat:@"结余: %@",_balanceAmount];
    NSMutableAttributedString *balace = [[NSMutableAttributedString alloc]initWithString:balanceStr];
    [balace addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:[balanceStr rangeOfString:@"结余:"]];
    [balace addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:22] range:[balanceStr rangeOfString:_balanceAmount]];
    self.balanceLabel.attributedText = balace;
    [self.balanceLabel sizeToFit];
}

- (void)updateAfterThemeChange{
    self.balanceLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.transferButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
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
