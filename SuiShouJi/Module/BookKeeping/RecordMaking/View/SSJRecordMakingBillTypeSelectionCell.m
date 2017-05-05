//
//  SSJRecordMakingBillTypeSelectionCell.m
//  SSRecordMakingDemo
//
//  Created by old lang on 16/4/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingBillTypeSelectionCell.h"
#import "SSJRecordMakingBillTypeSelectionCellItem.h"
#import "SSJRecordMakingBillTypeSelectionCellLabel.h"

static const NSTimeInterval kDuration = 0.25;
static const CGFloat kIconScale = 0.7;

static NSString *const kBorderColorAnimationKey = @"kBorderColorAnimationKey";
static NSString *const kTextColorAnimationKey = @"kTextColorAnimationKey";

@interface SSJRecordMakingBillTypeSelectionCell () <CAAnimationDelegate>

@property (nonatomic, strong) UIView *borderView;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) SSJRecordMakingBillTypeSelectionCellLabel *label;

@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) UIColor *normalTextColor;

@end

@implementation SSJRecordMakingBillTypeSelectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _normalTextColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [self.contentView addSubview:self.borderView];
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.label];
        [self.contentView addSubview:self.deleteBtn];
    }
    return self;
}

- (void)layoutSubviews {
    _imageView.size = CGSizeMake(_imageView.image.size.width * kIconScale, _imageView.image.size.height * kIconScale);
    _imageView.top = 24;
    _imageView.centerX = self.contentView.width * 0.5;
    _borderView.center = CGPointMake(self.contentView.width * 0.5, _imageView.centerY);
    _label.bottom = self.contentView.height;
    _label.centerX = self.contentView.width * 0.5;
    _deleteBtn.size = CGSizeMake(32, 32);
    _deleteBtn.centerY = self.contentView.height * 0.5;
    _deleteBtn.right = self.contentView.width;
    _deleteBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 14, 0, 0);
}

- (void)setItem:(SSJRecordMakingBillTypeSelectionCellItem *)item {
    _item = item;
    if (_item.colorValue.length) {
        _imageView.image = [[UIImage imageNamed:_item.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _imageView.tintColor = [UIColor ssj_colorWithHex:_item.colorValue];
    } else {
        _imageView.image = [UIImage imageNamed:_item.imageName];
    }
    _label.text = _item.title;
    [_label sizeToFit];
    [self updateState];
    [self setNeedsLayout];
}

- (void)updateState {
    _deleteBtn.hidden = !_item.editable;
    
    [_borderView.layer removeAnimationForKey:kBorderColorAnimationKey];
    [_label.layer removeAnimationForKey:kTextColorAnimationKey];
    
    if (_item.editable) {
        _borderView.layer.borderColor = [UIColor clearColor].CGColor;
        _label.textColor = _item.selected ? [UIColor ssj_colorWithHex:_item.colorValue] : _normalTextColor;
    } else if (_item.selected) {
        [self animateSelectState:YES];
    } else if (_item.deselected) {
        [self animateSelectState:NO];
    } else {
        _borderView.layer.borderColor = (_item.selected ? [UIColor ssj_colorWithHex:_item.colorValue].CGColor : [UIColor clearColor].CGColor);
        _label.textColor = _item.selected ? [UIColor ssj_colorWithHex:_item.colorValue] : _normalTextColor;
    }
}

- (void)animateSelectState:(BOOL)selected {
    CGColorRef normalBorderColor = [UIColor clearColor].CGColor;
    CGColorRef selectedBorderColor = [UIColor ssj_colorWithHex:_item.colorValue].CGColor;
    
    UIColor *selectedTextColor = [UIColor ssj_colorWithHex:_item.colorValue];
    
    _borderView.layer.borderColor = selected ? normalBorderColor : selectedBorderColor;
    _label.textColor = _item.selected ? _normalTextColor : selectedTextColor;
    
    CABasicAnimation *borderColorAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    borderColorAnimation.duration = kDuration;
    borderColorAnimation.delegate = self;
    borderColorAnimation.removedOnCompletion = NO;
    borderColorAnimation.fillMode = kCAFillModeForwards;
    borderColorAnimation.toValue = (__bridge id _Nullable)(selected ? selectedBorderColor : normalBorderColor);
    [_borderView.layer addAnimation:borderColorAnimation forKey:kBorderColorAnimationKey];
    
    CABasicAnimation *textColorAnimation = [CABasicAnimation animationWithKeyPath:@"foregroundColor"];
    textColorAnimation.duration = kDuration;
    textColorAnimation.delegate = self;
    textColorAnimation.removedOnCompletion = NO;
    textColorAnimation.fillMode = kCAFillModeForwards;
    textColorAnimation.toValue = (__bridge id _Nullable)(selected ? selectedTextColor.CGColor : _normalTextColor.CGColor);
    [_label.layer addAnimation:textColorAnimation forKey:kTextColorAnimationKey];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (anim == [_borderView.layer animationForKey:kBorderColorAnimationKey]) {
        CABasicAnimation *borderColorAnimation = (CABasicAnimation *)anim;
        _borderView.layer.borderColor = (__bridge CGColorRef _Nullable)(borderColorAnimation.toValue);
        [_borderView.layer removeAnimationForKey:kBorderColorAnimationKey];
    } else if (anim == [_label.layer animationForKey:kTextColorAnimationKey]) {
        _label.textColor = _item.selected ? [UIColor ssj_colorWithHex:_item.colorValue] : _normalTextColor;
        [_label.layer removeAnimationForKey:kTextColorAnimationKey];
    }
}

#pragma mark - Lazyloading
- (UIView *)borderView {
    if (!_borderView) {
        _borderView = [[UIView alloc] init];
        _borderView.size = CGSizeMake(40, 40);
        _borderView.layer.borderWidth = 1;
        _borderView.layer.cornerRadius = 20;
        _borderView.layer.borderColor = [UIColor clearColor].CGColor;
    }
    return _borderView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 52, 52)];
    }
    return _imageView;
}

- (SSJRecordMakingBillTypeSelectionCellLabel *)label {
    if (!_label) {
        _label = [[SSJRecordMakingBillTypeSelectionCellLabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_4);
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setImage:[UIImage imageNamed:@"record_making_remove"] forState:UIControlStateNormal];
        @weakify(self);
        [[_deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            BOOL shouldDelete = YES;
            if (self.shouldDeleteAction) {
                shouldDelete = self.shouldDeleteAction(self);
            }
            
            if (shouldDelete && self.deleteAction) {
                self.deleteAction(self);
            }
        }];
    }
    return _deleteBtn;
}

@end
