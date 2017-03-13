//
//  SSJMoreBackImageViewCollectionReusableView.m
//  SuiShouJi
//
//  Created by ricky on 2017/3/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJMoreBackImageViewCollectionReusableView.h"

@interface SSJMoreBackImageViewCollectionReusableView()

@property(nonatomic, strong) UIImageView *backImage;

@end

@implementation SSJMoreBackImageViewCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.backImage];
    }
    return self;
}

- (UIImageView *)backImage {
    if (!_backImage) {
        _backImage = [[UIImageView alloc] initWithFrame:self.bounds];
        _backImage.image = [UIImage imageNamed:@"more_bottom_bgimage"];
    }
    return _backImage;
}

@end
