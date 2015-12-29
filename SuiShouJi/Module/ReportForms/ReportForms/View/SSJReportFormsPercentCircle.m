//
//  SSJReportFormsPercentCircle.m
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJReportFormsPercentCircle.h"

@interface SSJReportFormsPercentCircle ()

@property (nonatomic, strong) NSMutableArray *layers;
@property (nonatomic) CGRect circleFrame;

@end

@implementation SSJReportFormsPercentCircle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layers = [NSMutableArray array];
    }
    return self;
}

- (void)layoutSubviews {
    [self updateCircleFrame];
    [self reloadData];
    
//    for (CAShapeLayer *layer in self.layers) {
//        layer.frame = self.circleFrame;
//    }
}

- (void)setCircleInsets:(UIEdgeInsets)circleInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_circleInsets, circleInsets)) {
        _circleInsets = circleInsets;
        [self updateCircleFrame];
        [self reloadData];
        [self setNeedsLayout];
    }
}

- (void)setCircleWidth:(CGFloat)circleWidth {
    if (_circleWidth != circleWidth) {
        _circleWidth = circleWidth;
        [self reloadData];
        [self setNeedsLayout];
    }
}

- (void)setDataSource:(id<SSJReportFormsPercentCircleDataSource>)dataSource {
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        [self reloadData];
        [self setNeedsLayout];
    }
}

- (void)reloadData {
    
    if (!self.dataSource
        || CGRectIsEmpty(self.bounds)
        || CGRectIsEmpty(self.circleFrame)
        || self.circleWidth <= 0) {
        return;
    }
    
    if ([self.dataSource respondsToSelector:@selector(numberOfComponentsInPercentCircle:)]) {
        
        NSUInteger numberOfComponents = [self.dataSource numberOfComponentsInPercentCircle:self];
        
        for (NSUInteger idx = 0; idx < numberOfComponents; idx ++) {
            
            if ([self.dataSource respondsToSelector:@selector(percentCircle:itemForComponentAtIndex:)]) {
                SSJReportFormsPercentCircleItem *item = [self.dataSource percentCircle:self itemForComponentAtIndex:idx];
                if (!item) {
                    return;
                }
                
                UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.circleFrame), CGRectGetMidY(self.circleFrame)) radius:(CGRectGetWidth(self.circleFrame) - self.circleWidth * 0.5) * 0.5 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
                
                [self.layers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
                
                CAShapeLayer *layer = [CAShapeLayer layer];
                layer.path = circlePath.CGPath;
                layer.fillColor = [UIColor whiteColor].CGColor;
                layer.lineWidth = self.circleWidth;
                layer.strokeColor = item.color.CGColor;
                layer.strokeEnd = item.scale;
                [self.layer addSublayer:layer];
                [self.layers addObject:layer];
            }
        }
        
        
    }
}

- (void)updateCircleFrame {
    CGRect circleFrame = UIEdgeInsetsInsetRect(self.bounds, self.circleInsets);
    CGFloat circleRadius = MIN(circleFrame.size.width, circleFrame.size.height);
    self.circleFrame = CGRectMake(circleFrame.origin.x, circleFrame.origin.y, circleRadius, circleRadius);
}

@end
