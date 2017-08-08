//
//  SSJMakeWishGuideView.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJMakeWishGuideView.h"

@interface SSJMakeWishGuideView ()
/**image*/
@property (nonatomic, strong) UIImageView *topImageView;

@property (nonatomic, strong) UILabel *titleL;

/**layer*/
@property (nonatomic, strong) CAShapeLayer *borderLayer;
@end

@implementation SSJMakeWishGuideView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer addSublayer:self.borderLayer];
        [self addSubview:self.topImageView];
        [self addSubview:self.titleL];
        [self drawBorderWithFrame:frame];
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.topImageView.centerX = self.width * 0.5;
    self.topImageView.top = 15;
    self.titleL.top = CGRectGetMaxY(self.topImageView.frame) + 15;
    self.titleL.left = 15;
    self.titleL.width = self.width - 30;
    self.titleL.height = 50;
}

#pragma mark - Private
- (void)show {
    if (self.superview) return;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    self.top = keyWindow.height;
    self.centerX = keyWindow.centerX;
    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor clearColor] alpha:1 target:self touchAction:@selector(dismiss) animation:^{
        self.bottom = keyWindow.height - 50;
    } timeInterval:0.25 fininshed:NULL];
}

- (void)dismiss {
    if (!self.superview) return;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [self.superview ssj_hideBackViewForView:self animation:^{
        self.top = keyWindow.bottom;
    } timeInterval:0.25 fininshed:^(BOOL complation) {
        [self removeFromSuperview];
    }];
}


- (void)drawBorderWithFrame:(CGRect)frame {
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    CGFloat triangleH = 9;
    CGFloat triagleWH = 10;
    CGFloat corners = 8;
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 4;
    [path moveToPoint:CGPointMake(width * 0.5, height)];
    [path addLineToPoint:CGPointMake(width * 0.5 - triagleWH, height-triangleH)];
    [path addLineToPoint:CGPointMake(corners, height-triangleH)];
    [path addArcWithCenter:CGPointMake(corners, height-triangleH-corners) radius:corners startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(0, corners)];
    [path addArcWithCenter:CGPointMake(corners, corners) radius:corners startAngle:M_PI endAngle:M_PI_2 * 3 clockwise:YES];
    [path addLineToPoint:CGPointMake(width-corners, 0)];
    [path addArcWithCenter:CGPointMake(width-corners, corners) radius:corners startAngle:M_PI_2 * 3 endAngle:M_PI * 2 clockwise:YES];
    [path addLineToPoint:CGPointMake(width, height-corners-triangleH)];
    [path addArcWithCenter:CGPointMake(width-corners, height-corners-triangleH) radius:corners startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(width * 0.5 + triagleWH, height-triangleH)];
    [path closePath];
    
    self.borderLayer.path = path.CGPath;
}

- (void)updateAppearance {
    self.titleL.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.borderLayer.strokeColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha].CGColor;
    self.borderLayer.fillColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainFillColor].CGColor;
}

#pragma mark - Setter
-(void)setImage:(NSString *)image {
    _image = image;
    self.topImageView.image = [UIImage imageNamed:image];
    [self.topImageView sizeToFit];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleL.text = title;
}

#pragma mark - Lazy
- (UIImageView *)topImageView {
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc] init];
    }
    return _topImageView;
}

- (UILabel *)titleL {
    if (!_titleL) {
        _titleL = [[UILabel alloc] init];
        _titleL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _titleL.textAlignment = NSTextAlignmentCenter;
        _titleL.numberOfLines = 0;
    }
    return _titleL;
}

- (CAShapeLayer *)borderLayer {
    if (!_borderLayer) {
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.lineWidth = 1.0f;
    }
    return _borderLayer;
}
@end
