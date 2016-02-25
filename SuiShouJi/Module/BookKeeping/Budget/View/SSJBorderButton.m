//
//  SSJBorderButton.m
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBorderButton.h"

#define DEFAULT_BACKGROUND_COLOR [UIColor whiteColor]

static const NSTimeInterval kAnimationDuration = 0.25;

@interface SSJBorderButton ()

@property (nonatomic, strong) UIColor *color;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, weak) id target;

@property (nonatomic) SEL action;

@end

@implementation SSJBorderButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 3;
        self.backgroundColor = DEFAULT_BACKGROUND_COLOR;
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    self.titleLabel.frame = self.bounds;
}

- (void)setFontSize:(CGFloat)size {
    self.titleLabel.font = [UIFont systemFontOfSize:size];
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = 1;
    self.titleLabel.textColor = color;
}

- (void)addTarget:(id)target action:(SEL)action {
    self.target = target;
    self.action = action;
}

#pragma mark - UIResponder
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    CALayer *presentationLayer =  self.layer.presentationLayer;
    if (!CGColorEqualToColor(presentationLayer.backgroundColor, DEFAULT_BACKGROUND_COLOR.CGColor)) {
        [self.layer removeAllAnimations];
        self.backgroundColor = DEFAULT_BACKGROUND_COLOR;
        self.titleLabel.textColor = self.color;
    } else {
        self.backgroundColor = self.color;
        self.titleLabel.textColor = [UIColor whiteColor];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.backgroundColor = DEFAULT_BACKGROUND_COLOR;
        self.titleLabel.textColor = self.color;
    } completion:NULL];
    
    if ([self.target respondsToSelector:self.action]) {
        [self.target performSelector:self.action withObject:nil afterDelay:0.0];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.backgroundColor = DEFAULT_BACKGROUND_COLOR;
        self.titleLabel.textColor = self.color;
    } completion:NULL];
}

@end
