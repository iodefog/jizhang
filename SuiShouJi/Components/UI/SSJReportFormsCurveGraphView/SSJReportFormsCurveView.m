//
//  SSJReportFormsCurveView.m
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveView.h"
#import "SSJReportFormsCurveDot.h"

#pragma mark - SSJReportFormsCurveViewItem
#pragma mark -

typedef NS_ENUM(NSInteger, SSJCurveValueLabelLayoutStyle) {
    SSJCurveValueLabelLayoutStyleTop,
    SSJCurveValueLabelLayoutStyleBottom
};

@interface SSJReportFormsCurveViewItem ()

@property (nonatomic) SSJCurveValueLabelLayoutStyle labelLayoutStyle;

@end

@implementation SSJReportFormsCurveViewItem

- (instancetype)init {
    if (self = [super init]) {
        _labelLayoutStyle = SSJCurveValueLabelLayoutStyleBottom;
    }
    return self;
}

- (BOOL)isCurveInfoEqualToItem:(SSJReportFormsCurveViewItem *)item {
    return (CGColorEqualToColor(_curveColor.CGColor, item.curveColor.CGColor)
            && CGPointEqualToPoint(_startPoint, item.startPoint)
            && CGPointEqualToPoint(_endPoint, item.endPoint)
            && CGSizeEqualToSize(_shadowOffset, item.shadowOffset)
            && _showCurve == item.showCurve
            && _showShadow == item.showShadow
            && _shadowWidth == item.shadowWidth
            && _shadowAlpha == item.shadowAlpha
            && _curveWidth == item.curveWidth);
}

- (void)testOverlapPreItem:(SSJReportFormsCurveViewItem *)preItem space:(CGFloat)space {
    CGSize textSize = [self.value sizeWithAttributes:@{NSFontAttributeName:self.valueFont}];
    CGRect textFrame = CGRectMake(space + self.endPoint.x, self.endPoint.y, textSize.width, textSize.height);
    
    CGSize preTextSize = [preItem.value sizeWithAttributes:@{NSFontAttributeName:preItem.valueFont}];
    CGRect preTextFrame = CGRectMake(preItem.endPoint.x, preItem.endPoint.y, preTextSize.width, preTextSize.height);
    
    if (CGRectIntersectsRect(textFrame, preTextFrame)) {
        switch (preItem.labelLayoutStyle) {
            case SSJCurveValueLabelLayoutStyleTop:
                self.labelLayoutStyle = SSJCurveValueLabelLayoutStyleBottom;
                break;
                
            case SSJCurveValueLabelLayoutStyleBottom:
                self.labelLayoutStyle = SSJCurveValueLabelLayoutStyleTop;
                break;
        }
    }
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, @{@"showCurve":@(_showCurve),
                                                        @"startPoint":NSStringFromCGPoint(_startPoint),
                                                        @"endPoint":NSStringFromCGPoint(_endPoint),
                                                        @"curveWidth":@(_curveWidth),
                                                        @"curveColor":_curveColor ?: [NSNull null],
                                                        @"showShadow":@(_showShadow),
                                                        @"shadowWidth":@(_shadowWidth),
                                                        @"shadowOffset":NSStringFromCGSize(_shadowOffset),
                                                        @"shadowAlpha":@(_shadowAlpha),
                                                        @"showValue":@(_showValue),
                                                        @"value":_value ?: [NSNull null],
                                                        @"valueColor":_valueColor ?: [NSNull null],
                                                        @"valueFont":_valueFont ?: [NSNull null],
                                                        @"showDot":@(_showDot),
                                                        @"dotColor":_dotColor ?: [NSNull null],
                                                        @"dotAlpha":@(_dotAlpha)}];
}

@end

#pragma mark - _SSJReportFormsCurveShapeView
#pragma mark -

@interface _SSJReportFormsCurveShapeView : UIView

@property (nonatomic, strong, readonly) CAShapeLayer *layer;

@end

@implementation _SSJReportFormsCurveShapeView

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (CAShapeLayer *)layer {
    return (CAShapeLayer *)[super layer];
}

@end

#pragma mark - SSJReportFormsCurveView
#pragma mark -

@interface SSJReportFormsCurveView ()

@property (nonatomic, strong) UIBezierPath *curvePath;

@property (nonatomic, strong) _SSJReportFormsCurveShapeView *curveView;

@property (nonatomic, strong) SSJReportFormsCurveDot *dot;

@property (nonatomic, strong) UILabel *valueLab;

@property (nonatomic, strong) UIImageView *maskCurveView;

@property (nonatomic, strong) NSSet *observedCurveProperies;

@property (nonatomic, strong) NSSet *observedDotProperies;

@property (nonatomic, strong) NSSet *observedLabelProperies;

@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic) BOOL layouted;

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
        
        _curveView = [[_SSJReportFormsCurveShapeView alloc] init];
        [self addSubview:_curveView];
        
        _dot = [[SSJReportFormsCurveDot alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _dot.outerRadius = 8;
        _dot.innerRadius = 4;
        [self addSubview:_dot];
        
        _valueLab = [[UILabel alloc] init];
        [self addSubview:_valueLab];
        
        _maskCurveView = [[UIImageView alloc] init];
        [self addSubview:_maskCurveView];
        
//        _maskCurveView.layer.borderColor = [UIColor blackColor].CGColor;
//        _maskCurveView.layer.borderWidth = 1;
        
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    _dot.center = _item.endPoint;
    
    [_valueLab sizeToFit];
    switch (_item.labelLayoutStyle) {
        case SSJCurveValueLabelLayoutStyleTop:
            _valueLab.leftBottom = CGPointMake(_item.endPoint.x + _dot.outerRadius, _item.endPoint.y);
            break;
            
        case SSJCurveValueLabelLayoutStyleBottom:
            _valueLab.leftTop = CGPointMake(_item.endPoint.x + _dot.outerRadius, _item.endPoint.y);
            break;
    }
    
    _curveView.frame = self.bounds;
    _maskCurveView.frame = self.bounds;
    
    if (!_layouted) {
        _layouted = YES;
        [self takeScreenShot];
    }
}

//- (void)setFrame:(CGRect)frame {
//    [super setFrame:frame];
//    [self takeScreenShot];
//}

- (void)setItem:(SSJReportFormsCurveViewItem *)item {
    
    if (!item) {
        SSJPRINT(@"item不能为nil");
        return;
    }
    
//    BOOL needsToUpdateCurve = (!_item || ![_item isCurveInfoEqualToItem:item]);
    
    [self removeObserver];
    _item = item;
    [self addObserver];
    
    [self updateDot];
    [self updateValueLabel];
    
    if (_item.showCurve) {
        [self updateCurve];
        [self takeScreenShot];
    }
    
    [self setNeedsLayout];
}

- (void)updateCurve {
    if (!_item.showCurve) {
        _curveView.hidden = YES;
        return;
    }
    
    _curveView.hidden = NO;
    
    CGFloat offset = (_item.endPoint.x - _item.startPoint.x) * 0.35;
    CGPoint controlPoint1 = CGPointMake(_item.startPoint.x + offset, _item.startPoint.y);
    CGPoint controlPoint2 = CGPointMake(_item.endPoint.x - offset, _item.endPoint.y);
    
    [_curvePath removeAllPoints];
    [_curvePath moveToPoint:_item.startPoint];
    [_curvePath addCurveToPoint:_item.endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    
    _curveView.layer.path = _curvePath.CGPath;
    _curveView.layer.lineWidth = _item.curveWidth;
    _curveView.layer.strokeColor = _item.curveColor.CGColor;
    _curveView.layer.fillColor = [UIColor clearColor].CGColor;
    
    if (_item.showShadow) {
        _curveView.layer.shadowColor = _item.curveColor.CGColor;
        _curveView.layer.shadowOpacity = 0.3;
        _curveView.layer.shadowOffset = _item.shadowOffset;
        _curveView.layer.shadowRadius = 1.2;
    }
}

// 渲染成图片，铺在表面上，隐藏其它的界面元素，以提高流畅度
- (void)takeScreenShot {
    
    _maskCurveView.hidden = YES;
    [_queue cancelAllOperations];
    
    BOOL flag = NO;
    for (NSOperation *operation in [_queue operations]) {
        if (operation.isExecuting) {
            flag = YES;
            break;
        }
    }
    
    if (CGRectIsEmpty(_curveView.bounds) || _curveView.hidden) {
        return;
    }
    
    [_queue addOperationWithBlock:^{
        if (CGRectIsEmpty(_curveView.bounds) || _curveView.hidden) {
            return;
        }
        
        UIImage *screentShot = [_curveView ssj_takeScreenShotWithSize:_curveView.size opaque:NO scale:0];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (CGRectIsEmpty(_curveView.bounds) || _curveView.hidden) {
                return;
            }
            
            if (flag) {
                return;
            }
            
            _maskCurveView.image = screentShot;
            _maskCurveView.size = screentShot.size;
            
            _curveView.hidden = YES;
            _maskCurveView.hidden = NO;
        }];
    }];
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
        [self takeScreenShot];
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
