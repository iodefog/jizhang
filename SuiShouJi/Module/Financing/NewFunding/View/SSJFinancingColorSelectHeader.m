//
//  SSJFinancingColorSelectHeader.m
//  SuiShouJi
//
//  Created by ricky on 2017/3/1.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFinancingColorSelectHeader.h"

@interface SSJFinancingColorSelectHeader()

@property(nonatomic, strong) CAGradientLayer *backLayer;

@property(nonatomic, strong) UILabel *balanceLab;

@property(nonatomic, strong) UILabel *nameLab;

@end

@implementation SSJFinancingColorSelectHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self.layer addSublayer:self.backLayer];
        [self addSubview:self.nameLab];
        [self addSubview:self.balanceLab];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backLayer.size = CGSizeMake(self.width - 30, self.height - 40);
    self.backLayer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.backLayer.width + 2, self.backLayer.height + 2) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(8, 8)].CGPath;
    self.backLayer.position = CGPointMake(self.width / 2, self.height / 2);
    if (self.nameLab.width + self.balanceLab.width > self.backLayer.width - 20) {
        CGFloat reduction = (self.nameLab.width + self.balanceLab.width - (self.width - 20)) * 0.5;
        self.nameLab.width -= reduction;
        self.balanceLab.width -= reduction;
    }
    self.nameLab.left = self.backLayer.left + 10;
    self.nameLab.centerY = self.height / 2;
    self.balanceLab.right = self.backLayer.right - 10;
    self.balanceLab.centerY = self.height / 2;
}

- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.font = [UIFont systemFontOfSize:18];
        _nameLab.textColor = [UIColor whiteColor];
    }
    return _nameLab;
}

- (UILabel *)balanceLab {
    if (!_balanceLab) {
        _balanceLab = [[UILabel alloc] init];
        _balanceLab.font = [UIFont systemFontOfSize:18];
        _balanceLab.textColor = [UIColor whiteColor];
    }
    return _balanceLab;
}

- (CAGradientLayer *)backLayer {
    if (!_backLayer) {
        _backLayer = [CAGradientLayer layer];
        _backLayer.cornerRadius = 8;
        _backLayer.shadowOpacity = 0.4;
    }
    return _backLayer;
}

- (void)setFundName:(NSString *)fundName {
    self.nameLab.text = fundName;
    [self.nameLab sizeToFit];
}

- (void)setFundBalance:(NSString *)fundBalance {
    self.balanceLab.text = fundBalance;
    [self.balanceLab sizeToFit];
}

- (void)setItem:(SSJFinancingGradientColorItem *)item{
    _backLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:item.startColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:item.endColor].CGColor];
    _backLayer.shadowColor = [UIColor ssj_colorWithHex:item.startColor].CGColor;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
