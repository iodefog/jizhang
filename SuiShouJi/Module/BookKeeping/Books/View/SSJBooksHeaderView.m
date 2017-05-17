//
//  SSJBooksHeaderView.m
//  SuiShouJi
//
//  Created by ricky on 16/11/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#define Angle2Radian(angle) ((angle) / 180.0 * M_PI)

static NSString *const kSummaryButtonAnimationKey = @"summaryButtonAnimationKey";

#import "SSJBooksHeaderView.h"

@interface SSJBooksHeaderView()

@property(nonatomic, strong) UILabel *incomeTitleLab;

@property(nonatomic, strong) UILabel *incomeLab;

@property(nonatomic, strong) UILabel *expentureTitleLab;

@property(nonatomic, strong) UILabel *expentureLab;

@property(nonatomic, strong) UIButton *summaryButton;

@property(nonatomic, strong) UIImageView *waveImage;
@end

@implementation SSJBooksHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self ssj_setBorderColor:[UIColor whiteColor]];
        [self ssj_setBorderStyle:SSJBorderStyleTop];
        [self ssj_setBorderWidth:1.f / [UIScreen mainScreen].scale];
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self addSubview:self.waveImage];
        [self addSubview:self.incomeTitleLab];
        [self addSubview:self.incomeLab];
        [self addSubview:self.expentureTitleLab];
        [self addSubview:self.expentureLab];
        [self addSubview:self.summaryButton];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    self.backColorView.leftTop = CGPointMake(0, 0);
    self.waveImage.leftTop = CGPointMake(0, 0);
    self.incomeTitleLab.centerY = self.expentureTitleLab.centerY = self.height / 2 + 12;
    self.incomeLab.centerY = self.expentureLab.centerY = self.height / 2 + 36;
    self.incomeTitleLab.centerX = self.incomeLab.centerX = self.width / 4;
    self.expentureTitleLab.centerX = self.expentureLab.centerX = self.width / 2 + self.width / 4;
    self.summaryButton.top = self.incomeTitleLab.top - 10;
    self.summaryButton.centerX = self.width / 2;
}

- (UILabel *)incomeTitleLab{
    if (!_incomeTitleLab) {
        _incomeTitleLab = [[UILabel alloc]init];
        _incomeTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _incomeTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        _incomeTitleLab.text = @"累计收入";
        [_incomeTitleLab sizeToFit];
    }
    return _incomeTitleLab;
}

- (UILabel *)incomeLab{
    if (!_incomeLab) {
        _incomeLab = [[UILabel alloc]init];
        _incomeLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _incomeLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
    }
    return _incomeLab;
}

- (UILabel *)expentureTitleLab{
    if (!_expentureTitleLab) {
        _expentureTitleLab = [[UILabel alloc]init];
        _expentureTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _expentureTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        _expentureTitleLab.text = @"累计支出";
        [_expentureTitleLab sizeToFit];
    }
    return _expentureTitleLab;
}

- (UILabel *)expentureLab{
    if (!_expentureLab) {
        _expentureLab = [[UILabel alloc]init];
        _expentureLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _expentureLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
    }
    return _expentureLab;
}

- (UIButton *)summaryButton{
    if (!_summaryButton) {
        _summaryButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 50)];
        [_summaryButton setImage:[UIImage ssj_themeImageWithName:@"bk_summary"] forState:UIControlStateNormal];
        _summaryButton.layer.anchorPoint = CGPointMake(0.5, 1);
        [_summaryButton addTarget:self action:@selector(buttonClickAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _summaryButton;
}

- (UIImageView *)waveImage{
    if (!_waveImage) {
        _waveImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _waveImage.image = [[UIImage ssj_themeImageWithName:@"bk_wave"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 32, 0) resizingMode:UIImageResizingModeStretch];
    }
    return _waveImage;
}

- (void)setIncome:(double)income{
    _income = income;
    self.incomeLab.text = [NSString stringWithFormat:@"%.2f",_income];
    [self.incomeLab sizeToFit];
}

- (void)setExpenture:(double)expenture{
    _expenture = expenture;
    self.expentureLab.text = [NSString stringWithFormat:@"%.2f",_expenture];
    [self.expentureLab sizeToFit];
}

// 抖动动画
- (void)startAnimating
{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    anim.keyPath = @"transform.rotation";
    
    anim.values = @[@(Angle2Radian(-8)),  @(Angle2Radian(8)), @(Angle2Radian(-8))];
    anim.duration = 3;
    // 动画的重复执行次数
    anim.repeatCount = MAXFLOAT;
    
    // 保持动画执行完毕后的状态
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    
    [self.summaryButton.layer addAnimation:anim forKey:kSummaryButtonAnimationKey];
}

- (void)stopLoading{
    [self.summaryButton.layer removeAnimationForKey:kSummaryButtonAnimationKey];
    
}

- (void)buttonClickAction{
    if (self.buttonClickBlock) {
        self.buttonClickBlock();
    }
}

- (void)updateAfterThemeChange{
    self.incomeTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.incomeLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.expentureTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.expentureLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    [self.summaryButton setImage:[UIImage ssj_themeImageWithName:@"bk_summary"] forState:UIControlStateNormal];
    self.waveImage.image = [[UIImage ssj_themeImageWithName:@"bk_wave"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 32, 0) resizingMode:UIImageResizingModeStretch];
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
