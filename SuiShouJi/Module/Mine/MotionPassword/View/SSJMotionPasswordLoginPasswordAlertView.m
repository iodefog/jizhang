//
//  SSJMotionPasswordLoginPasswordAlertView.m
//  SuiShouJi
//
//  Created by old lang on 16/5/17.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMotionPasswordLoginPasswordAlertView.h"
#import "UIView+SSJViewAnimatioin.h"

static const CGFloat kHeaderHeight = 50;
static const CGFloat kBodyHeight = 72;
static const CGFloat kFooterHeight = 54;

static NSString *const kPinkColor = @"eb4a64";

@interface SSJMotionPasswordLoginPasswordAlertView ()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UITextField *passwordInput;

@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIView *bodyView;

@end

@implementation SSJMotionPasswordLoginPasswordAlertView

+ (instancetype)alertView {
    SSJMotionPasswordLoginPasswordAlertView *alert = [[SSJMotionPasswordLoginPasswordAlertView alloc] initWithFrame:CGRectMake(0, 0, 296, (kHeaderHeight + kBodyHeight + kFooterHeight))];
    return alert;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.titleLab];
        [self addSubview:self.bodyView];
        [self addSubview:self.cancelButton];
        [self addSubview:self.sureButton];
        [self.bodyView addSubview:self.passwordInput];
        
        self.layer.cornerRadius = 3;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)shake {
    double duration = 0.125;
    __block double startTime = 0;
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
        for (int i = 0; i < 8; i ++) {
            CGFloat translationX = i & 1 ? -10 : 10;
            if (i == 7) {
                translationX = 0;
            }
            [UIView addKeyframeWithRelativeStartTime:startTime relativeDuration:duration animations:^{
                self.transform = CGAffineTransformMakeTranslation(translationX, 0);
            }];
            startTime += duration;
        }
    } completion:NULL];
}

- (void)show {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [self ssj_popupInView:keyWindow completion:NULL];
}

- (void)dismiss:(void (^ __nullable)(BOOL finished))completion {
    [_passwordInput resignFirstResponder];
    [self ssj_dismiss:completion];
}

- (NSString *)password {
    return _passwordInput.text;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, kHeaderHeight)];
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.text = @"请输入登录密码";
    }
    return _titleLab;
}

- (UIView *)bodyView {
    if (!_bodyView) {
        _bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, kHeaderHeight, self.width, kBodyHeight)];
        [_bodyView ssj_setBorderWidth:1];
        [_bodyView ssj_setBorderStyle:(SSJBorderStyleTop | SSJBorderStyleBottom)];
        [_bodyView ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
    }
    return _bodyView;
}

- (UITextField *)passwordInput {
    if (!_passwordInput) {
        _passwordInput = [[UITextField alloc] initWithFrame:CGRectMake((self.width - 186) * 0.5, (kBodyHeight - 32) * 0.5, 186, 32)];
        _passwordInput.textAlignment = NSTextAlignmentCenter;
//        _passwordInput.borderStyle = UITextBorderStyleRoundedRect;
        _passwordInput.secureTextEntry = YES;
        _passwordInput.layer.cornerRadius = 3;
        _passwordInput.layer.borderWidth = 1;
        _passwordInput.layer.borderColor = [UIColor ssj_colorWithHex:kPinkColor].CGColor;
    }
    return _passwordInput;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.frame = CGRectMake(self.width * 0.5, kHeaderHeight + kBodyHeight, self.width * 0.5, kFooterHeight);
        _sureButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton setTitleColor:[UIColor ssj_colorWithHex:kPinkColor] forState:UIControlStateNormal];
    }
    return _sureButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(0, kHeaderHeight + kBodyHeight, self.width * 0.5, kFooterHeight);
        _cancelButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor ssj_colorWithHex:kPinkColor] forState:UIControlStateNormal];
        [_cancelButton ssj_setBorderStyle:SSJBorderStyleRight];
        [_cancelButton ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
        @weakify(self);
        [[_cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self dismiss:NULL];
        }];
    }
    return _cancelButton;
}

@end
