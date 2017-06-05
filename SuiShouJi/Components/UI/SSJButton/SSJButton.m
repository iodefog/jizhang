//
//  SSJButton.m
//  SuiShouJi
//
//  Created by old lang on 17/3/17.
//  Copyright © 2017年 MZL. All rights reserved.
//

#import "SSJButton.h"
#import "Masonry.h"
#import "SSJButtonConentView.h"

@interface SSJButton ()

@property (nonatomic, strong) NSMutableDictionary *titleInfo;

@property (nonatomic, strong) NSMutableDictionary *titleColorInfo;

@property (nonatomic, strong) NSMutableDictionary *imageInfo;

@property (nonatomic, strong) NSMutableDictionary *backgroundImageInfo;

@property (nonatomic, strong) NSMutableDictionary *backgroundColorInfo;

@property (nonatomic, strong) NSMutableDictionary *borderColorInfo;

@property (nonatomic, strong) SSJButtonConentView *contentView;

@end

@implementation SSJButton

- (void)dealloc {
    [self removeObserver];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _titleInfo = [[NSMutableDictionary alloc] init];
        _titleColorInfo = [[NSMutableDictionary alloc] init];
        _imageInfo = [[NSMutableDictionary alloc] init];
        _backgroundImageInfo = [[NSMutableDictionary alloc] init];
        _backgroundColorInfo = [[NSMutableDictionary alloc] init];
        _borderColorInfo = [[NSMutableDictionary alloc] init];
        
        self.contentView = [[SSJButtonConentView alloc] init];
        [self addSubview:self.contentView];
        
        [self addObserver];
    }
    return self;
}

- (void)updateConstraints {
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(self.contentInset).priorityLow();
    }];
    [super updateConstraints];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.contentView.layer.cornerRadius = cornerRadius;
    self.contentView.clipsToBounds = (cornerRadius > 0);
}

- (CGFloat)cornerRadius {
    return self.contentView.layer.cornerRadius;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.contentView.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth {
    return self.contentView.layer.borderWidth;
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_contentInset, contentInset)) {
        _contentInset = contentInset;
        [self setNeedsUpdateConstraints];
    }
}

- (void)setTitleInset:(UIEdgeInsets)titleInset {
    self.contentView.titleInset = titleInset;
}

- (UIEdgeInsets)titleInset {
    return self.contentView.titleInset;
}

- (void)setImageInset:(UIEdgeInsets)imageInset {
    self.contentView.imageInset = imageInset;
}

- (UIEdgeInsets)imageInset {
    return self.contentView.imageInset;
}

- (void)setSpaceBetweenImageAndTitle:(CGFloat)spaceBetweenImageAndTitle {
    self.contentView.spaceBetweenImageAndTitle = spaceBetweenImageAndTitle;
}

- (CGFloat)spaceBetweenImageAndTitle {
    return self.contentView.spaceBetweenImageAndTitle;
}

- (void)setLayoutStyle:(SSJButtonLayoutStyle)layoutStyle {
    self.contentView.layoutStyle = layoutStyle;
}

- (SSJButtonLayoutStyle)layoutStyle {
    return self.contentView.layoutStyle;
}

- (UILabel *)titleLabel {
    return self.contentView.titleLabel;
}

- (UIImageView *)imageView {
    return self.contentView.imageView;
}

- (UIImageView *)backgroundImageView {
    return self.contentView.backgroundImageView;
}

- (SSJButtonState)currentState {
    if (self.state & UIControlStateDisabled) {
        return SSJButtonStateDisabled;
    } else if (self.state & UIControlStateSelected) {
        return SSJButtonStateSelected;
    } else if (self.state & UIControlStateHighlighted) {
        return SSJButtonStateHighlighted;
    } else {
        return SSJButtonStateNormal;
    }
}

- (void)setTitle:(nullable NSString *)title forState:(SSJButtonState)state {
    _titleInfo[@(state)] = title;
    [self updateAppearance];
}

- (void)setTitleColor:(nullable UIColor *)color forState:(SSJButtonState)state {
    _titleColorInfo[@(state)] = color;
    [self updateAppearance];
}

- (void)setImage:(nullable UIImage *)image forState:(SSJButtonState)state {
    _imageInfo[@(state)] = image;
    [self updateAppearance];
}

- (void)setBackgroundImage:(nullable UIImage *)image forState:(SSJButtonState)state {
    _backgroundImageInfo[@(state)] = image;
    [self updateAppearance];
}

- (void)setBackgroundColor:(nullable UIColor *)backgroundColor forState:(SSJButtonState)state {
    _backgroundColorInfo[@(state)] = backgroundColor;
    [self updateAppearance];
}

- (void)setBorderColor:(nullable UIColor *)borderColor forState:(SSJButtonState)state {
    _borderColorInfo[@(state)] = borderColor;
    [self updateAppearance];
}

- (nullable NSString *)titleForState:(SSJButtonState)state {
    return _titleInfo[@(state)];
}

- (nullable UIColor *)titleColorForState:(SSJButtonState)state {
    return _titleColorInfo[@(state)];
}

- (nullable UIImage *)imageForState:(SSJButtonState)state {
    return _imageInfo[@(state)];
}

- (nullable UIImage *)backgroundImageForState:(SSJButtonState)state {
    return _backgroundImageInfo[@(state)];
}

- (nullable UIColor *)backgroundColorForState:(SSJButtonState)state {
    return _backgroundColorInfo[@(state)];
}

- (nullable UIColor *)borderColorForState:(SSJButtonState)state {
    return _borderColorInfo[@(state)];
}

#pragma mark - Private
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context {
    [self updateAppearance];
}

- (void)addObserver {
    [self addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeObserver {
    [self removeObserver:self forKeyPath:@"enabled"];
    [self removeObserver:self forKeyPath:@"selected"];
    [self removeObserver:self forKeyPath:@"highlighted"];
}

- (void)updateAppearance {
    NSString *title = _titleInfo[@(self.currentState)] ?: _titleInfo[@(SSJButtonStateNormal)];
    UIColor *titleColor = _titleColorInfo[@(self.currentState)] ?: _titleColorInfo[@(SSJButtonStateNormal)];
    UIImage *image = _imageInfo[@(self.currentState)] ?: _imageInfo[@(SSJButtonStateNormal)];
    UIImage *backgroundImage = _backgroundImageInfo[@(self.currentState)] ?: _backgroundImageInfo[@(SSJButtonStateNormal)];
    UIColor *borderColor = _borderColorInfo[@(self.currentState)] ?: _borderColorInfo[@(SSJButtonStateNormal)];
    UIColor *backgroundColor = _backgroundColorInfo[@(self.currentState)] ?: _backgroundColorInfo[@(SSJButtonStateNormal)];
    
    self.contentView.titleLabel.text = title;
    self.contentView.titleLabel.textColor = titleColor;
    self.contentView.imageView.image = image;
    self.contentView.backgroundImageView.image = backgroundImage;
    self.contentView.layer.borderColor = borderColor.CGColor;
    self.contentView.backgroundColor = backgroundColor;
    
    [self setNeedsUpdateConstraints];
}

@end
