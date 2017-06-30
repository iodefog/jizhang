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
        [self addSubview:self.hiddenButton];
        [self addSubview:self.balanceButton];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.balanceLabel.top = self.height / 2 + 4;
    self.balanceLabel.left = 18;
    self.balanceTitleLab.bottom = self.balanceLabel.top - 8;
    self.balanceTitleLab.left = self.balanceLabel.left;
    self.balanceButton.left = self.balanceTitleLab.right + 10;
    self.balanceButton.bottom = self.balanceTitleLab.bottom;
    self.transferButton.size = CGSizeMake(60, 24);
    self.transferButton.centerY = self.balanceLabel.centerY;
    self.transferButton.right = self.width - 18;
    self.hiddenButton.centerY = self.balanceLabel.centerY;
    self.hiddenButton.left = self.balanceLabel.right + 10;
}

-(UILabel *)balanceLabel{
    if (!_balanceLabel) {
        _balanceLabel = [[UILabel alloc] init];
        _balanceLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _balanceLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
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
        _transferButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _transferButton;
}

- (UILabel *)balanceTitleLab {
    if (!_balanceTitleLab) {
        _balanceTitleLab = [[UILabel alloc] init];
        _balanceTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _balanceTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _balanceTitleLab.text = @"结余";
        [_balanceTitleLab sizeToFit];
    }
    return _balanceTitleLab;
}

-(UIButton *)hiddenButton{
    if (!_hiddenButton) {
        _hiddenButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_hiddenButton setImage:[[UIImage imageNamed:@"founds_yincang"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_hiddenButton setImage:[[UIImage imageNamed:@"founds_xianshi"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        [_hiddenButton addTarget:self action:@selector(hiddenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _hiddenButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _hiddenButton;
}

- (UIButton *)balanceButton {
    if (!_balanceButton) {
        _balanceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_balanceButton setImage:[UIImage imageNamed:@"founds_selectbutton"] forState:UIControlStateNormal];
        [_balanceButton sizeToFit];
        [_balanceButton addTarget:self action:@selector(balanceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _balanceButton;
}

-(void)setBalanceAmount:(NSString *)balanceAmount{
    _balanceAmount = balanceAmount;
    self.balanceLabel.text = _balanceAmount;
    [self.balanceLabel sizeToFit];
}

#pragma mark - Event
-(void)hiddenButtonClicked:(id)sender{
    if (self.hiddenButtonClickBlock) {
        self.hiddenButtonClickBlock();
    }
}

- (void)updateAfterThemeChange {
    self.balanceLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.transferButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    self.transferButton.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor].CGColor;
    [self.transferButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
    [self.transferButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    self.balanceTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.hiddenButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

- (void)balanceButtonClicked:(id)sender {
    self.balanceButton.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
    if (self.balanceButtonClickBlock) {
        self.balanceButtonClickBlock();
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
