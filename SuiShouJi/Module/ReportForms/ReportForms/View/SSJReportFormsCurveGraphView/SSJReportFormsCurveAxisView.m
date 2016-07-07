//
//  SSJReportFormsAxisView.m
//  SSJCurveGraphDemo
//
//  Created by old lang on 16/6/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveAxisView.h"

@interface SSJReportFormsCurveAxisView ()

@property (nonatomic, strong) NSMutableArray *labels;

@end

@implementation SSJReportFormsCurveAxisView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _labels = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)layoutSubviews {
    if (_labels.count > 1) {
        CGFloat unitWidth = (self.width - _margin) / (_labels.count - 1);
        for (int i = 0; i < _labels.count; i ++) {
            UILabel *label = _labels[i];
            label.center = CGPointMake(unitWidth * i + _margin, self.height * 0.5);
        }
    } else if (_labels.count == 1) {
        UILabel *label = _labels[0];
        label.center = CGPointMake(self.width, self.height * 0.5);
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    if (_labels.count > 1) {
        CGFloat unitWidth = (self.width - _margin) / (_labels.count - 1);
        for (int i = 0; i < _axisTitles.count; i ++) {
            CGContextMoveToPoint(ctx, unitWidth * i + _margin, 0);
            CGContextAddLineToPoint(ctx, unitWidth * i + _margin, 3);
        }
    } else {
        CGContextMoveToPoint(ctx, self.width, 0);
        CGContextAddLineToPoint(ctx, self.width, 3);
    }
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor ssj_colorWithHex:@"878787"].CGColor);
    CGContextSetLineWidth(ctx, 1 / [UIScreen mainScreen].scale);
    CGContextStrokePath(ctx);
}

- (void)setAxisTitles:(NSArray *)axisTitles {
    if (![_axisTitles isEqualToArray:axisTitles]) {
        _axisTitles = axisTitles;
        
        [_labels makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_labels removeAllObjects];
        
        for (int i = 0; i < _axisTitles.count; i ++) {
            UILabel *label = [[UILabel alloc] init];
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
            label.text = _axisTitles[i];
            [label sizeToFit];
            [self addSubview:label];
            [_labels addObject:label];
        }
        [self setNeedsDisplay];
    }
}

@end
