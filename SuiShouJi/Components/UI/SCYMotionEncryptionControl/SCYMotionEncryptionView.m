//
//  SCYMotionEncryptionView.m
//  SCYMotionEncryptionDemo
//
//  Created by old lang on 15-3-22.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SCYMotionEncryptionView.h"
#import "SCYMotionEncryptionCircleLayer.h"
#import "SCYMotionEncryptionStrokeLayer.h"
#import "SCYMotionEncryptionTriangleLayer.h"

@interface SCYMotionEncryptionView () {
    SCYMotionEncryptionCircleLayer *_lastTouchedCircle;
}

@property (nonatomic, strong) NSMutableArray *circlesArray;

@property (nonatomic, strong) NSMutableArray *numbersArray;

@property (nonatomic, strong) SCYMotionEncryptionStrokeLayer *strokeLayer;

@property (nonatomic, assign) CGPoint touchPoint;

@property (nonatomic, strong) NSMutableDictionary *pointInfo;

@end

@implementation SCYMotionEncryptionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _pointInfo = [NSMutableDictionary dictionary];
        _circlesArray = [NSMutableArray array];
        _numbersArray = [NSMutableArray array];
        _layout = SCYMotionEncryptionLayoutMake(3, 3);
        [self reload];
        
        _strokeLayer = [SCYMotionEncryptionStrokeLayer layer];
        [self.layer addSublayer:_strokeLayer];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    if (_circleRadius <= 0 && SCYMotionEncryptionLayoutEqualToLayout(_layout, SCYMotionEncryptionLayoutZero)) {
        return;
    }
    
    _strokeLayer.frame = self.bounds;
    
    CGRect contentRect = UIEdgeInsetsInsetRect(self.bounds, _contentInsets);
    CGFloat horizontal_space = 0.0;
    CGFloat vertical_space = 0.0;
    if (_layout.numberOfColumns > 1) {
        horizontal_space = (contentRect.size.width - _circleRadius * 2 * _layout.numberOfColumns) / (_layout.numberOfColumns - 1);
    }
    if (_layout.numberOfRows > 1) {
        vertical_space = (contentRect.size.height - _circleRadius * 2 * _layout.numberOfRows) / (_layout.numberOfRows - 1);
    }
    
    [_pointInfo removeAllObjects];
    for (int row = 0; row < _layout.numberOfRows; row ++) {
        for (int column = 0; column < _layout.numberOfColumns; column ++) {
            int index = row * (int)_layout.numberOfColumns + column;
            if (_circlesArray.count > index) {
                @autoreleasepool {
                    SCYMotionEncryptionCircleLayer *circleLayer = _circlesArray[index];
                    CGFloat center_x = contentRect.origin.x + _circleRadius + (_circleRadius * 2 + horizontal_space) * column;
                    CGFloat center_y = contentRect.origin.y + _circleRadius + (_circleRadius * 2 + vertical_space) * row;
                    circleLayer.radius = _circleRadius;
                    circleLayer.position = CGPointMake(center_x, center_y);
                    
                    [_pointInfo setObject:[NSValue valueWithCGPoint:CGPointMake(center_x, center_y)] forKey:@(index)];
                }
            }
        }
    }
}

#pragma mark - Public
- (void)setStrokeColorInfo:(NSDictionary<NSNumber *,UIColor *> *)strokeColorInfo {
    self.strokeLayer.strokeColorInfo = strokeColorInfo;
}

- (void)setCircleRadius:(CGFloat)circleRadius {
    if (_circleRadius != circleRadius) {
        _circleRadius = circleRadius;
        [self setNeedsLayout];
    }
}

- (void)setImageInfo:(NSDictionary *)imageInfo {
    if (![_imageInfo isEqualToDictionary:imageInfo]) {
        _imageInfo = imageInfo;
        [_circlesArray makeObjectsPerformSelector:@selector(setImageInfo:) withObject:_imageInfo];
    }
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_contentInsets, contentInsets)) {
        _contentInsets = contentInsets;
        [self setNeedsLayout];
    }
}

- (void)setLayout:(SCYMotionEncryptionLayout)layout {
    if (!SCYMotionEncryptionLayoutEqualToLayout(_layout, layout)) {
        _layout = layout;
        [self reload];
        [self setNeedsLayout];
    }
}

- (NSArray *)allKeypads {
    NSInteger count = _layout.numberOfRows * _layout.numberOfColumns;
    NSMutableArray *keypads = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i < _layout.numberOfRows * _layout.numberOfColumns; i ++) {
        [keypads addObject:@(i)];
    }
    return [keypads copy];
}

- (void)setKeypads:(nullable NSArray *)keypads toStatus:(SCYMotionEncryptionCircleLayerStatus)status {
    [_numbersArray removeAllObjects];
    [_numbersArray addObjectsFromArray:keypads];
    [self p_updateCirclesStatus:status];
}

#pragma mark - Private
- (void)reload {
    [_circlesArray makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    for (int i = 0; i < _layout.numberOfRows * _layout.numberOfColumns; i ++) {
        @autoreleasepool {
            SCYMotionEncryptionCircleLayer *circleLayer = [SCYMotionEncryptionCircleLayer layer];
            circleLayer.radius = _circleRadius;
            circleLayer.imageInfo = self.imageInfo;
            circleLayer.status = SCYMotionEncryptionCircleLayerStatusDefault;
            [self.layer addSublayer:circleLayer];
            [_circlesArray addObject:circleLayer];
        }
    }
}

/* 返回当前触点是否在圆的范围之内 */
- (BOOL)p_containPoint:(CGPoint)point withCenter:(CGPoint)center {
    BOOL isContain = (pow((center.x - point.x), 2) + pow((center.y - point.y), 2) < pow(_circleRadius, 2));
    return isContain;
}

/* 返回当前触点范围内的圆 */
- (SCYMotionEncryptionCircleLayer *)p_motionTouchInCircle {
    for (int idx = 0; idx < _circlesArray.count; idx ++) {
        SCYMotionEncryptionCircleLayer *circleLayer = _circlesArray[idx];
        if (![circleLayer isKindOfClass:[SCYMotionEncryptionCircleLayer class]]) {
            continue;
        }
        if (![self p_containPoint:_touchPoint withCenter:circleLayer.position]) {
            continue;
        }
        if ([_numbersArray containsObject:@(idx)]) {
            continue;
        }
        _lastTouchedCircle = circleLayer;
        return circleLayer;
    }
    return nil;
}

/*  */
- (void)p_motionTouchesBegin {
    SCYMotionEncryptionCircleLayer *circle = [self p_motionTouchInCircle];
    if (circle) {
        NSUInteger idx = [_circlesArray indexOfObject:circle];
        [_numbersArray addObject:@(idx)];
        circle.status = SCYMotionEncryptionCircleLayerStatusCorrect;
        if (_delegate && [_delegate respondsToSelector:@selector(motionView:didSelectKeypads:)]) {
            [_delegate motionView:self didSelectKeypads:[_numbersArray copy]];
        }
    }
}

/*  */
- (NSMutableArray *)p_pointsArray {
    NSMutableArray *pointsArray = [NSMutableArray arrayWithCapacity:_numbersArray.count];
    for (int idx = 0; idx < _numbersArray.count; idx ++) {
        
        NSNumber *currentNumber = _numbersArray[idx];
        CGPoint currentPoint = [_pointInfo[currentNumber] CGPointValue];
        
        if (idx + 1 < _numbersArray.count) {
            NSNumber *nextNumber = _numbersArray[idx + 1];
            CGPoint nextPoint = [_pointInfo[nextNumber] CGPointValue];
            SCYMotionEncryptionPoints points = [self p_caculatePointsWithPoint1:currentPoint point2:nextPoint];
            NSValue *pointsValue = [NSValue valueWithSCYMotionEncryptionPoints:points];
            [pointsArray addObject:pointsValue];
        } else {
            if (![self p_containPoint:_touchPoint withCenter:currentPoint]) {
                CGPoint relativePoint = [self p_caculateRelativePointWithPoint1:currentPoint point2:_touchPoint];
                CGPoint startPoint = CGPointMake(currentPoint.x + relativePoint.x, currentPoint.y + relativePoint.y);
                CGPoint endPoint = _touchPoint;
                SCYMotionEncryptionPoints points = SCYMotionEncryptionPointsMake(startPoint, endPoint);
                NSValue *pointsValue = [NSValue valueWithSCYMotionEncryptionPoints:points];
                [pointsArray addObject:pointsValue];
            }
        }
    }
    return pointsArray;
}

/*  */
- (SCYMotionEncryptionPoints)p_caculatePointsWithPoint1:(CGPoint)point1 point2:(CGPoint)point2 {
    CGPoint relativePoint = [self p_caculateRelativePointWithPoint1:point1 point2:point2];
    CGPoint startPoint = CGPointMake(point1.x + relativePoint.x, point1.y + relativePoint.y);
    CGPoint endPoint = CGPointMake(point2.x - relativePoint.x, point2.y - relativePoint.y);
    return SCYMotionEncryptionPointsMake(startPoint, endPoint);
}

/*  */
- (CGPoint)p_caculateRelativePointWithPoint1:(CGPoint)point1 point2:(CGPoint)point2 {
    CGFloat horizontalSpace = (point2.x - point1.x);
    CGFloat verticalSpace = (point2.y - point1.y);
    CGFloat hypotenuse = sqrt(pow(horizontalSpace, 2) + pow(verticalSpace, 2));
    
    CGFloat point_x = horizontalSpace / hypotenuse * _circleRadius;
    CGFloat point_y = verticalSpace / hypotenuse * _circleRadius;
    return CGPointMake(point_x, point_y);
}

/* 更新圆圈的外观状态 */
- (void)p_updateCirclesStatus:(SCYMotionEncryptionCircleLayerStatus)status {
    for (NSNumber *number in _numbersArray) {
        int idx = [number intValue];
        if (_circlesArray.count > idx) {
            SCYMotionEncryptionCircleLayer *circleLayer = _circlesArray[idx];
            circleLayer.status = status;
        }
    }
}

#pragma mark - Touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch* touch = [touches anyObject];
    _touchPoint = [touch locationInView:self];
    [self p_motionTouchesBegin];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch* touch = [touches anyObject];
    _touchPoint = [touch locationInView:self];
    [self p_motionTouchesBegin];
    
    if (_numbersArray.count == 0) {
        return;
    }
    
    if (self.showStroke) {
        _strokeLayer.pointsArray = nil;
        _strokeLayer.pointsArray = [self p_pointsArray];
        _strokeLayer.status = SCYMotionEncryptionCircleLayerStatusDefault;
        [_strokeLayer setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (_numbersArray.count == 0) {
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(motionView:didFinishSelectKeypads:)]) {
        SCYMotionEncryptionCircleLayerStatus status = [_delegate motionView:self didFinishSelectKeypads:[_numbersArray copy]];
        [self p_updateCirclesStatus:status];
        if (_showStroke) {
            _strokeLayer.status = status;
            [_strokeLayer setNeedsDisplay];
        }
    }
    
    self.userInteractionEnabled = NO;
    double delayInSeconds = 0.4;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self p_updateCirclesStatus:SCYMotionEncryptionCircleLayerStatusDefault];
        [self.numbersArray removeAllObjects];
        self.strokeLayer.pointsArray = nil;
        [self.strokeLayer setNeedsDisplay];
        self.userInteractionEnabled = YES;
    });
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

@end
