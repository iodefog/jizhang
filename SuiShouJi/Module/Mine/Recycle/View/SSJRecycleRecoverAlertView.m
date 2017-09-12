//
//  SSJRecycleRecoverAlertView.m
//  SuiShouJi
//
//  Created by old lang on 2017/9/12.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRecycleRecoverAlertView.h"

static const NSTimeInterval kDuration = 0.25;

@interface SSJRecycleRecoverAlertView ()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UILabel *messageLab;

@property (nonatomic, strong) UIButton *btn;

@end

@implementation SSJRecycleRecoverAlertView

- (void)dealloc {
    
}

+ (instancetype)alertView {
    return [[self alloc] initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.layer.cornerRadius = 12;
        self.clipsToBounds = YES;
        [self addSubview:self.titleLab];
        [self addSubview:self.messageLab];
        [self addSubview:self.btn];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.btn.layer.cornerRadius = self.btn.height * 0.5;
}

- (void)updateConstraints {
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(280);
        make.center.mas_equalTo(SSJ_KEYWINDOW);
    }];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(50);
        make.centerX.mas_equalTo(self);
    }];
    [self.messageLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLab.mas_bottom).offset(26);
        make.centerX.mas_equalTo(self);
    }];
    [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(210, 40));
        make.top.mas_equalTo(self.messageLab.mas_bottom).offset(30);
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(-40);
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
    self.titleLab.textColor = SSJ_MAIN_COLOR;
    self.messageLab.textColor = SSJ_MAIN_COLOR;
    [self.btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btn ssj_setBackgroundColor:SSJ_MARCATO_COLOR forState:UIControlStateNormal];
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = @"已还原成功～";
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
    }
    return _titleLab;
}

- (UILabel *)messageLab {
    if (!_messageLab) {
        _messageLab = [[UILabel alloc] init];
        _messageLab.numberOfLines = 0;
        _messageLab.text = @"你的打赏会激励程序员哥哥\n拼命守护你的数据哦！";
        _messageLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _messageLab.textAlignment = NSTextAlignmentCenter;
    }
    return _messageLab;
}

- (UIButton *)btn {
    if (!_btn) {
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.clipsToBounds = YES;
        _btn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_btn setTitle:@"打赏" forState:UIControlStateNormal];
        @weakify(self);
        [[_btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self dismiss];
            if (self.confirmBlock) {
                self.confirmBlock();
            }
        }];
    }
    return _btn;
}

@end
