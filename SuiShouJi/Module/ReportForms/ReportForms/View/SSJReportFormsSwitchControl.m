//
//  SSJReportFormsSwitchControl.m
//  SuiShouJi
//
//  Created by old lang on 16/7/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsSwitchControl.h"

@interface SSJReportFormsSwitchControl ()

@property (nonatomic, strong) NSMutableArray *buttons;

@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, strong) NSMutableArray *verticalLines;

@property (nonatomic, strong) UIView *horizontalLine;

@end

@implementation SSJReportFormsSwitchControl

- (instancetype)initWithTitles:(NSArray <NSString *>*)titles {
    if (self = [super initWithFrame:CGRectZero]) {
        self.backgroundColor = [UIColor clearColor];
        
        _titles = titles;
        _buttons = [NSMutableArray arrayWithCapacity:titles.count];
        _verticalLines = [NSMutableArray arrayWithCapacity:titles.count];
        
        for (int i = 0; i < titles.count; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            [_buttons addObject:btn];
        }
        
        for (int i = 0; i < titles.count - 1; i ++) {
            UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.height)];
            [self addSubview:verticalLine];
            [_verticalLines addObject:verticalLine];
        }
        
        _horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width / titles.count, 1)];
        [self addSubview:_horizontalLine];
        
        self.selectedIndex = 0;
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat btnWidth = self.width / _buttons.count;
    for (int i = 0; i < _buttons.count; i ++) {
        UIButton *btn = _buttons[i];
        btn.frame = CGRectMake(btnWidth * i, 0, btnWidth, self.height);
    }
    
    for (int i = 0; i < _verticalLines.count; i ++) {
        UIView *line = _verticalLines[i];
        line.frame = CGRectMake(btnWidth * (i + 1), 0, 1, self.height);
    }
    
//    _horizontalLine.top = self.height - 1;
//    _horizontalLine.size = CGSizeMake(self.width / _buttons.count, 1);
    [self updateHorizontalLine];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex > _buttons.count - 1) {
        SSJPRINT(@"警告：selectedIndex大于最大限制");
        return;
    }
    
    _selectedIndex = selectedIndex;
    for (int i = 0; i < _buttons.count; i ++) {
        UIButton *btn = _buttons[i];
        btn.selected = i == _selectedIndex;
        
        SSJBorderStyle borderStyle = (i < _buttons.count - 1) ? SSJBorderStyleRight : SSJBorderStyleleNone;
        borderStyle = i != _selectedIndex ?: borderStyle | SSJBorderStyleBottom;
        [btn ssj_setBorderStyle:borderStyle];
    }
    
    [self updateHorizontalLine];
}

- (void)updateHorizontalLine {
    CGFloat left = 0;
    if (_selectedIndex + 1 >= _buttons.count) {
        left = (_selectedIndex + 1 - _buttons.count) * self.width / _buttons.count;
    } else {
        left = (_selectedIndex + 1) * self.width / _buttons.count;
    }
    
    _horizontalLine.frame = CGRectMake(left, self.height - 1, self.width / _buttons.count * (_buttons.count - 1), 1);
}

- (void)setNormalTitleColor:(UIColor *)normalTitleColor {
    if (!CGColorEqualToColor(_normalTitleColor.CGColor, normalTitleColor.CGColor)) {
        _normalTitleColor = normalTitleColor;
        
        for (UIButton *btn in _buttons) {
            [btn setTitleColor:_normalTitleColor forState:UIControlStateNormal];
            [btn setTitleColor:_normalTitleColor forState:(UIControlStateNormal | UIControlStateHighlighted)];
        }
    }
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    if (!CGColorEqualToColor(_selectedTitleColor.CGColor, selectedTitleColor.CGColor)) {
        _selectedTitleColor = selectedTitleColor;
        
        for (UIButton *btn in _buttons) {
            [btn setTitleColor:selectedTitleColor forState:UIControlStateSelected];
            [btn setTitleColor:selectedTitleColor forState:(UIControlStateSelected | UIControlStateHighlighted)];
        }
    }
}

- (void)setNormalBackgroundColor:(UIColor *)normalBackgroundColor {
    if (!CGColorEqualToColor(_normalBackgroundColor.CGColor, normalBackgroundColor.CGColor)) {
        _normalBackgroundColor = normalBackgroundColor;
        
        for (UIButton *btn in _buttons) {
            [btn ssj_setBackgroundColor:_normalBackgroundColor forState:UIControlStateNormal];
            [btn ssj_setBackgroundColor:_normalBackgroundColor forState:UIControlStateNormal | UIControlStateHighlighted];
        }
    }
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor {
    if (!CGColorEqualToColor(_selectedBackgroundColor.CGColor, selectedBackgroundColor.CGColor)) {
        _selectedBackgroundColor = selectedBackgroundColor;
        
        for (UIButton *btn in _buttons) {
            [btn ssj_setBackgroundColor:_selectedBackgroundColor forState:UIControlStateSelected];
            [btn ssj_setBackgroundColor:_selectedBackgroundColor forState:UIControlStateSelected | UIControlStateHighlighted];
        }
    }
}

- (void)setLineColor:(UIColor *)lineColor {
    if (!CGColorEqualToColor(_lineColor.CGColor, lineColor.CGColor)) {
        _lineColor = lineColor;
        
        for (UIView *line in _verticalLines) {
            line.backgroundColor = _lineColor;
        }
        _horizontalLine.backgroundColor = _lineColor;
    }
}

- (void)buttonAction:(UIButton *)btn {
    self.selectedIndex = [_buttons indexOfObject:btn];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
