//
//  SSJBookColorSelectedCollectionViewCell.m
//  SuiShouJi
//
//  Created by yi cai on 2017/5/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBookColorSelectedCollectionViewCell.h"
#import "SSJFinancingGradientColorItem.h"

@interface SSJBookColorSelectedCollectionViewCell ()
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
/**<#注释#>*/
@property (nonatomic, strong) CAShapeLayer *sharpLayer;
@end
@implementation SSJBookColorSelectedCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer addSublayer:self.gradientLayer];
    }
    return self;
}
- (void)setColorSelected:(BOOL)colorSelected {
    if (_colorSelected != colorSelected) {
        if (colorSelected) {
            CGFloat itemWidth = (SSJSCREENWITH - 96) / 4 + 5;
            CGRect itemRect = CGRectMake(-2.5, -2.5, itemWidth, 45);
            self.gradientLayer.frame = itemRect;
            self.sharpLayer.path = [UIBezierPath bezierPathWithRoundedRect:_gradientLayer.bounds cornerRadius:8].CGPath;
            _gradientLayer.mask = self.sharpLayer;
            
        } else {
            CGFloat itemWidth = (SSJSCREENWITH - 96) / 4;
            CGRect itemRect = CGRectMake(0, 0, itemWidth, 40);
            self.gradientLayer.frame = itemRect;
            self.sharpLayer.path = [UIBezierPath bezierPathWithRoundedRect:_gradientLayer.bounds cornerRadius:6].CGPath;
            _gradientLayer.mask = self.sharpLayer;
        }
        _colorSelected = colorSelected;
    }

}

- (void)setItemColor:(SSJFinancingGradientColorItem *)itemColor {
    _itemColor = itemColor;
    self.gradientLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:_itemColor.startColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:_itemColor.endColor].CGColor];
    self.gradientLayer.shadowColor = [UIColor ssj_colorWithHex:_itemColor.startColor].CGColor;
    if (self.itemColor.isSelected) {
        self.gradientLayer.shadowOpacity = 0.4;
    } else {
        self.gradientLayer.shadowOpacity = 0;
    }
}

#pragma mark - Lazy
- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        CGFloat itemWidth = (SSJSCREENWITH - 96) / 4;
        CGRect itemRect = CGRectMake(0, 0, itemWidth, 40);
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = itemRect;
        self.sharpLayer.path = [UIBezierPath bezierPathWithRoundedRect:_gradientLayer.bounds cornerRadius:6].CGPath;
        _gradientLayer.mask = self.sharpLayer;
        _gradientLayer.startPoint = CGPointMake(0, 0.5);
        _gradientLayer.endPoint = CGPointMake(1, 0.5);
    }
    return _gradientLayer;
}

- (CAShapeLayer *)sharpLayer {
    if (!_sharpLayer) {
        _sharpLayer = [CAShapeLayer layer];
    }
    return _sharpLayer;
}

@end
