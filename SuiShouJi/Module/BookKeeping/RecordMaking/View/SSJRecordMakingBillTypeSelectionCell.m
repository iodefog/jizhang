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

@end

@implementation SSJRecordMakingBillTypeSelectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.borderView];
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.label];
        [self.contentView addSubview:self.deleteBtn];
    }
    return self;
}

- (void)layoutSubviews {
    self.imageView.size = CGSizeMake(self.imageView.image.size.width * kIconScale, self.imageView.image.size.height * kIconScale);
    self.imageView.top = 24;
    self.imageView.centerX = self.contentView.width * 0.5;
    self.borderView.center = CGPointMake(self.contentView.width * 0.5, self.imageView.centerY);
    self.label.bottom = self.contentView.height;
    self.label.centerX = self.contentView.width * 0.5;
    self.deleteBtn.size = CGSizeMake(32, 32);
    self.deleteBtn.centerY = self.contentView.height * 0.5;
    self.deleteBtn.right = self.contentView.width;
    self.deleteBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 14, 0, 0);
}

- (void)setItem:(SSJRecordMakingBillTypeSelectionCellItem *)item {
    _item = item;
    
    @weakify(self);
    [[RACObserve(_item, title) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id x) {
        @strongify(self);
        self.label.text = self.item.title;
        [self.label sizeToFit];
        [self setNeedsLayout];
    }];
    
    [[RACObserve(_item, imageName) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id x) {
        @strongify(self);
        self.imageView.image = [[UIImage imageNamed:self.item.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }];
    
    [[[RACObserve(_item, colorValue) takeUntil:self.rac_prepareForReuseSignal] skip:1] subscribeNext:^(id x) {
        @strongify(self);
        if (self.item.colorValue.length) {
            self.imageView.tintColor = [UIColor ssj_colorWithHex:self.item.colorValue];
        }
        [self updateBorderAndTextColor:YES];
    }];
    
    [[[RACObserve(_item, state) takeUntil:self.rac_prepareForReuseSignal] skip:1] subscribeNext:^(id x) {
        @strongify(self);
        self.deleteBtn.hidden = self.item.state != SSJRecordMakingBillTypeSelectionCellStateEditing;
        [self updateBorderAndTextColor:YES];
    }];
    
    if (_item.colorValue.length) {
        self.imageView.tintColor = [UIColor ssj_colorWithHex:self.item.colorValue];
    }
    self.deleteBtn.hidden = self.item.state != SSJRecordMakingBillTypeSelectionCellStateEditing;
    [self updateBorderAndTextColor:NO];
}

- (void)updateBorderAndTextColor:(BOOL)animated {
    CGColorRef textColor = NULL;
    CGColorRef borderColor = NULL;
    
    switch (_item.state) {
        case SSJRecordMakingBillTypeSelectionCellStateNormal:
        case SSJRecordMakingBillTypeSelectionCellStateEditing:
            textColor = SSJ_MAIN_COLOR.CGColor;
            borderColor = [UIColor clearColor].CGColor;
            break;
            
        case SSJRecordMakingBillTypeSelectionCellStateSelected:
            textColor = [UIColor ssj_colorWithHex:_item.colorValue].CGColor;
            borderColor = [UIColor ssj_colorWithHex:_item.colorValue].CGColor;
            break;
    }
    
    if (animated) {
        CABasicAnimation *borderColorAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
        borderColorAnimation.delegate = self;
        borderColorAnimation.duration = kDuration;
        borderColorAnimation.removedOnCompletion = NO;
        borderColorAnimation.fillMode = kCAFillModeForwards;
//        borderColorAnimation.fromValue = (__bridge id _Nullable)(_borderView.layer.presentationLayer.borderColor);
        borderColorAnimation.toValue = (__bridge id _Nullable)(borderColor);
        [_borderView.layer addAnimation:borderColorAnimation forKey:kBorderColorAnimationKey];
        
        
        // CTMB 动画莫名其妙的不起作用
        CABasicAnimation *textColorAnimation = [CABasicAnimation animationWithKeyPath:@"foregroundColor"];
        textColorAnimation.delegate = self;
        textColorAnimation.duration = kDuration;
        textColorAnimation.removedOnCompletion = NO;
        textColorAnimation.fillMode = kCAFillModeForwards;
//        textColorAnimation.fromValue = (__bridge id _Nullable)(_label.layer.presentationLayer.borderColor);
        textColorAnimation.toValue = (__bridge id _Nullable)(textColor);
        [_label.textLayer addAnimation:textColorAnimation forKey:kTextColorAnimationKey];
    } else {
        _borderView.layer.borderColor = borderColor;
        _label.textLayer.foregroundColor = textColor;
    }
    
//    _borderView.layer.borderColor = borderColor;
//    _label.textLayer.foregroundColor = textColor;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    CABasicAnimation *basicAnimation = (CABasicAnimation *)anim;
    if (anim == [_borderView.layer animationForKey:kBorderColorAnimationKey]) {
        [_borderView.layer removeAnimationForKey:kBorderColorAnimationKey];
        _borderView.layer.borderColor = (__bridge CGColorRef _Nullable)(basicAnimation.toValue);
        
    } else if (anim == [_label.layer animationForKey:kTextColorAnimationKey]) {
        _label.textLayer.foregroundColor = (__bridge CGColorRef _Nullable)(basicAnimation.toValue);
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
        _label.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
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
