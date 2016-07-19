//
//  SSJBudgetDetailMiddleTitleView.m
//  SuiShouJi
//
//  Created by old lang on 16/2/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetDetailMiddleTitleView.h"

@interface SSJBudgetDetailMiddleTitleView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *periodLabel;

@end

@implementation SSJBudgetDetailMiddleTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.periodLabel];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    self.titleLabel.left = 14;
    self.periodLabel.right = self.width - 14;
    self.titleLabel.centerY = self.periodLabel.centerY = self.height * 0.5;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.titleLabel.backgroundColor = backgroundColor;
    self.periodLabel.backgroundColor = backgroundColor;
}

- (void)setTitle:(NSString *)title {
    if (![self.titleLabel.text isEqualToString:title]) {
        self.titleLabel.text = title;
        [self.titleLabel sizeToFit];
        [self setNeedsLayout];
    }
}

- (void)setPeriod:(NSString *)period {
    if (![self.periodLabel.text isEqualToString:period]) {
        self.periodLabel.text = period;
        [self.periodLabel sizeToFit];
        [self setNeedsLayout];
    }
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _titleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _titleLabel;
}

- (UILabel *)periodLabel {
    if (!_periodLabel) {
        _periodLabel = [[UILabel alloc] init];
        _periodLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _periodLabel.font = [UIFont systemFontOfSize:12];
    }
    return _periodLabel;
}

@end
