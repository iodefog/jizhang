//
//  SSJReportFormsCurveView.m
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveView.h"
#import "SSJReportFormsCurveViewItem.h"
#import "SSJReportFormsCurveDot.h"

@interface SSJReportFormsCurveView ()

@property (nonatomic, strong) UIBezierPath *curvePath;

@property (nonatomic, strong) CAShapeLayer *curveLayer;

@property (nonatomic, strong) SSJReportFormsCurveDot *dot;

@property (nonatomic, strong) UILabel *valueLab;

@property (nonatomic, strong) NSSet *observedCurveProperies;

@property (nonatomic, strong) NSSet *observedDotProperies;

@property (nonatomic, strong) NSSet *observedLabelProperies;

@end

@implementation SSJReportFormsCurveView

- (void)dealloc {
    [self removeObserver];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _observedCurveProperies = [[NSSet alloc] initWithObjects:@"startPoint",
                                   @"endPoint",
                                   @"showCurve",
                                   @"curveWidth",
                                   @"curveColor",
                                   @"showShadow",
                                   @"shadowWidth",
                                   @"shadowOffset",
                                   @"shadowAlpha", nil];
        
        _observedDotProperies = [[NSSet alloc] initWithObjects:@"showValue",
                                 @"value",
                                 @"valueColor",
                                 @"valueFont", nil];
        
        _observedLabelProperies = [[NSSet alloc] initWithObjects:@"showDot",
                                   @"dotColor",
                                   @"dotAlpha", nil];
        
        _curvePath = [UIBezierPath bezierPath];
        
        _curveLayer = [CAShapeLayer layer];
        [self.layer addSublayer:_curveLayer];
        
        _dot = [[SSJReportFormsCurveDot alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _dot.outerRadius = 8;
        _dot.innerRadius = 4;
        [self addSubview:_dot];
        
        _valueLab = [[UILabel alloc] init];
        [self addSubview:_valueLab];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    _dot.center = _item.endPoint;
    
    [_valueLab sizeToFit];
    _valueLab.leftTop = CGPointMake(_item.endPoint.x + _dot.outerRadius, _item.endPoint.y);
}

- (void)setItem:(SSJReportFormsCurveViewItem *)item {
    
    if (!item) {
        SSJPRINT(@"item不能为nil");
        return;
    }
    
    BOOL needsToUpdateCurve = (!_item || ![_item isCurveInfoEqualToItem:item]);
    
    [self removeObserver];
    _item = item;
    [self addObserver];
    
    [self updateDot];
    [self updateValueLabel];
    
    _curveLayer.hidden = !_item.showCurve;
    if (needsToUpdateCurve && _item.showCurve) {
        [self updateCurve];
    }
}

- (void)updateCurve {
    
    CGFloat offset = (_item.endPoint.x - _item.startPoint.x) * 0.35;
    CGPoint controlPoint1 = CGPointMake(_item.startPoint.x + offset, _item.startPoint.y);
    CGPoint controlPoint2 = CGPointMake(_item.endPoint.x - offset, _item.endPoint.y);
    
    [_curvePath removeAllPoints];
    [_curvePath moveToPoint:_item.startPoint];
    [_curvePath addCurveToPoint:_item.endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    
    _curveLayer.path = _curvePath.CGPath;
    _curveLayer.lineWidth = _item.curveWidth;
    _curveLayer.strokeColor = _item.curveColor.CGColor;
    _curveLayer.fillColor = [UIColor clearColor].CGColor;
    
    if (_item.showShadow) {
        _curveLayer.shadowColor = _item.curveColor.CGColor;
        _curveLayer.shadowOpacity = 0.3;
        _curveLayer.shadowOffset = _item.shadowOffset;
        _curveLayer.shadowRadius = 1;
    }
}

- (void)updateDot {
    _dot.dotColor = _item.dotColor;
    _dot.outerColorAlpha = _item.dotAlpha;
    _dot.hidden = !_item.showDot;
}

- (void)updateValueLabel {
    _valueLab.hidden = !_item.showValue;
    _valueLab.textColor = _item.valueColor;
    _valueLab.font = _item.valueFont;
    _valueLab.text = _item.value;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context {
    
    if ([_observedCurveProperies containsObject:keyPath]) {
        [self updateCurve];
    } else if ([_observedDotProperies containsObject:keyPath]) {
        [self updateDot];
    } else if ([_observedLabelProperies containsObject:keyPath]) {
        [self updateValueLabel];
    }
}

- (void)addObserver {
    for (NSString *property in _observedCurveProperies) {
        [_item addObserver:self forKeyPath:property options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    for (NSString *property in _observedDotProperies) {
        [_item addObserver:self forKeyPath:property options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    for (NSString *property in _observedLabelProperies) {
        [_item addObserver:self forKeyPath:property options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)removeObserver {
    for (NSString *property in _observedCurveProperies) {
        [_item removeObserver:self forKeyPath:property];
    }
    
    for (NSString *property in _observedDotProperies) {
        [_item removeObserver:self forKeyPath:property];
    }
    
    for (NSString *property in _observedLabelProperies) {
        [_item removeObserver:self forKeyPath:property];
    }
}

@end
