//
//  SSJCategoryEditableCollectionViewCell.m
//  SuiShouJi
//
//  Created by old lang on 16/8/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCategoryEditableCollectionViewCell.h"

static const CGFloat kIconScale = 0.7;

@interface SSJCategoryEditableCollectionViewCell ()

@property (nonatomic, strong) UIView *circleView;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIImageView *additionView;

@property (nonatomic, strong) NSArray *observedKeyPaths;

@end

@implementation SSJCategoryEditableCollectionViewCell

- (void)dealloc {
    [self removeObserver];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.circleView];
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.titleLab];
        [self.contentView addSubview:self.additionView];
        
        _observedKeyPaths = @[@"imageName", @"imageTintColor", @"imageBackgroundColor", @"title", @"titleColor", @"additionImageName"];
        
//#warning test
//        self.layer.borderWidth = 1;
//        self.layer.borderColor = [UIColor orangeColor].CGColor;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_titleLab sizeToFit];
    
    _imageView.size = CGSizeMake(_imageView.image.size.width * kIconScale, _imageView.image.size.height * kIconScale);
    CGFloat gap = (self.contentView.height - _imageView.height - _titleLab.height) * 0.33;
    _imageView.top = gap;
    _imageView.centerX = _titleLab.centerX = self.contentView.width * 0.5;
    _circleView.center = _imageView.center;
    _titleLab.top = _imageView.bottom + gap;
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
    [self setNeedsLayout];
}

#pragma mark - Private
- (void)updateAppearance {
    _imageView.image = [[UIImage imageNamed:_item.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _imageView.tintColor = _item.imageTintColor;
    _circleView.backgroundColor = _item.imageBackgroundColor;
    _titleLab.text = _item.title;
    _titleLab.textColor = _item.titleColor;
    _additionView.image = [UIImage imageNamed:_item.additionImageName];
}

- (void)addObserver {
    for (NSString *keyPath in _observedKeyPaths) {
        [_item addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)removeObserver {
    for (NSString *keyPath in _observedKeyPaths) {
        [_item removeObserver:self forKeyPath:keyPath];
    }
}

#pragma mark - Getter
- (UIView *)circleView {
    if (!_circleView) {
        _circleView = [[UIView alloc] init];
        _circleView.size = CGSizeMake(40, 40);
        _circleView.clipsToBounds = YES;
        _circleView.layer.cornerRadius = 20;
    }
    return _circleView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
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
