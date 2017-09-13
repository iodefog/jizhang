//
//  SSJRecycleDataDeletionAlertView.m
//  SuiShouJi
//
//  Created by old lang on 2017/9/13.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRecycleDataDeletionAlertView.h"

static const NSTimeInterval kDuration = 0.25;

@interface SSJRecycleDataDeletionAlertView ()

@property (nonatomic, strong) UILabel *messageLab;

@property (nonatomic, strong) UILabel *tipLab;

@property (nonatomic, strong) UIImageView *tipIcon;

@property (nonatomic, strong) UIButton *confirmBtn;

@end

@implementation SSJRecycleDataDeletionAlertView

+ (instancetype)alertView {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 12;
        self.clipsToBounds = YES;
        [self addSubview:self.messageLab];
        [self addSubview:self.tipLab];
        [self addSubview:self.tipIcon];
        [self addSubview:self.confirmBtn];
        [self setNeedsUpdateConstraints];
        [self updateAppearanceAccordingToTheme];
    }
    return self;
}

- (void)updateConstraints {
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(SSJ_KEYWINDOW);
    }];
    [self.messageLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40);
        make.width.mas_equalTo(248);
        make.centerX.mas_equalTo(self);
    }];
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.messageLab.mas_bottom).offset(22);
        make.left.mas_equalTo(self.tipIcon.mas_right).offset(12);
    }];
    [self.tipIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(66);
        make.centerY.mas_equalTo(self.tipLab);
        make.size.mas_equalTo(self.tipIcon.image.size);
    }];
    [self.confirmBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tipLab.mas_bottom).offset(10);
        make.left.right.bottom.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(280, 50));
    }];
    [super updateConstraints];
}

- (void)show {
    if (self.superview) {
        return;
    }
    
    self.alpha = 0;
    [SSJ_KEYWINDOW ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:SSJMaskAlpha target:self touchAction:@selector(dismiss) animation:^{
        self.alpha = 1;
    } timeInterval:kDuration fininshed:NULL];
}

- (void)dismiss {
    [SSJ_KEYWINDOW ssj_hideBackViewForView:self animation:^{
        self.alpha = 0;
    } timeInterval:kDuration fininshed:NULL];
}

- (void)updateAppearanceAccordingToTheme {
    self.backgroundColor = SSJ_SECONDARY_FILL_COLOR;
    self.messageLab.textColor = SSJ_MAIN_COLOR;
    self.tipLab.textColor = SSJ_SECONDARY_COLOR;
    [self.confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.confirmBtn ssj_setBackgroundColor:SSJ_MARCATO_COLOR forState:UIControlStateNormal];
}

- (UILabel *)messageLab {
    if (!_messageLab) {
        _messageLab = [[UILabel alloc] init];
        _messageLab.numberOfLines = 0;
        _messageLab.text = @"该资金账户以及对应流水已被删除至回收站";
        _messageLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _messageLab.textAlignment = NSTextAlignmentCenter;
    }
    return _messageLab;
}

- (UILabel *)tipLab {
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        _tipLab.text = @"“回收站”位于“设置”里";
        _tipLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _tipLab.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLab;
}

- (UIImageView *)tipIcon {
    if (!_tipIcon) {
        _tipIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bulb"]];
    }
    return _tipIcon;
}

- (UIButton *)confirmBtn {
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.titleLabel.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_2];
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        @weakify(self);
        [[_confirmBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self dismiss];
        }];
    }
    return _confirmBtn;
}

@end
