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
static const NSInteger kAuthCodeLimit = 6;

@interface SSJVerifCodeField()

@property (nonatomic, strong) id <NSObject> observer;

//验证码
@property (nonatomic, strong) UIButton *getAuthCodeBtn;

//@property (nonatomic, strong) SSJLoginVerifyPhoneNumViewModel *viewModel;

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
        self.viewModel.regOrForType = type;
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.placeholder = NSLocalizedString(@"验证码", nil);
        self.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        
        [self addSubview:self.getAuthCodeBtn];

        [self ssj_setBorderWidth:1/SSJSCREENSCALE];
        [self ssj_setBorderStyle:SSJBorderStyleBottom];
        
        __weak typeof(self) wself = self;
        self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:self queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if (wself.text.length > kAuthCodeLimit) {
                wself.text = [wself.text substringToIndex:kAuthCodeLimit];
            }
        }];
        
//        [self.viewModel.getVerificationCodeCommand execute:nil];
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

#pragma mark - Private
- (CGRect)clearButtonRectForBounds:(CGRect)bounds{
    CGRect rect = [super clearButtonRectForBounds:bounds];
    CGFloat x = rect.origin.x - kAuthCodeBtnWidth - 10;
    return CGRectMake(x, rect.origin.y , rect.size.width, rect.size.height);
}

- (void)setViewModel:(SSJLoginVerifyPhoneNumViewModel *)viewModel {
    _viewModel = viewModel;
}

//  开始倒计时
- (void)beginCountdownIfNeeded {
    if (!self.countdownTimer.valid && !self.countdownTimer) {
        self.countdown = kCountdownLimit;
                self.countdownTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateCountdown) userInfo:nil repeats:YES];
        //
//        [[[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] takeUntil:self.rac_willDeallocSignal ] subscribeNext:^(id x) {
//            [self updateCountdown];
//        }];
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
        [self.getAuthCodeBtn setTitle:[NSString stringWithFormat:@"%ds",(int)self.countdown] forState:UIControlStateDisabled];
    } else {
        self.getAuthCodeBtn.enabled = YES;
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
        [_getAuthCodeBtn setTitleColor:[UIColor ssj_colorWithHex:@"#f9cbd0"] forState:UIControlStateDisabled];
        [_getAuthCodeBtn ssj_setBorderStyle:SSJBorderStyleLeft];
        [_getAuthCodeBtn ssj_setBorderWidth:1/SSJSCREENSCALE];
        
        [[_getAuthCodeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
            [[self.viewModel.getVerificationCodeCommand execute:nil] subscribeNext:^(RACTuple *tuple) {
                //请求成功并且不需要图形验证码的时候开启倒计时
                if ([tuple.first isEqualToString:@"1"]) {//发送验证码成功
                    //倒计时
                    [self beginCountdownIfNeeded];
                } else if ([tuple.first isEqualToString:@"2"]) {//需要图片验证码
                    //显示图形验证码
                    self.graphVerView.verImage = [tuple.second base64ToImage];
                    [self.graphVerView show];
                } else if ([tuple.first isEqualToString:@"3"]) {//图片验证码错误
                    [CDAutoHideMessageHUD showMessage:@"图片验证码错误"];
                } else {
                    [CDAutoHideMessageHUD showMessage:tuple.last];
                }
            }];
//            [self.viewModel.getVerificationCodeCommand.executionSignals.switchToLatest subscribeNext:^(RACTuple *tuple) {
//                
//            }];
            
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
        [[_graphVerView.reChooseBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
            //点击重新获取图形验证码
            [self.viewModel.reGetVerificationCodeCommand execute:nil];
            [self.viewModel.reGetVerificationCodeCommand.executionSignals.switchToLatest subscribeNext:^(UIImage *image) {
                //成功刷新验证码
                self.graphVerView.verImage = image;
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
    [self ssj_setBorderColor:SSJ_CELL_SEPARATOR_COLOR];
    [self.getAuthCodeBtn ssj_setBorderColor:SSJ_CELL_SEPARATOR_COLOR];
}

@end
