//
//  SSJBorderButton.m
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBorderButton.h"

static const NSTimeInterval kAnimationDuration = 0.25;

@interface SSJBorderButton ()

@property (nonatomic) SSJBorderButtonState state;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, weak) id target;

@property (nonatomic) SEL action;

@property (nonatomic, strong) NSMutableDictionary *titleInfo;

@property (nonatomic, strong) NSMutableDictionary *titleColorInfo;

@property (nonatomic, strong) NSMutableDictionary *borderColorInfo;

@property (nonatomic, strong) NSMutableDictionary *backgroundColorInfo;

@end

@implementation SSJBorderButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 3;
        self.layer.borderWidth = 1;
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        
        self.titleInfo = [NSMutableDictionary dictionary];
        self.titleColorInfo = [NSMutableDictionary dictionary];
        self.borderColorInfo = [NSMutableDictionary dictionary];
        self.backgroundColorInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)layoutSubviews {
    self.titleLabel.frame = self.bounds;
}

- (void)setFontSize:(CGFloat)size {
    if (_fontSize != size) {
        _fontSize = size;
        self.titleLabel.font = [UIFont systemFontOfSize:size];
    }
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
}

- (void)setState:(SSJBorderButtonState)state {
    if (_state != state) {
        _state = state;
        
        self.titleLabel.textColor = self.titleColorInfo[@(self.state)] ?: self.titleColorInfo[@(SSJBorderButtonStateNormal)];
        [UIView animateWithDuration:kAnimationDuration animations:^{
//            [self updateAppearance];
            self.titleLabel.text = self.titleInfo[@(self.state)] ?: self.titleInfo[@(SSJBorderButtonStateNormal)];
            self.layer.borderColor = ((UIColor *)self.borderColorInfo[@(self.state)]).CGColor ?: ((UIColor *)self.borderColorInfo[@(SSJBorderButtonStateNormal)]).CGColor;
            self.backgroundColor = self.backgroundColorInfo[@(self.state)] ?: self.backgroundColorInfo[@(SSJBorderButtonStateNormal)];
        }];
    }
}

- (void)setEnabled:(BOOL)enabled {
    if (_enabled != enabled) {
        _enabled = enabled;
        self.state = _enabled ? SSJBorderButtonStateNormal : SSJBorderButtonStateDisable;
    }
}

- (void)addTarget:(id)target action:(SEL)action {
    self.target = target;
    self.action = action;
}

- (void)setTitle:(NSString *)title forState:(SSJBorderButtonState)state {
    [self.titleInfo setObject:title forKey:@(state)];
    [self updateAppearance];
}

- (void)setTitleColor:(UIColor *)color forState:(SSJBorderButtonState)state {
    [self.titleColorInfo setObject:color forKey:@(state)];
    [self updateAppearance];
}

- (void)setBorderColor:(UIColor *)color forState:(SSJBorderButtonState)state {
    [self.borderColorInfo setObject:color forKey:@(state)];
    [self updateAppearance];
}

- (void)setBackgroundColor:(UIColor *)color forState:(SSJBorderButtonState)state {
    [self.backgroundColorInfo setObject:color forKey:@(state)];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.titleLabel.text = self.titleInfo[@(self.state)] ?: self.titleInfo[@(SSJBorderButtonStateNormal)];
    self.titleLabel.textColor = self.titleColorInfo[@(self.state)] ?: self.titleColorInfo[@(SSJBorderButtonStateNormal)];
    self.layer.borderColor = ((UIColor *)self.borderColorInfo[@(self.state)]).CGColor ?: ((UIColor *)self.borderColorInfo[@(SSJBorderButtonStateNormal)]).CGColor;
    self.backgroundColor = self.backgroundColorInfo[@(self.state)] ?: self.backgroundColorInfo[@(SSJBorderButtonStateNormal)];
}

#pragma mark - UIResponder
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    self.state = SSJBorderButtonStateHighlighted;
    
//    CALayer *presentationLayer = self.layer.presentationLayer;
//    if (!CGColorEqualToColor(presentationLayer.backgroundColor, DEFAULT_BACKGROUND_COLOR.CGColor)) {
//        [self.layer removeAllAnimations];
//        self.backgroundColor = DEFAULT_BACKGROUND_COLOR;
//        self.titleLabel.textColor = self.color;
//    } else {
//        self.backgroundColor = self.color;
//        self.titleLabel.textColor = [UIColor whiteColor];
//    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    double delayInSeconds = 0.1;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds*NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        self.state = SSJBorderButtonStateNormal;
    });
//    self.state = SSJBorderButtonStateNormal;
    
//    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
//        self.backgroundColor = DEFAULT_BACKGROUND_COLOR;
//        self.titleLabel.textColor = self.color;
//    } completion:NULL];
    
    if (self.enabled) {
        if ([self.target respondsToSelector:self.action]) {
            [self.target performSelector:self.action withObject:nil afterDelay:0.0];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    self.state = SSJBorderButtonStateNormal;
    
    
//    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
//        self.backgroundColor = self.backgroundColorInfo[@(UIControlStateNormal)];
//        self.titleLabel.textColor = self.color;
//    } completion:NULL];
}

@end
