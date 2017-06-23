//
//  SSJLoginVerifyPhoneViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/6/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJLoginVerifyPhoneViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SSJNormalWebViewController.h"
#import "SSJMotionPasswordViewController.h"
#import "MMDrawerController.h"

#import "SSJLoginVerifyPhoneNumViewModel.h"

#import "SSJUserTableManager.h"
#import "SSJDatabaseQueue.h"



@interface SSJLoginVerifyPhoneViewController ()
@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

/**手机号输入框*/
@property (nonatomic, strong) UITextField *numTextF;


@property (nonatomic, strong) UILabel *phonePreL;

@property (nonatomic, strong) UIButton *verifyPhoneBtn;

@property (nonatomic, strong) UIButton *agreeButton;

@property (nonatomic, strong) UIButton *protocolButton;

@property (nonatomic,strong)UIButton *tencentLoginButton;

@property (nonatomic,strong)UIButton *weixinLoginButton;

@property (nonatomic, strong) SSJLoginVerifyPhoneNumViewModel *verifyPhoneViewModel;
@end

@implementation SSJLoginVerifyPhoneViewController

#pragma mark - System
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
        self.title = @"登录";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialUI];
    [self initialBind];
}

#pragma mark - Layout
- (void)updateViewConstraints {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.phonePreL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100);
        make.height.mas_equalTo(50);
        make.left.mas_equalTo(self.scrollView.mas_left).offset(20);
        make.width.mas_lessThanOrEqualTo(40);
    }];
    
    [self.numTextF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.phonePreL.mas_right);
        make.top.height.mas_equalTo(self.phonePreL);
        make.right.mas_equalTo(self.view).offset(-20);
    }];
    
    [self.verifyPhoneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.mas_equalTo(self.phonePreL);
        make.top.mas_equalTo(self.numTextF.mas_bottom).offset(40);
        make.right.mas_equalTo(self.numTextF);
    }];
    
    [self.agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.phonePreL);
        make.width.height.mas_equalTo(20);
        make.top.mas_equalTo(self.verifyPhoneBtn.mas_bottom).offset(10);
    }];
    
    [self.protocolButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.agreeButton.mas_right);
        make.width.greaterThanOrEqualTo(0);
        make.height.top.mas_equalTo(self.agreeButton);
    }];
    
    [self.weixinLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).offset(-50);
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.right.mas_equalTo(self.scrollView.mas_centerX).offset(-10);
    }];
    
    [self.tencentLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.bottom.mas_equalTo(self.weixinLoginButton);
        make.left.mas_equalTo(self.scrollView.mas_centerX).offset(10);
    }];
    
    [super updateViewConstraints];
}

#pragma mark - Private
- (void)initialUI {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.numTextF];
    [self.scrollView addSubview:self.phonePreL];
    [self.scrollView addSubview:self.verifyPhoneBtn];
    [self.scrollView addSubview:self.agreeButton];
    [self.scrollView addSubview:self.protocolButton];
    [self.scrollView addSubview:self.weixinLoginButton];
    [self.scrollView addSubview:self.tencentLoginButton];
    [self updateViewConstraints];
}


/**
 信号绑定
 */
- (void)initialBind {
    RAC(self.verifyPhoneViewModel,phoneNum) = self.numTextF.rac_textSignal;
    RAC(self.verifyPhoneViewModel, agreeProtocol) = RACObserve(self.agreeButton,selected);
}

#pragma mark - Lazy
- (TPKeyboardAvoidingScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.contentSize = CGSizeMake(0, self.view.height);
    }
    return _scrollView;
}

- (UITextField *)numTextF {
    if (!_numTextF) {
        _numTextF = [[UITextField alloc] init];
        _numTextF.placeholder = @"请输入手机号";
    }
    return _numTextF;
}

- (UILabel *)phonePreL {
    if (!_phonePreL) {
        _phonePreL = [[UILabel alloc] init];
        _phonePreL.text = @"+86";
    }
    return _phonePreL;
}

- (UIButton *)verifyPhoneBtn {
    if (!_verifyPhoneBtn) {
        _verifyPhoneBtn = [[UIButton alloc] init];
        [_verifyPhoneBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [_verifyPhoneBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"f9cbd0"] forState:UIControlStateDisabled];
        [_verifyPhoneBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"ea4a64"] forState:UIControlStateNormal];
        RAC(_verifyPhoneBtn,enabled) = self.verifyPhoneViewModel.enableVerifySignal;

        @weakify(self);
        [[_verifyPhoneBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
//            [self.verifyPhoneViewModel.verifyPhoneNumRequestCommand execute:nil];
            [[self.verifyPhoneViewModel.verifyPhoneNumRequestCommand execute:nil] subscribeNext:^(id x) {
                //请求返回处理好的数据
                NSLog(@"-----%%%%))*)()%@",x);
            }];
        }];
    }
    return _verifyPhoneBtn;
}

- (UIButton *)agreeButton {
    if (!_agreeButton) {
        _agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _agreeButton.selected = YES;
        [_agreeButton setImage:nil forState:UIControlStateNormal];
        [_agreeButton setImage:[[UIImage imageNamed:@"register_agreement"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        _agreeButton.tintColor = [UIColor ssj_colorWithHex:@"ea4a64"];
        [[_agreeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
            btn.selected = !btn.selected;
        }];
        [_agreeButton ssj_setBorderWidth:1];
        [_agreeButton ssj_setBorderStyle:SSJBorderStyleAll];
        [_agreeButton ssj_setBorderColor:[UIColor ssj_colorWithHex:@"ea4a64"]];
    }
    return _agreeButton;
}

- (UIButton *)protocolButton {
    if (!_protocolButton) {
        _protocolButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _protocolButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        NSString *oldStr = @"我已阅读并同意用户协定";
        [_protocolButton setAttributedTitle:[oldStr attributeStrWithTargetStr:@"用户协定" range:NSMakeRange(0, 0) color:[UIColor ssj_colorWithHex:@"ea4a64"]] forState:UIControlStateNormal];
        [_protocolButton setTitleColor:[UIColor ssj_colorWithHex:@"666666"] forState:UIControlStateNormal];
        @weakify(self);
        [[_protocolButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            SSJNormalWebViewController *userAgreementVC = [SSJNormalWebViewController webViewVCWithURL:[NSURL URLWithString:SSJUserProtocolUrl]];
            userAgreementVC.title = @"用户协定";
            [self.navigationController pushViewController:userAgreementVC animated:YES];
        }];
    }
    return _protocolButton;
}

-(UIButton *)tencentLoginButton{
    if (!_tencentLoginButton) {
        _tencentLoginButton = [[UIButton alloc]init];
        [_tencentLoginButton setImage:[UIImage imageNamed:@"login_qq"] forState:UIControlStateNormal];
        //        _tencentLoginButton.size = CGSizeMake(35, 35);
        [_tencentLoginButton sizeToFit];
        _tencentLoginButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor];
        _tencentLoginButton.contentMode = UIViewContentModeCenter;
//        [_tencentLoginButton addTarget:self action:@selector(qqLoginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tencentLoginButton;
}

-(UIButton *)weixinLoginButton{
    if (!_weixinLoginButton) {
        _weixinLoginButton = [[UIButton alloc]init];
        [_weixinLoginButton setImage:[UIImage imageNamed:@"login_weixin"] forState:UIControlStateNormal];
        [_weixinLoginButton sizeToFit];
        _weixinLoginButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginMainColor];
        _weixinLoginButton.contentMode = UIViewContentModeCenter;
        [[_weixinLoginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [self.verifyPhoneViewModel.wxLoginCommand execute:nil];
        }];
    }
    return _weixinLoginButton;
}

- (SSJLoginVerifyPhoneNumViewModel *)verifyPhoneViewModel {
    if (!_verifyPhoneViewModel) {
        _verifyPhoneViewModel = [[SSJLoginVerifyPhoneNumViewModel alloc] init];
        _verifyPhoneViewModel.vc = self;
    }
    return _verifyPhoneViewModel;
}

@end
