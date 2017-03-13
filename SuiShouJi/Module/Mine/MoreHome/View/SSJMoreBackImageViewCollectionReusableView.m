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

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backImage.frame = CGRectMake(0, 0, self.width, self.height);
}

- (UIImageView *)backImage {
    if (!_backImage) {
        _backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _backImage.image = [UIImage imageNamed:@"more_bottom_bgimage"];
    }
    return _backImage;
}

@end
