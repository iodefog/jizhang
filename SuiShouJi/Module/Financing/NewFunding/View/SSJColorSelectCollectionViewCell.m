//
//  SSJColorSelectCollectionViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJColorSelectCollectionViewCell.h"


@interface SSJColorSelectCollectionViewCell()
@property (nonatomic,strong) CAGradientLayer *gradientLayer;
@end

@implementation SSJColorSelectCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
}

-(CAGradientLayer *)gradientLayer{
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.cornerRadius = 8;
    }
    return _gradientLayer;
}

-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
//    if (_isSelected == YES) {
//        [UIView animateWithDuration:0.2 animations:^{
//            self.smallCircleView.transform = CGAffineTransformMakeScale(2, 2);
//        }completion:nil];
//    }else{
//        self.smallCircleView.transform = CGAffineTransformMakeScale(1, 1);
//    }

}

-(void)setStartColor:(NSString *)startColor andEndColor:(NSString *)endColor{
    self.gradientLayer.colors = @[(__bridge id)[UIColor ssj_colorWithHex:startColor].CGColor,(__bridge id)[UIColor ssj_colorWithHex:endColor].CGColor];
}

@end
