//
//  SSJColorSelectCollectionViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJGradientColorSelectCollectionViewCell.h"

@interface SSJGradientColorSelectCollectionViewCell()

@property (nonatomic,strong) CAGradientLayer *gradientLayer;

@end

@implementation SSJGradientColorSelectCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer addSublayer:self.gradientLayer];
        self.clipsToBounds = NO;
    }
    return self;
}

- (void)dealloc {
    [self removeOberver];
}


-(CAGradientLayer *)gradientLayer{
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = self.bounds;
        _gradientLayer.startPoint = CGPointMake(0, 0.5);
        _gradientLayer.endPoint = CGPointMake(1, 0.5);
        _gradientLayer.cornerRadius = 8;
        _gradientLayer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.width + 2, self.height + 2) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(8, 8)].CGPath;
    }
    return _gradientLayer;
}

-(void)setItemColor:(SSJFinancingGradientColorItem *)itemColor{
    [self removeOberver];
    _itemColor = itemColor;
    [self addObesever];
    [self updateAppearance];
}

- (void)removeOberver{
    [_itemColor removeObserver:self forKeyPath:@"startColor"];
    [_itemColor removeObserver:self forKeyPath:@"endColor"];
    [_itemColor removeObserver:self forKeyPath:@"isSelected"];
}

- (void)addObesever{
    [_itemColor addObserver:self forKeyPath:@"startColor" options:NSKeyValueObservingOptionNew context:NULL];
    [_itemColor addObserver:self forKeyPath:@"endColor" options:NSKeyValueObservingOptionNew context:NULL];
    [_itemColor addObserver:self forKeyPath:@"isSelected" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    [self updateAppearance];
}

- (void)updateAppearance{
    self.gradientLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:_itemColor.startColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:_itemColor.endColor].CGColor];
    self.gradientLayer.shadowColor = [UIColor ssj_colorWithHex:_itemColor.startColor].CGColor;
    if (self.itemColor.isSelected) {
        self.gradientLayer.shadowOpacity = 0.4;
    } else {
        self.gradientLayer.shadowOpacity = 0;
    }
}

@end
