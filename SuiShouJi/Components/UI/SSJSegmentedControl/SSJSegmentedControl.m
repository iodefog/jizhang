//
//  SSJSegmentedControl.m
//  SuiShouJi
//
//  Created by old lang on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJSegmentedControl.h"

@interface SSJSegmentedControl ()

@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation SSJSegmentedControl

- (instancetype)initWithItems:(NSArray *)items; {
    if (!items.count) {
        return nil;
    }
    
    if (self = [super initWithFrame:CGRectZero]) {
        self.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        self.tintColor = [UIColor ssj_colorWithHex:@"#cccccc"];
        self.buttons = [NSMutableArray arrayWithCapacity:items.count];
        
        for (int i = 0; i < items.count; i ++) {
            NSString *title = items[i];
            if (![title isKindOfClass:[NSString class]]) {
                return nil;
            }
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.titleLabel.font = self.font;
            button.selected = (i == self.selectedSegmentIndex);
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitleColor:self.tintColor forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [button ssj_setBorderWidth:1];
            [button ssj_setBorderStyle:SSJBorderStyleAll];
            if (i == 0) {
                button.cornerRadius = 3;
                [button ssj_setBorderInsets:UIEdgeInsetsMake(1, 1, 1, 0)];
                [button ssj_setCornerStyle:(UIRectCornerTopLeft | UIRectCornerBottomLeft)];
            } else if (i == items.count - 1) {
                button.cornerRadius = 3;
                [button ssj_setBorderInsets:UIEdgeInsetsMake(1, 0, 1, 1)];
                [button ssj_setCornerStyle:(UIRectCornerTopRight | UIRectCornerBottomRight)];
            } else {
                [button ssj_setBorderInsets:UIEdgeInsetsMake(1, 0, 1, 0)];
            }
            
            [self addSubview:button];
            [self.buttons addObject:button];
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithItems:nil];
}

- (void)layoutSubviews {
    CGFloat width = self.width / self.buttons.count;
    CGFloat height = self.height;
    for (int i = 0; i < self.buttons.count; i ++) {
        UIButton *button = self.buttons[i];
        button.frame = CGRectMake(width * i, 0, width, height);
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (CGSizeEqualToSize(self.size, CGSizeZero)) {
        CGFloat width = 0.0;
        CGFloat height = 0.0;
        CGFloat horizontalGap = 16.0;
        CGFloat verticalGap = 10.0;
        for (UIButton *button in self.buttons) {
            NSString *title = [button titleForState:button.state];
            CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName:self.font}];
            width = MAX(width, titleSize.width + horizontalGap);
            height = MAX(height, titleSize.height + verticalGap);
        }
        return CGSizeMake(width * self.buttons.count, height);
    }
    return self.size;
}

- (nullable NSString *)titleForSegmentAtIndex:(NSUInteger)segment {
    if (segment < self.buttons.count) {
        UIButton *btn = self.buttons[segment];
        return [btn titleForState:UIControlStateNormal];
    }
    return nil;
}

- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state {
    for (UIButton *button in self.buttons) {
        UIColor *color = attributes[NSForegroundColorAttributeName];
        if (color) {
            [button setTitleColor:color forState:state];
        }
    }
}

- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex {
    if (_selectedSegmentIndex != selectedSegmentIndex) {
        _selectedSegmentIndex = selectedSegmentIndex;
        
        for (int i = 0; i < self.buttons.count; i ++) {
            UIButton *button = self.buttons[i];
            button.selected = (i == selectedSegmentIndex);
            UIColor *borderColor = (i == selectedSegmentIndex) ? _selectedBorderColor : _borderColor;
            [button ssj_setBorderColor:borderColor];
        }
    }
}

- (void)setFont:(UIFont *)font {
    _font = font;
    for (UIButton *button in self.buttons) {
        button.titleLabel.font = font;
    }
    [self sizeToFit];
}

- (void)setBorderColor:(UIColor *)borderColor {
    if (!CGColorEqualToColor(_borderColor.CGColor, borderColor.CGColor)) {
        _borderColor = borderColor;
        for (int i = 0; i < [self.buttons count]; i ++) {
            if (i != _selectedSegmentIndex) {
                UIButton *button = self.buttons[i];
                [button ssj_setBorderColor:_borderColor];
            }
        }
    }
}

- (void)setSelectedBorderColor:(UIColor *)selectedBorderColor {
    if (!CGColorEqualToColor(_selectedBorderColor.CGColor, selectedBorderColor.CGColor)) {
        _selectedBorderColor = selectedBorderColor;
        UIButton *btn = [self.buttons ssj_safeObjectAtIndex:_selectedSegmentIndex];
        [btn ssj_setBorderColor:_selectedBorderColor];
    }
}

- (void)buttonClickAction:(UIButton *)button {
    NSUInteger newIndex = [self.buttons indexOfObject:button];
    if (self.selectedSegmentIndex != newIndex) {
        self.selectedSegmentIndex = newIndex;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
