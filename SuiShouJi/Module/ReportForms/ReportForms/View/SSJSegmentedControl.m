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
        self.layer.cornerRadius = 3;
        self.layer.borderWidth = 1;
        self.font = [UIFont systemFontOfSize:18];
        self.tintColor = [UIColor ssj_colorWithHex:@"#cccccc"];
        self.buttons = [NSMutableArray arrayWithCapacity:items.count];
        
        for (int i = 0; i < items.count; i ++) {
            NSString *title = items[i];
            if (![title isKindOfClass:[NSString class]]) {
                continue;
            }
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.titleLabel.font = self.font;
            button.selected = (i == self.selectedSegmentIndex);
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitleColor:self.tintColor forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
            if (i < items.count - 1) {
                [button ssj_setBorderStyle:SSJBorderStyleRight];
                [button ssj_setBorderWidth:1];
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
        [button ssj_relayoutBorder];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
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

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    
    if (!CGColorEqualToColor(self.tintColor.CGColor, tintColor.CGColor)) {
        self.layer.borderColor = tintColor.CGColor;
        for (UIButton *button in self.buttons) {
            [button setTitleColor:tintColor forState:UIControlStateNormal];
            [button ssj_setBorderColor:tintColor];
        }
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
