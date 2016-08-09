//
//  SSJMagicExportSuccessAlertView.m
//  SuiShouJi
//
//  Created by old lang on 16/8/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportSuccessAlertView.h"
#import "SSJMagicExportResultCheckMarkView.h"
#import "UIView+SSJViewAnimatioin.h"

@interface SSJMagicExportSuccessAlertView ()

@property (nonatomic, strong) SSJMagicExportResultCheckMarkView *checkMark;

@property (nonatomic, strong) UILabel *remindLab;

@end

@implementation SSJMagicExportSuccessAlertView

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)]) {
        [self addSubview:self.checkMark];
        [self addSubview:self.remindLab];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat gap = 10;
    CGFloat top = (self.height - _checkMark.radius * 2 - _remindLab.height - gap) * 0.5;
    _checkMark.top = top;
    _remindLab.top = _checkMark.bottom + gap;
    _checkMark.centerX = _remindLab.centerX = self.width * 0.5;
}

- (void)show:(void(^)())completion {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window ssj_popupInView:window completion:^(BOOL finished) {
        [_checkMark startAnimation:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (completion) {
                    completion();
                }
            });
        }];
    }];
}

- (SSJMagicExportResultCheckMarkView *)checkMark {
    if (!_checkMark) {
        _checkMark = [[SSJMagicExportResultCheckMarkView alloc] initWithRadius:30];
        _checkMark.backgroundColor = [UIColor clearColor];
        _checkMark.center = CGPointMake(self.width * 0.5, 66);
    }
    return _checkMark;
}

- (UILabel *)remindLab {
    if (!_remindLab) {
        _remindLab = [[UILabel alloc] init];
        _remindLab.backgroundColor = [UIColor clearColor];
        _remindLab.font = [UIFont systemFontOfSize:13];
        _remindLab.textAlignment = NSTextAlignmentCenter;
        _remindLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _remindLab.text = @"提交成功，请至您的邮箱查看";
    }
    return _remindLab;
}

@end
