//
//  SSJLoginGraphVerView.m
//  SuiShouJi
//
//  Created by yi cai on 2017/6/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJLoginGraphVerView.h"

#import "SSJLoginVerifyPhoneNumViewModel.h"
#import "SSJStringAddition.h"

@interface SSJLoginGraphVerView ()

@property (nonatomic, strong) UILabel *titleL;

@property (nonatomic, strong) UIImageView *verImageView;

//@property (nonatomic, strong) UIButton *reChooseBtn;

/**验证码输入框*/
@property (nonatomic, strong) UITextField *verNumTextF;

/**commit*/
@property (nonatomic, strong) UIButton *commitBtn;
@end

@implementation SSJLoginGraphVerView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleL];
        [self addSubview:self.verImageView];
        [self addSubview:self.verNumTextF];
        [self addSubview:self.reChooseBtn];
        [self addSubview:self.commitBtn];
        
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
        [self initBind];//信号绑定
        self.backgroundColor = [UIColor whiteColor];
        [self updateConstraintsIfNeeded];
    }
    return self;
}

- (void)initBind{
    RAC(self.verViewModel,graphNum) = self.verNumTextF.rac_textSignal;
}

- (void)updateConstraints {
    [self.titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(34);
        make.left.right.mas_offset(0);
        make.height.greaterThanOrEqualTo(0);
    }];
    
    [self.verImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(49);
        make.right.mas_offset(-49);
        make.height.mas_offset(40);
        make.top.mas_equalTo(self.titleL.mas_bottom).offset(10);
    }];
    
    [self.reChooseBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.verImageView.mas_right).offset(13);
        make.centerY.mas_equalTo(self.verImageView.mas_centerY);
    }];
    
    [self.verNumTextF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.verImageView);
        make.top.mas_equalTo(self.verImageView.mas_bottom).offset(10);
        make.height.mas_equalTo(self.verImageView);
    }];
    
    [self.commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottomMargin.mas_equalTo(0);
        make.height.mas_equalTo(47);
    }];
    [super updateConstraints];
}

#pragma mark - Private
- (void)show {
    if (self.superview) return;
    self.verNumTextF.text = nil;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.3 target:self touchAction:@selector(dismiss) animation:^{
        self.hidden = NO;
    } timeInterval:0.25 fininshed:NULL];
    [self.verNumTextF becomeFirstResponder];
}

- (void)dismiss {
    if (!self.superview) return;
    [self.superview ssj_hideBackViewForView:self animation:^{
        self.hidden = YES;
    } timeInterval:0.25 fininshed:NULL];
    [self.verNumTextF resignFirstResponder];
}

- (void)setVerImage:(UIImage *)verImage {
    _verImage = verImage;
    self.verImageView.image = verImage;
}

#pragma mark - Lazy
- (UILabel *)titleL {
    if (!_titleL) {
        _titleL = [[UILabel alloc] init];
        _titleL.text = @"请输入图片验证码，表明你是地球人😄";
        _titleL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _titleL.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _titleL.numberOfLines = 0;
        _titleL.preferredMaxLayoutWidth = SSJSCREENWITH - 56;
        _titleL.textAlignment = NSTextAlignmentCenter;
    }
    return _titleL;
}


- (UIImageView *)verImageView {
    if (!_verImageView) {
        _verImageView = [[UIImageView alloc] init];
//        _verImageView.backgroundColor = [UIColor ssj_colorWithHex:@"#cccccc"];
        _verImageView.contentMode = UIViewContentModeCenter;
    }
    return _verImageView;
}

- (UIButton *)reChooseBtn {
    if (!_reChooseBtn) {
        _reChooseBtn = [[UIButton alloc] init];
        [_reChooseBtn setImage:[UIImage imageNamed:@"login_combinedShape"] forState:UIControlStateNormal];
    }
    return _reChooseBtn;
}

- (UITextField *)verNumTextF {
    if (!_verNumTextF) {
        _verNumTextF = [[UITextField alloc] init];
        _verNumTextF.textColor = [UIColor ssj_colorWithHex:@"#333333"];
        _verNumTextF.keyboardType = UIKeyboardTypeNumberPad;
        _verNumTextF.textAlignment = NSTextAlignmentCenter;
        [_verNumTextF ssj_setBorderColor:[UIColor ssj_colorWithHex:@"#cccccc"]];
        [_verNumTextF ssj_setBorderStyle:SSJBorderStyleBottom];
        [_verNumTextF ssj_setBorderWidth:1/SSJSCREENSCALE];
    }
    return _verNumTextF;
}

- (UIButton *)commitBtn {
    if (!_commitBtn) {
        _commitBtn = [[UIButton alloc] init];
        [_commitBtn setTitle:@"提交" forState:UIControlStateNormal];
        _commitBtn.backgroundColor = [UIColor ssj_colorWithHex:@"#EB4A64"];
        [[_commitBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
            //发送获取验证码请求
            [self.verViewModel.getVerificationCodeCommand execute:nil];
        }];
    }
    return _commitBtn;
}

@end
