//
//  SSJBudgetDetailNavigationTitleView.m
//  SuiShouJi
//
//  Created by old lang on 16/2/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetDetailNavigationTitleView.h"

@interface SSJBudgetDetailNavigationTitleView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *preButton;

@property (nonatomic, strong) UIButton *nextButton;

@end

@implementation SSJBudgetDetailNavigationTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.preButton];
        [self addSubview:self.nextButton];
    }
    return self;
}

- (void)layoutSubviews {
    self.preButton.left = 0;
    self.preButton.centerY = self.height * 0.5;
    
    self.nextButton.right = self.width;
    self.nextButton.centerY = self.height * 0.5;
    
    self.titleLabel.center = CGPointMake(self.width * 0.5, self.height * 0.5);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat width = self.titleLabel.width + self.preButton.width + self.nextButton.width + 10;
    CGFloat height = MAX(self.titleLabel.height, self.preButton.height);
    return CGSizeMake(width, height);
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:21];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

- (UIButton *)preButton {
    if (!_preButton) {
        _preButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_preButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    return _preButton;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    return _nextButton;
}

@end
