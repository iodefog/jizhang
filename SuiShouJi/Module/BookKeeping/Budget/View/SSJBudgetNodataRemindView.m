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

@property (nonatomic, strong) UILabel *subTitleLab;

@end

@implementation SSJBudgetNodataRemindView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        [self addSubview:self.titleLab];
        [self addSubview:self.subTitleLab];
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat y = (self.height - _imageView.height - _titleLab.height - kVerticalGap) * 0.5;
    
    _imageView.top = y;
    self.titleLab.top = _imageView.bottom + kVerticalGap;
    _imageView.centerX = _titleLab.centerX = self.width * 0.5;
    self.subTitleLab.top = CGRectGetMaxY(self.titleLab.frame) + 35;
    self.subTitleLab.centerX = self.titleLab.centerX;
}

- (CGSize)sizeThatFits:(CGSize)size {
    [_imageView sizeToFit];
    [_titleLab sizeToFit];
    CGFloat subW = MAX(_imageView.width, _titleLab.width);
    return CGSizeMake(MAX(subW, self.subTitleLab.width), CGRectGetMaxY(self.subTitleLab.frame));
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
        [self.titleLab sizeToFit];
        [self sizeToFit];
    }
}

- (void)setSubTitle:(NSString *)subTitle {
    if (![_subTitle isEqualToString:subTitle]) {
        _subTitle = subTitle;
        _subTitleLab.text = subTitle;
        [self.subTitleLab sizeToFit];
        [self sizeToFit];
    }
}

- (void)updateAppearance {
    _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _subTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
}

#pragma mark - Lazy
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.numberOfLines = 0;
        
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

- (UILabel *)subTitleLab {
    if (!_subTitleLab) {
        _subTitleLab = [[UILabel alloc] init];
        _subTitleLab.numberOfLines = 0;
        _subTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _subTitleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _subTitleLab;
}



@end
