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

@property (nonatomic, strong) UIButton *actionBtn;

@end

@implementation SSJBudgetNodataRemindView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
        [self addSubview:self.titleLab];
        [self addSubview:self.subTitleLab];
        [self addSubview:self.actionBtn];
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat height = self.actionBtn.height > 0 ? CGRectGetMaxY(self.actionBtn.frame) : CGRectGetMaxY(self.titleLab.frame);
    CGFloat y = (self.height - height) * 0.5;
    _imageView.top = y;
    self.titleLab.top = _imageView.bottom + kVerticalGap;
    _imageView.centerX = _titleLab.centerX = self.width * 0.5;
    self.subTitleLab.top = CGRectGetMaxY(self.titleLab.frame) + 35;
    self.subTitleLab.centerX = self.actionBtn.centerX = self.titleLab.centerX;
    
    self.actionBtn.top = CGRectGetMaxY(self.subTitleLab.frame) + 20;
}

- (CGSize)sizeThatFits:(CGSize)size {
    [_imageView sizeToFit];
    [_titleLab sizeToFit];
    CGFloat subW = MAX(_imageView.width, _titleLab.width);
    CGSize finalsize = CGSizeMake(MAX(subW, MAX(self.subTitleLab.width,self.actionBtn.width)), CGRectGetMaxY(self.actionBtn.frame));
    return finalsize;
}

- (void)setImage:(NSString *)image {
    if (![_image isEqualToString:image]) {
        _image = image;
        _imageView.image = [UIImage imageNamed:_image];
        [_imageView sizeToFit];
        [self sizeToFit];
    }
}

- (void)setTitle:(NSString *)title {
    if (![_title isEqualToString:title]) {
        _title = title;
        _titleLab.text = title;
        [self.titleLab sizeToFit];
        self.titleLab.top = _imageView.bottom + kVerticalGap;
        [self sizeToFit];
    }
}

- (void)setSubTitle:(NSString *)subTitle {
    self.subTitleLab.hidden = NO;
    if (![_subTitle isEqualToString:subTitle]) {
        _subTitle = subTitle;
        _subTitleLab.text = subTitle;
        [self.subTitleLab sizeToFit];
        self.subTitleLab.top = CGRectGetMaxY(self.titleLab.frame) + 35;
        [self sizeToFit];
    }
}

- (void)setActionTitle:(NSString *)actionTitle {
    self.actionBtn.hidden = NO;
    if (![_actionTitle isEqualToString:actionTitle]) {
        _actionTitle = actionTitle;
        [self.actionBtn setTitle:actionTitle forState:UIControlStateNormal];
        self.actionBtn.width = SSJSCREENWITH - 30;
        self.actionBtn.height = 44;
        self.actionBtn.top = CGRectGetMaxY(self.subTitleLab.frame) + 20;
        [self sizeToFit];
    }
}

- (void)updateAppearance {
    _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _subTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    [_actionBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
    [_actionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
        _subTitleLab.hidden = YES;
    }
    return _subTitleLab;
}

- (UIButton *)actionBtn {
    if (!_actionBtn) {
        _actionBtn = [[UIButton alloc] init];
        _actionBtn.layer.cornerRadius = 8;
        _actionBtn.layer.masksToBounds = YES;
        _actionBtn.hidden = YES;
        _actionBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        @weakify(self);
        [[_actionBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.actionBlock) {
                self.actionBlock();
            }
        }];
    }
    return _actionBtn;
}

@end
