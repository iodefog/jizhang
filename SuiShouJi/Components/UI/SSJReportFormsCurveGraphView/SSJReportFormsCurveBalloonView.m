//
//  SSJReportFormsCurveBalloonView.m
//  SSJCurveGraphView
//
//  Created by old lang on 16/12/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveBalloonView.h"

static const CGFloat kTailHeight = 4;

@interface SSJReportFormsCurveBalloonView ()

@property (nonatomic, strong) CAShapeLayer *headerLayer;

@property (nonatomic, strong) UIView *verticalLine;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation SSJReportFormsCurveBalloonView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _titleFont = [UIFont systemFontOfSize:12];
        _titleColor = [UIColor whiteColor];
        _ballonColor = [UIColor yellowColor];
        
        [self addSubview:self.verticalLine];
        [self.layer addSublayer:self.headerLayer];
        [self addSubview:self.titleLabel];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake([self titleRoundedSize].width, size.height);
}

- (void)layoutSubviews {
    _titleLabel.leftTop = CGPointZero;
    _titleLabel.size = [self titleRoundedSize];
    _verticalLine.size = CGSizeMake(1, self.height);
    _verticalLine.centerX = self.width * 0.5;
    [self updateHeader];
}

- (void)setTitle:(NSString *)title {
    if (![_title isEqualToString:title]) {
        _title = title;
        _titleLabel.text = _title;
        [self sizeToFit];
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    if (_titleFont.pointSize != titleFont.pointSize) {
        _titleFont = titleFont;
        _titleLabel.font = _titleFont;
        [self sizeToFit];
    }
}

- (void)setTitleColor:(UIColor *)titleColor {
    if (!CGColorEqualToColor(_titleColor.CGColor, titleColor.CGColor)) {
        _titleColor = titleColor;
        _titleLabel.textColor = _titleColor;
    }
}

- (void)setBallonColor:(UIColor *)ballonColor {
    if (!CGColorEqualToColor(_ballonColor.CGColor, ballonColor.CGColor)) {
        _ballonColor = ballonColor;
        _headerLayer.fillColor = _ballonColor.CGColor;
        _headerLayer.shadowColor = _ballonColor.CGColor;
        _verticalLine.backgroundColor = _ballonColor;
    }
}

- (CGSize)titleRoundedSize {
    CGSize titleSize = [_title sizeWithAttributes:@{NSFontAttributeName:_titleFont}];
    return CGSizeMake(titleSize.width + 20, titleSize.height + 6);
}

- (void)updateHeader {
    CGSize roundedSize = [self titleRoundedSize];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, roundedSize.width, roundedSize.height) cornerRadius:roundedSize.height * 0.5];
    [path moveToPoint:CGPointMake(self.width * 0.5, roundedSize.height + kTailHeight)];
    [path addLineToPoint:CGPointMake(self.width * 0.5 - kTailHeight, roundedSize.height)];
    [path addLineToPoint:CGPointMake(self.width * 0.5 + kTailHeight, roundedSize.height)];
    [path closePath];
    
    _headerLayer.path = path.CGPath;
}

- (CAShapeLayer *)headerLayer {
    if (!_headerLayer) {
        _headerLayer = [CAShapeLayer layer];
        _headerLayer.lineWidth = 0;
        _headerLayer.fillColor = _ballonColor.CGColor;
        _headerLayer.shadowColor = _ballonColor.CGColor;
        _headerLayer.shadowOpacity = 0.3;
        _headerLayer.shadowOffset = CGSizeMake(0, 10);
        _headerLayer.shadowRadius = 1;
    }
    return _headerLayer;
}

- (UIView *)verticalLine {
    if (!_verticalLine) {
        _verticalLine = [[UIView alloc] init];
        _verticalLine.backgroundColor = _ballonColor;
    }
    return _verticalLine;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = _title;
        _titleLabel.textColor = _titleColor;
        _titleLabel.font = _titleFont;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

@end
