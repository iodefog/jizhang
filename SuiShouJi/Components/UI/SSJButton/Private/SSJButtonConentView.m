//
//  SSJButtonConentView.m
//  SuiShouJi
//
//  Created by old lang on 17/3/19.
//  Copyright © 2017年 MZL. All rights reserved.
//

#import "SSJButtonConentView.h"
#import "Masonry.h"

@interface SSJButtonConentView ()

@property (nonatomic, strong) UIView *container;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic) BOOL needUpdateAppearance;

@end

@implementation SSJButtonConentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.backgroundImageView];
        [self addSubview:self.container];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)updateConstraints {
    [self.backgroundImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    switch (self.layoutStyle) {
        case SSJButtonLayoutStyleImageAndTitleCenter: {
            [self.container mas_updateConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(self);
            }];
            [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.center.mas_equalTo(self.container);
                make.size.mas_equalTo(self.imageView.image.size);
            }];
            [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.center.mas_equalTo(self.container);
            }];
        }
            break;
            
        case SSJButtonLayoutStyleImageLeftTitleRight: {
            [self.container mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.imageView.mas_left);
                make.right.mas_equalTo(self.titleLabel.mas_right);
                make.height.mas_equalTo(CGRectGetHeight(self.bounds));
                make.centerX.mas_equalTo(CGRectGetMidX(self.bounds));
                make.centerY.mas_equalTo(CGRectGetMidY(self.bounds));
            }];
            [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.container);
                make.left.mas_equalTo(0);
                make.size.mas_equalTo(self.imageView.image.size);
            }];
            [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.container);
                make.left.mas_equalTo(self.imageView.mas_right).offset(self.spaceBetweenImageAndTitle);
            }];
        }
            break;
            
        case SSJButtonLayoutStyleImageRightTitleLeft: {
            [self.container mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.titleLabel.mas_left);
                make.right.mas_equalTo(self.imageView.mas_right);
                make.height.mas_equalTo(CGRectGetHeight(self.bounds));
                make.centerX.mas_equalTo(CGRectGetMidX(self.bounds));
                make.centerY.mas_equalTo(CGRectGetMidY(self.bounds));
            }];
            [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.container);
                make.left.mas_equalTo(self.titleLabel.mas_right).offset(self.spaceBetweenImageAndTitle);
                make.size.mas_equalTo(self.imageView.image.size);
            }];
            [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.container);
                make.left.mas_equalTo(0);
            }];
        }
            break;
            
        case SSJButtonLayoutStyleImageTopTitleBottom: {
            [self.container mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.imageView.mas_top);
                make.bottom.mas_equalTo(self.titleLabel.mas_bottom);
                make.width.mas_equalTo(CGRectGetWidth(self.bounds));
                make.centerX.mas_equalTo(CGRectGetMidX(self.bounds));
                make.centerY.mas_equalTo(CGRectGetMidY(self.bounds));
            }];
            [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.centerX.mas_equalTo(self.container);
                make.size.mas_equalTo(self.imageView.image.size);
            }];
            [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(self.spaceBetweenImageAndTitle);
                make.centerX.mas_equalTo(self.container);
            }];
        }
            break;
            
        case SSJButtonLayoutStyleImageBottomTitleTop: {
            [self.container mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.titleLabel.mas_top);
                make.bottom.mas_equalTo(self.imageView.mas_bottom);
                make.width.mas_equalTo(CGRectGetWidth(self.bounds));
                make.centerX.mas_equalTo(CGRectGetMidX(self.bounds));
                make.centerY.mas_equalTo(CGRectGetMidY(self.bounds));
            }];
            [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(self.spaceBetweenImageAndTitle);
                make.centerX.mas_equalTo(self.container);
                make.size.mas_equalTo(self.imageView.image.size);
            }];
            [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
                make.centerX.mas_equalTo(self.container);
            }];
        }
            break;
            
        case SSJButtonLayoutStyleCustom: {
            [self.container mas_updateConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(self);
            }];
            [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
                CGRect layoutRect = UIEdgeInsetsInsetRect(self.bounds, self.imageInset);
                make.center.mas_equalTo(CGPointMake(CGRectGetMidX(layoutRect), CGRectGetMidY(layoutRect)));
            }];
            [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                CGRect layoutRect = UIEdgeInsetsInsetRect(self.bounds, self.titleInset);
                make.center.mas_equalTo(CGPointMake(CGRectGetMidX(layoutRect), CGRectGetMidY(layoutRect)));
                make.left.mas_greaterThanOrEqualTo(self.titleInset.left);
            }];
        }
            break;
    }
    
    [super updateConstraints];
}

- (void)setTitleInset:(UIEdgeInsets)titleInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_titleInset, titleInset)) {
        _titleInset = titleInset;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setImageInset:(UIEdgeInsets)imageInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_imageInset, imageInset)) {
        _imageInset = imageInset;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setSpaceBetweenImageAndTitle:(CGFloat)spaceBetweenImageAndTitle {
    if (_spaceBetweenImageAndTitle != spaceBetweenImageAndTitle) {
        _spaceBetweenImageAndTitle = spaceBetweenImageAndTitle;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setLayoutStyle:(SSJButtonLayoutStyle)layoutStyle {
    if (_layoutStyle != layoutStyle) {
        _layoutStyle = layoutStyle;
        [self setNeedsUpdateConstraints];
    }
}

#pragma mark - Lazyloading
- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] init];
        _container.userInteractionEnabled = NO;
        [_container addSubview:self.imageView];
        [_container addSubview:self.titleLabel];
    }
    return _container;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
    }
    return _titleLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
    }
    return _backgroundImageView;
}

@end
