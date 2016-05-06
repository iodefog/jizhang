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

static NSString *const kBorderColorAnimationKey = @"kBorderColorAnimationKey";
static NSString *const kTransformAnimationKey = @"kTransformAnimationKey";
static NSString *const kTextColorAnimationKey = @"kTextColorAnimationKey";

@interface SSJRecordMakingBillTypeSelectionCell ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) SSJRecordMakingBillTypeSelectionCellLabel *label;

@property (nonatomic, strong) UIButton *deleteBtn;

@end

@implementation SSJRecordMakingBillTypeSelectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 52, 52)];
        _imageView.layer.borderWidth = 1;
        _imageView.layer.cornerRadius = _imageView.width * 0.5;
        _imageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_imageView];
        
        _label = [[SSJRecordMakingBillTypeSelectionCellLabel alloc] init];
        _label.fontSize = 16;
        _label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_label];
        
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn addTarget:self action:@selector(deleteButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_deleteBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [self.contentView addSubview:_deleteBtn];
        
        _deleteBtn.layer.borderWidth = 1;
        _deleteBtn.layer.borderColor = [UIColor redColor].CGColor;
        
//        self.contentView.layer.borderColor = [UIColor redColor].CGColor;
//        self.contentView.layer.borderWidth = 1;
    }
    return self;
}

- (void)layoutSubviews {
    _imageView.center = CGPointMake(self.contentView.width * 0.5, 36);
    _label.bottom = self.contentView.height;
    _label.centerX = self.contentView.width * 0.5;
    _deleteBtn.size = CGSizeMake(22, 22);
    _deleteBtn.center = _imageView.rightTop;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
}

- (void)setItem:(SSJRecordMakingBillTypeSelectionCellItem *)item {
    [self setNeedsLayout];
    _item = item;
    _imageView.image = [UIImage imageNamed:_item.imageName];
    _label.text = _item.title;
    [_label sizeToFit];
    [self updateState];
    _item.animated = NO;
}

- (void)deleteButtonAction {
    if (_deleteAction) {
        _deleteAction(self);
    }
}

- (void)updateState {
    _deleteBtn.hidden = !_item.editable;
    
    [self.contentView.layer removeAllAnimations];
    self.contentView.transform = CGAffineTransformMakeRotation(0);
    
    if (_item.editable) {
        _imageView.transform = CGAffineTransformMakeScale(1, 1);
        _imageView.layer.borderColor = [UIColor ssj_colorWithHex:@"eb4a64"].CGColor;
        
        self.contentView.transform = CGAffineTransformMakeRotation(-M_PI_4 * 0.06);
        [UIView animateWithDuration:0.12 delay:0 options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction) animations:^{
            self.contentView.transform = CGAffineTransformMakeRotation(+M_PI_4 * 0.06);
        } completion:NULL];
        return;
    }
    
    UIColor *selectedColor = [UIColor ssj_colorWithHex:_item.colorValue];
    CGColorRef borderColor = (_item.selected ? selectedColor.CGColor : [UIColor clearColor].CGColor);
    if (_item.animated) {
        CABasicAnimation *borderColorAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
        borderColorAnimation.duration = kDuration;
        borderColorAnimation.delegate = self;
        borderColorAnimation.removedOnCompletion = NO;
        borderColorAnimation.fillMode = kCAFillModeForwards;
        borderColorAnimation.toValue = (__bridge id _Nullable)(borderColor);
        [_imageView.layer addAnimation:borderColorAnimation forKey:kBorderColorAnimationKey];
        
        CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        transformAnimation.duration = kDuration;
        transformAnimation.delegate = self;
        transformAnimation.removedOnCompletion = NO;
        transformAnimation.fillMode = kCAFillModeForwards;
        transformAnimation.toValue = _item.selected ? @1.33 : @1;
        [_imageView.layer addAnimation:transformAnimation forKey:kTransformAnimationKey];
        
        CABasicAnimation *textColorAnimation = [CABasicAnimation animationWithKeyPath:@"foregroundColor"];
        textColorAnimation.duration = kDuration;
        textColorAnimation.delegate = self;
        textColorAnimation.removedOnCompletion = NO;
        textColorAnimation.fillMode = kCAFillModeForwards;
        textColorAnimation.toValue = (__bridge id _Nullable)(_item.selected ? selectedColor.CGColor : [UIColor blackColor].CGColor);
        [_label.layer addAnimation:textColorAnimation forKey:kTextColorAnimationKey];
    } else {
        _imageView.layer.borderColor = borderColor;
        _imageView.transform = _item.selected ? CGAffineTransformMakeScale(1.33, 1.33) : CGAffineTransformMakeScale(1, 1);
        _label.textColor = _item.selected ? selectedColor : [UIColor blackColor];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (anim == [_imageView.layer animationForKey:kBorderColorAnimationKey]) {
        CABasicAnimation *borderColorAnimation = (CABasicAnimation *)anim;
        _imageView.layer.borderColor = (__bridge CGColorRef _Nullable)(borderColorAnimation.toValue);
        [_imageView.layer removeAnimationForKey:kBorderColorAnimationKey];
        
    } else if (anim == [_imageView.layer animationForKey:kTransformAnimationKey]) {
        _imageView.transform = _item.selected ? CGAffineTransformMakeScale(1.33, 1.33) : CGAffineTransformMakeScale(1, 1);
        [_imageView.layer removeAnimationForKey:kTransformAnimationKey];
        
    } else if (anim == [_label.layer animationForKey:kTextColorAnimationKey]) {
        _label.textColor = _item.selected ? [UIColor ssj_colorWithHex:_item.colorValue] : [UIColor blackColor];
        [_label.layer removeAnimationForKey:kTextColorAnimationKey];
    }
}

@end
