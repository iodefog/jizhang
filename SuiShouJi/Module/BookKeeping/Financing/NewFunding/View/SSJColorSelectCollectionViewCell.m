//
//  SSJColorSelectCollectionViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJColorSelectCollectionViewCell.h"
@interface SSJColorSelectCollectionViewCell()
@property (nonatomic,strong) UIImageView *checkMarkImage;
@end

@implementation SSJColorSelectCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:self.itemColor];
        [self addSubview:self.checkMarkImage];
        self.checkMarkImage.hidden = YES;
    }
    return self;
}

-(void)layoutSubviews{
    _checkMarkImage.size = CGSizeMake(22, 22);
    _checkMarkImage.center = CGPointMake(self.width / 2, self.height / 2);
}

-(UIImageView *)checkMarkImage{
    if (!_checkMarkImage) {
        _checkMarkImage = [[UIImageView alloc]init];
        _checkMarkImage.tintColor = [UIColor whiteColor];
        _checkMarkImage.image = [[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    }
    return _checkMarkImage;
}

-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    if (_isSelected) {
        self.checkMarkImage.hidden = NO;
    }else{
        self.checkMarkImage.hidden = YES;
    }
}

-(void)setItemColor:(NSString *)itemColor{
    _itemColor = itemColor;
    self.backgroundColor = [UIColor ssj_colorWithHex:_itemColor];
}

@end
