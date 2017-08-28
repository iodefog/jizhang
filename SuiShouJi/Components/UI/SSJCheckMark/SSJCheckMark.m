//
//  SSJCheckMark.m
//  SuiShouJi
//
//  Created by old lang on 2017/8/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCheckMark.h"

@interface _SSJCheckMarkDisplayView : UIView

@property (nonatomic, strong) UIColor *fillColor;

@property (nonatomic, strong) UIColor *tickColor;

@end

@implementation _SSJCheckMarkDisplayView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setFillColor:(UIColor *)fillColor {
    if (!CGColorEqualToColor(_fillColor.CGColor, fillColor.CGColor)) {
        _fillColor = fillColor;
        [self setNeedsDisplay];
    }
}

- (void)setTickColor:(UIColor *)tickColor {
    if (!CGColorEqualToColor(_tickColor.CGColor, tickColor.CGColor)) {
        _tickColor = tickColor;
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    [self.fillColor setFill];
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    [path fill];
    
    [self.tickColor setStroke];
    [path removeAllPoints];
    [path moveToPoint:CGPointMake(CGRectGetWidth(self.bounds) * 0.125, CGRectGetHeight(self.bounds) * 0.5)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) * 0.36, CGRectGetHeight(self.bounds) * 0.74)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) * 0.82, CGRectGetHeight(self.bounds) * 0.26)];
    path.lineWidth = 1;
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    [path stroke];
}

@end

@interface SSJCheckMark ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIColor *> *tickColorInfo;

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIColor *> *fillColorInfo;

@property (nonatomic, strong) _SSJCheckMarkDisplayView *displayView;

@property (nonatomic) BOOL userSetRadius;

@end

@implementation SSJCheckMark

- (void)dealloc {
    [self removeObserver];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.tickColorInfo = [NSMutableDictionary dictionary];
        self.fillColorInfo = [NSMutableDictionary dictionary];
        [self addSubview:self.displayView];
        self.backgroundColor = [UIColor clearColor];
        [self addObserver];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_userSetRadius) {
        _radius = MIN(self.width, self.height) * 0.5;
    }
    self.displayView.size = CGSizeMake(self.radius * 2, self.radius * 2);
    self.displayView.center = CGPointMake(self.width * 0.5, self.height * 0.5);
}

- (void)setRadius:(CGFloat)radius {
    if (_radius != radius) {
        _radius = radius;
        _userSetRadius = YES;
        [self setNeedsLayout];
    }
}

- (_SSJCheckMarkDisplayView *)displayView {
    if (!_displayView) {
        _displayView = [[_SSJCheckMarkDisplayView alloc] init];
    }
    return _displayView;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context {
    [self updateAppearance];
    [self willChangeValueForKey:@"currentState"];
    [self didChangeValueForKey:@"currentState"];
}

- (void)addObserver {
    [self addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeObserver {
    [self removeObserver:self forKeyPath:@"enabled"];
    [self removeObserver:self forKeyPath:@"selected"];
    [self removeObserver:self forKeyPath:@"highlighted"];
}

- (void)updateAppearance {
    self.displayView.fillColor = self.fillColorInfo[@(self.currentState)] ?: self.fillColorInfo[@(SSJCheckMarkNormal)];
    self.displayView.tickColor = self.tickColorInfo[@(self.currentState)] ?: self.tickColorInfo[@(SSJCheckMarkNormal)];
}

- (void)setCurrentState:(SSJCheckMarkState)currentState {
    switch (currentState) {
        case SSJCheckMarkDisabled:
            self.enabled = NO;
            self.selected = NO;
            self.highlighted = NO;
            break;
            
        case SSJCheckMarkSelected:
            self.enabled = YES;
            self.selected = YES;
            self.highlighted = NO;
            break;
            
        case SSJCheckMarkHighlighted:
            self.enabled = YES;
            self.selected = NO;
            self.highlighted = YES;
            break;
            
        case SSJCheckMarkNormal:
            self.enabled = YES;
            self.selected = NO;
            self.highlighted = NO;
            break;
            
        default:
            break;
    }
}

- (SSJCheckMarkState)currentState {
    if (self.state & UIControlStateDisabled) {
        return SSJCheckMarkDisabled;
    } else if (self.state & UIControlStateSelected) {
        return SSJCheckMarkSelected;
    } else if (self.state & UIControlStateHighlighted) {
        return SSJCheckMarkHighlighted;
    } else {
        return SSJCheckMarkNormal;
    }
}

- (void)setTickColr:(UIColor *)tickColr forState:(SSJCheckMarkState)state {
    self.tickColorInfo[@(state)] = tickColr;
    [self updateAppearance];
}

- (UIColor *)tickColorForState:(SSJCheckMarkState)state {
    return self.tickColorInfo[@(state)];
}

- (void)setFillColr:(UIColor *)fillColor forState:(SSJCheckMarkState)state {
    self.fillColorInfo[@(state)] = fillColor;
    [self updateAppearance];
}

- (UIColor *)fillColorForState:(SSJCheckMarkState)state {
    return self.fillColorInfo[@(state)];
}

@end


@implementation SSJCheckMark (SSJTheme)

- (void)updateAppearanceAccordingToTheme {
    [self setFillColr:SSJ_MAIN_FILL_COLOR forState:SSJCheckMarkNormal];
    [self setFillColr:SSJ_MARCATO_COLOR forState:SSJCheckMarkSelected];
    [self setTickColr:[UIColor whiteColor] forState:SSJCheckMarkNormal];
}

@end

