//
//  SSJBudgetDetailPeriodSwitchControl.m
//  SuiShouJi
//
//  Created by old lang on 16/3/11.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetDetailPeriodSwitchControl.h"

static CGSize kButtonSize = {36, 30};

@interface SSJBudgetDetailPeriodSwitchControl ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *preButton;

@property (nonatomic, strong) UIButton *nextButton;

@end

@implementation SSJBudgetDetailPeriodSwitchControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectMake(0, 0, 150, 30)]) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.preButton];
        [self addSubview:self.nextButton];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    [self.titleLabel sizeToFit];
    return CGSizeMake(self.titleLabel.width + self.preButton.width + self.nextButton.width, MAX(self.titleLabel.height, kButtonSize.height));
}

- (void)layoutSubviews {
    self.titleLabel.centerX = self.width * 0.5;
    self.preButton.right = self.titleLabel.left;
    self.nextButton.left = self.titleLabel.right;
    self.titleLabel.centerY = self.preButton.centerY = self.nextButton.centerY = self.height * 0.5;
}

- (void)setTitles:(NSArray *)titles {
    if (![_titles isEqualToArray:titles]) {
        _titles = titles;
        _selectedIndex = MIN(_selectedIndex, _titles.count - 1);
        
        [self updateTitle];
        [self updateButtonEnable];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex >= _titles.count) {
        SSJPRINT(@"selectedIndex超出数组titles的最大范围");
        return;
    }
    
    if (_selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        [self updateTitle];
        [self updateButtonEnable];
    }
}

- (void)setTitleSize:(CGFloat)titleSize {
    _titleLabel.font = [UIFont systemFontOfSize:titleSize];
    [self sizeToFit];
}

#pragma mark - Event
- (void)preButtonAction {
    _selectedIndex = MAX(0, _selectedIndex - 1);
    [self updateTitle];
    [self updateButtonEnable];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)nextButtonAction {
    _selectedIndex = MIN(_titles.count - 1, _selectedIndex + 1);
    [self updateTitle];
    [self updateButtonEnable];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - Private
- (void)updateButtonEnable {
    _preButton.enabled = _selectedIndex > 0;
    _nextButton.enabled = _selectedIndex < _titles.count - 1;
}

- (void)updateTitle {
    _titleLabel.text = [_titles ssj_safeObjectAtIndex:_selectedIndex];
    [self sizeToFit];
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:21];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTitleColor];
    }
    return _titleLabel;
}

- (UIButton *)preButton {
    if (!_preButton) {
        _preButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_preButton setImage:[[UIImage imageNamed:@"budget_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_preButton setImage:[UIImage imageNamed:@"budget_left_disable"] forState:UIControlStateDisabled];
        _preButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor];
        [_preButton addTarget:self action:@selector(preButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _preButton.size = kButtonSize;
    }
    return _preButton;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextButton setImage:[[UIImage imageNamed:@"budget_right"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_nextButton setImage:[UIImage imageNamed:@"budget_right_diable"] forState:UIControlStateDisabled];
        _nextButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor];
        [_nextButton addTarget:self action:@selector(nextButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _nextButton.size = kButtonSize;
    }
    return _nextButton;
}

@end
