//
//  SSJReportFormsCurveGridView.m
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveGridView.h"

@interface SSJReportFormsCurveGridView ()

@property (nonatomic) NSUInteger horizontalLineCount;

@property (nonatomic, strong) NSMutableArray *spaceNumbers;

@property (nonatomic, strong) NSMutableArray *titles;

@end

@implementation SSJReportFormsCurveGridView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _titleFont = [UIFont systemFontOfSize:12];
        _titleColor = [UIColor grayColor];
        _lineColor = [UIColor grayColor];
        _lineWith = 1 / [UIScreen mainScreen].scale;
        
        _spaceNumbers = [[NSMutableArray alloc] init];
        _titles = [[NSMutableArray alloc] init];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, _lineWith);
    CGContextSetStrokeColorWithColor(ctx, _lineColor.CGColor);
    
    CGFloat space = 0;
    
    for (int idx = 0; idx < _horizontalLineCount; idx ++) {
        space += [_spaceNumbers[idx] floatValue];
        NSString *title = _titles[idx];
        
        CGContextMoveToPoint(ctx, 0, space);
        CGContextAddLineToPoint(ctx, self.width, space);
        
        NSDictionary *titleAttributes = @{NSFontAttributeName:_titleFont,
                                          NSForegroundColorAttributeName:_titleColor};
        CGSize size = [title sizeWithAttributes:titleAttributes];
        [title drawInRect:CGRectMake(2, space - 2 - size.height, size.width, size.height) withAttributes:titleAttributes];
    }
    
    CGContextDrawPath(ctx, kCGPathStroke);
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    [self setNeedsDisplay];
}

- (void)setTitleColor:(UIColor *)titleColor {
    if (!CGColorEqualToColor(_titleColor.CGColor, titleColor.CGColor)) {
        _titleColor = titleColor;
        [self setNeedsDisplay];
    }
}

- (void)setLineColor:(UIColor *)lineColor {
    if (!CGColorEqualToColor(_lineColor.CGColor, lineColor.CGColor)) {
        _lineColor = lineColor;
        [self setNeedsDisplay];
    }
}

- (void)setLineWith:(CGFloat)lineWith {
    if (_lineWith != lineWith) {
        _lineWith = lineWith;
        [self setNeedsDisplay];
    }
}

- (void)reloadData {
    if (!_dataSource
        || ![_dataSource respondsToSelector:@selector(numberOfHorizontalLineInGridView:)]
        || ![_dataSource respondsToSelector:@selector(gridView:headerSpaceOnHorizontalLineAtIndex:)]
        || ![_dataSource respondsToSelector:@selector(gridView:titleAtIndex:)]) {
        return;
    }
    
    [_spaceNumbers removeAllObjects];
    [_titles removeAllObjects];
    
    _horizontalLineCount = [_dataSource numberOfHorizontalLineInGridView:self];
    
    for (int idx = 0; idx < _horizontalLineCount; idx ++) {
        CGFloat space = [_dataSource gridView:self headerSpaceOnHorizontalLineAtIndex:idx];
        [_spaceNumbers addObject:@(space)];
        
        NSString *title = [_dataSource gridView:self titleAtIndex:idx];
        [_titles addObject:(title ?: @"")];
    }
    
    [self setNeedsDisplay];
}

@end
