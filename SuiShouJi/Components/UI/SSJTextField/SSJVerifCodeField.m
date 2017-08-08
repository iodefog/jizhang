//
//  SSJVerifCodeField.m
//  SuiShouJi
//
//  Created by yi cai on 2017/6/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJVerifCodeField.h"
#import "SSJLoginGraphVerView.h"
#import "SSJLoginVerifyPhoneNumViewModel.h"


static const CGFloat kAuthCodeBtnWidth = 125;
static const NSInteger kCountdownLimit = 60;

@interface SSJVerifCodeField()

@property (nonatomic, strong) id <NSObject> observer;

//验证码
@property (nonatomic, strong) UIButton *getAuthCodeBtn;

@property (nonatomic) SSJGetVerifCodeState getAuthCodeState;

/**倒计时*/
@property (nonatomic, strong) NSTimer *countdownTimer;

/**<#注释#>*/
@property (nonatomic, assign) NSInteger countdown;

/**图形验证码*/
@property (nonatomic, strong) SSJLoginGraphVerView *graphVerView;

@end

@implementation SSJVerifCodeField

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
}

- (instancetype)initWithGetCodeType:(SSJRegistAndForgetPasswordType)type {
    if (self = [super init]) {
        self.authCodeLength = SSJAuthCodeLength;
        self.viewModel.regOrForType = type;
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.placeholder = NSLocalizedString(@"验证码", nil);
        self.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        
        [self addSubview:self.getAuthCodeBtn];

        [self ssj_setBorderWidth:2];
        [self ssj_setBorderStyle:SSJBorderStyleBottom];
        
        __weak typeof(self) wself = self;
        self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:self queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if (wself.text.length > wself.authCodeLength && wself.authCodeLength > 0) {
                wself.text = [wself.text substringToIndex:wself.authCodeLength];
            }
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.getAuthCodeBtn.size = CGSizeMake(kAuthCodeBtnWidth, self.height);
    self.getAuthCodeBtn.right = self.width;
    
    CGFloat verticalInset = (self.height - 18) * 0.5;
    [self.getAuthCodeBtn ssj_setBorderInsets:UIEdgeInsetsMake(verticalInset, 0, verticalInset, 0)];
}

#pragma mark - Overwrite
- (CGRect)clearButtonRectForBounds:(CGRect)bounds{
    CGRect rect = [super clearButtonRectForBounds:bounds];
    CGFloat x = rect.origin.x - kAuthCodeBtnWidth - 10;
    return CGRectMake(x, rect.origin.y , rect.size.width, rect.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect rect = [super editingRectForBounds:bounds];
    CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width - kAuthCodeBtnWidth, rect.size.height);
    return newRect;
}

- (void)setViewModel:(SSJLoginVerifyPhoneNumViewModel *)viewModel {
    _viewModel = viewModel;
}

- (void)getVerifCode {
    __weak typeof(self) wself = self;
    wself.getAuthCodeState = SSJGetVerifCodeStateLoading;
    [[[wself.viewModel.getVerificationCodeCommand execute:nil] takeUntil:wself.rac_willDeallocSignal] subscribeNext:^(NSDictionary *value) {
        [wself dealVerifCodeDataWithDic:value];
    } error:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
        wself.getAuthCodeState = SSJGetVerifCodeStateFailed;
    }];
}

#pragma mark - Private

//处理发送验证码返回的数据
- (void)dealVerifCodeDataWithDic:(NSDictionary *)value {
    __weak typeof(self) wself = self;
    NSString *code = [NSString stringWithFormat:@"%@",[value objectForKey:@"code"]];
    NSString *image = [NSString stringWithFormat:@"%@",[[value objectForKey:@"results"] objectForKey:@"image"]];
    NSString *desc = [NSString stringWithFormat:@"%@",[value objectForKey:@"desc"]];
    //请求成功并且不需要图形验证码的时候开启倒计时
    if ([code isEqualToString:@"1"]) {//发送验证码成功
        [CDAutoHideMessageHUD showMessage:desc];
        //倒计时
        [wself beginCountdownIfNeeded];
        [wself becomeFirstResponder];
        wself.getAuthCodeState = SSJGetVerifCodeStateSent;
        [_graphVerView dismiss];
    } else if ([code isEqualToString:@"2"]) {//需要图片验证码
        //显示图形验证码
        [wself.graphVerView.verNumTextF becomeFirstResponder];
        wself.graphVerView.verImage = [image base64ToImage];
        [wself.graphVerView show];
        wself.getAuthCodeState = SSJGetVerifCodeStateNeedImageCode;
    } else if ([code isEqualToString:@"3"]) {//图片验证码错误
        [CDAutoHideMessageHUD showMessage:desc];
        //清空之前输入的验证码
        wself.viewModel.graphNum = @"";
        wself.graphVerView.verNumTextF.text = @"";
        //重新获取图形验证码
        [[[wself.viewModel.reGetVerificationCodeCommand execute:nil] takeUntil:wself.rac_willDeallocSignal] subscribeNext:^(UIImage *image) {
            //成功刷新验证码
            wself.graphVerView.verImage = image;
            
        }];
        wself.getAuthCodeState = SSJGetVerifCodeStateImageCodeError;
    } else {
        [CDAutoHideMessageHUD showMessage:desc];
        wself.getAuthCodeState = SSJGetVerifCodeStateFailed;
    }
}
//  开始倒计时
- (void)beginCountdownIfNeeded {
    if (!self.countdownTimer.valid && !self.countdownTimer) {
        self.countdown = kCountdownLimit;
                self.countdownTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateCountdown) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.countdownTimer forMode:NSRunLoopCommonModes];
        [self.countdownTimer fire];
    }
}
//取消定时器
- (void)invalidateTimer {
    [self.countdownTimer invalidate];
    _countdownTimer = nil;
}

//  更新倒计时
- (void)updateCountdown {
    if (self.countdown > 0) {
        self.getAuthCodeBtn.enabled = NO;
        [self.getAuthCodeBtn setTitle:[NSString stringWithFormat:@"%ds后重新获取",(int)self.countdown] forState:UIControlStateDisabled];
    } else {
        self.getAuthCodeBtn.enabled = YES;
        [self.getAuthCodeBtn setTitle:[NSString stringWithFormat:@"重新获取"] forState:UIControlStateNormal];
        
        [self invalidateTimer];
    }
    self.countdown --;
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    self.getAuthCodeBtn.titleLabel.font = font;
}

- (UIButton *)getAuthCodeBtn {
    if (!_getAuthCodeBtn) {
        _getAuthCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _getAuthCodeBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_getAuthCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_getAuthCodeBtn setTitleColor:[UIColor ssj_colorWithHex:@"#ea4a64"] forState:UIControlStateNormal];
        [_getAuthCodeBtn setTitleColor:[UIColor ssj_colorWithHex:@"#ea4a64"] forState:UIControlStateDisabled];
        [_getAuthCodeBtn ssj_setBorderStyle:SSJBorderStyleLeft];
        [_getAuthCodeBtn ssj_setBorderWidth:2];
        @weakify(self);
        [[_getAuthCodeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
            @strongify(self);
            [self getVerifCode];
        
        }];
    }
    return _getAuthCodeBtn;
}

- (SSJLoginGraphVerView *)graphVerView {
    if (!_graphVerView) {
        _graphVerView = [[SSJLoginGraphVerView alloc] init];
        _graphVerView.verViewModel = self.viewModel;
        _graphVerView.size = CGSizeMake(315, 252);
        _graphVerView.centerY = SSJSCREENHEIGHT * 0.5 - 80;
        _graphVerView.centerX = SSJSCREENWITH * 0.5;
        @weakify(self);
        [[_graphVerView.reChooseBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
            @strongify(self);
            //点击重新获取图形验证码
            [[[self.viewModel.reGetVerificationCodeCommand execute:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(UIImage *image) {
                //成功刷新验证码
                self.graphVerView.verImage = image;
            }];
        }];
        
        [[_graphVerView.commitBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
            @strongify(self);
            if (!self.viewModel.graphNum.length) {
                [CDAutoHideMessageHUD showMessage:@"请输入图形验证码"];
                return ;
            }
            
            //发送获取验证码请求
            [[[self.viewModel.getVerificationCodeCommand execute:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSDictionary *value) {
                [self endEditing:YES];
                [self dealVerifCodeDataWithDic:value];
            }];
        }];
    }
    return _graphVerView;
}

@end


@implementation SSJVerifCodeField (SSJTheme)

- (void)updateAppearanceAccordingToTheme {
    self.textColor = SSJ_MAIN_COLOR;
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName:SSJ_SECONDARY_COLOR}];
    [self ssj_setBorderColor:SSJ_BORDER_COLOR];
    [self.getAuthCodeBtn ssj_setBorderColor:SSJ_BORDER_COLOR];
}


- (void)defaultAppearanceTheme {
    self.textColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].mainColor];
//    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName:SSJ_SECONDARY_COLOR}];
    [self ssj_setBorderColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].borderColor]];
    [self.getAuthCodeBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].borderColor]];
}
@end
