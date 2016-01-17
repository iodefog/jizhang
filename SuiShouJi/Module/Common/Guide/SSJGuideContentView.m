//
//  SSJGuideContentView.m
//  MoneyMore
//
//  Created by old lang on 15-5-7.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJGuideContentView.h"

@interface SSJGuideContentView ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation SSJGuideContentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.center = CGPointMake(self.width * 0.5, self.height * 0.43);
}

- (void)setImageName:(NSString *)imageName {
    if (![_imageName isEqualToString:imageName]) {
        _imageName = [imageName copy];
        self.imageView.image = [UIImage imageNamed:imageName];
        [self.imageView sizeToFit];
        [self setNeedsLayout];
    }
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

@end
