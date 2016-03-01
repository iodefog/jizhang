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

@property (nonatomic, strong) NSArray *titles;

@end

@implementation SSJBudgetDetailNavigationTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectMake(0, 0, 150, 30)]) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.preButton];
        [self addSubview:self.nextButton];
    }
    return self;
}

- (void)layoutSubviews {
    self.titleLabel.centerX = self.width * 0.5;
    self.preButton.right = self.titleLabel.left - 5;
    self.nextButton.left = self.titleLabel.right + 5;
    self.titleLabel.centerY = self.preButton.centerY = self.nextButton.centerY = self.height * 0.5;
}

//- (CGSize)sizeThatFits:(CGSize)size {
//    CGFloat width = self.titleLabel.width + self.preButton.width + self.nextButton.width + 10;
//    CGFloat height = MAX(self.titleLabel.height, self.preButton.height);
//    return CGSizeMake(width, height);
//}

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    if (_currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        [self updateTitle];
    }
}

- (void)setTitles:(NSArray *)titles {
    if (![_titles isEqualToArray:titles]) {
        _titles = titles;
        [self updateTitle];
        [self updateButtonEnable];
    }
}

- (void)setButtonShowed:(BOOL)showed {
    self.preButton.hidden = self.nextButton.hidden = !showed;
}

- (void)preButtonAction {
    _currentIndex --;
    _currentIndex = MAX(_currentIndex, 0);
    [self updateTitle];
    [self updateButtonEnable];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)updateButtonEnable {
    if (self.titles.count > 1) {
        self.preButton.enabled = _currentIndex > 0;
        self.nextButton.enabled = _currentIndex < self.titles.count - 1;
    } else {
        self.preButton.enabled = self.nextButton.enabled = NO;
    }
}

- (void)nextButtonAction {
    _currentIndex ++;
    _currentIndex = MIN(_currentIndex, self.titles.count - 1);
    [self updateTitle];
    [self updateButtonEnable];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)updateTitle {
    self.titleLabel.text = [self.titles ssj_safeObjectAtIndex:self.currentIndex];
    [self.titleLabel sizeToFit];
    [self sizeToFit];
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
        [_preButton setImage:[UIImage imageNamed:@"reportForms_left"] forState:UIControlStateNormal];
        [_preButton addTarget:self action:@selector(preButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_preButton sizeToFit];
    }
    return _preButton;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextButton setImage:[UIImage imageNamed:@"reportForms_right"] forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(nextButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_nextButton sizeToFit];
    }
    return _nextButton;
}

@end
