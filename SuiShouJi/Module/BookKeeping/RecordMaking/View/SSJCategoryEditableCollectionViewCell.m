//
//  SSJCategoryEditableCollectionViewCell.m
//  SuiShouJi
//
//  Created by old lang on 16/8/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCategoryEditableCollectionViewCell.h"

@interface SSJCategoryEditableCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIImageView *additionView;

@end

@implementation SSJCategoryEditableCollectionViewCell

- (void)dealloc {
    [self removeObserver];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.titleLab];
        [self.contentView addSubview:self.additionView];
        
//        self.layer.borderColor = [UIColor redColor].CGColor;
//        self.layer.borderWidth = 1;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_titleLab sizeToFit];
    
    CGFloat gap = (self.contentView.height - _imageView.height - _titleLab.height) * 0.33;
    _imageView.top = gap;
    _titleLab.top = _imageView.bottom + gap;
    _imageView.centerX = _titleLab.centerX = self.contentView.width * 0.5;
    _additionView.rightTop = CGPointMake(self.contentView.width - 5, 5);
}

- (void)setItem:(SSJCategoryEditableCollectionViewCellItem *)item {
    [self removeObserver];
    _item = item;
    [self addObserver];
    [self updateAppearance];
    [self setNeedsLayout];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    [self updateAppearance];
}

#pragma mark - Private
- (void)updateAppearance {
    _imageView.image = [[UIImage imageNamed:_item.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _imageView.tintColor = _item.imageTintColor;
    _imageView.backgroundColor = _item.imageBackgroundColor;
    _titleLab.text = _item.title;
    _titleLab.textColor = _item.titleColor;
    _additionView.image = [UIImage imageNamed:_item.additionImageName];
}

- (void)addObserver {
    [_item addObserver:self forKeyPath:@"imageTintColor" options:NSKeyValueObservingOptionNew context:NULL];
    [_item addObserver:self forKeyPath:@"imageBackgroundColor" options:NSKeyValueObservingOptionNew context:NULL];
    [_item addObserver:self forKeyPath:@"additionImageName" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeObserver {
    [_item removeObserver:self forKeyPath:@"imageTintColor"];
    [_item removeObserver:self forKeyPath:@"imageBackgroundColor"];
    [_item removeObserver:self forKeyPath:@"additionImageName"];
}

#pragma mark - Getter
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 54, 54)];
        _imageView.contentMode = UIViewContentModeCenter;
        _imageView.clipsToBounds = YES;
        _imageView.layer.cornerRadius = _imageView.width * 0.5;
    }
    return _imageView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:14];
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _titleLab;
}

- (UIImageView *)additionView {
    if (!_additionView) {
        _additionView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    }
    return _additionView;
}

@end
