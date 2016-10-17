//
//  SSJBudgetNodataRemindView.m
//  SuiShouJi
//
//  Created by old lang on 16/7/15.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetNodataRemindView.h"

static const CGFloat kVerticalGap = 10;

@interface SSJBudgetNodataRemindView ()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation SSJBudgetNodataRemindView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        
        _titleLab = [[UILabel alloc] init];
        _titleLab.numberOfLines = 0;
        
        _titleLab.font = [UIFont systemFontOfSize:18];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        [self addSubview:_titleLab];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat y = (self.height - _imageView.height - _titleLab.height - kVerticalGap) * 0.5;
    
    _imageView.top = y;
    _titleLab.top = _imageView.bottom + kVerticalGap;
    _imageView.centerX = _titleLab.centerX = self.width * 0.5;
}

- (CGSize)sizeThatFits:(CGSize)size {
    [_imageView sizeToFit];
    [_titleLab sizeToFit];
    
    return CGSizeMake(MAX(_imageView.width, _titleLab.width), _imageView.height + _titleLab.height + kVerticalGap);
}

- (void)setImage:(NSString *)image {
    if (![_image isEqualToString:image]) {
        _image = image;
        _imageView.image = [UIImage imageNamed:_image];
        [self sizeToFit];
    }
}

- (void)setTitle:(NSString *)title {
    if (![_title isEqualToString:title]) {
        _title = title;
        _titleLab.text = title;
        [self sizeToFit];
    }
}

- (void)updateAppearance {
    _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

@end
