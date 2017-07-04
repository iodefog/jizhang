//
//  SSJChangeMobileNoSecondViewController.m
//  SuiShouJi
//
//  Created by old lang on 2017/6/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJChangeMobileNoSecondViewController.h"
#import "SSJChangeMobileNoThirdViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SSJChangeMobileNoStepView.h"
#import "SSJMobileNoField.h"
#import "SSJLoginVerifyPhoneNumViewModel.h"

@interface SSJChangeMobileNoSecondViewController ()

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, strong) SSJChangeMobileNoStepView *stepView;

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *descLab;

@property (nonatomic, strong) SSJMobileNoField *mobileNoField;

@property (nonatomic, strong) UIButton *nextBtn;

@property (nonatomic, strong) SSJLoginVerifyPhoneNumViewModel *viewModel;

@end

@implementation SSJChangeMobileNoSecondViewController

#pragma mark - Lifecycle
- (void)dealloc {
    
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"新手机号";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpViews];
    [self setupBindings];
    [self updateAppearance];
    [self.view setNeedsUpdateConstraints];
//    [self.mobileNoField becomeFirstResponder];
}

- (void)updateViewConstraints {
    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(SSJ_NAVIBAR_BOTTOM, 0, 0, 0));
    }];
    [self.stepView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView).offset(30);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    [self.icon mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.stepView.mas_bottom).offset(30);
        make.centerX.mas_equalTo(self.scrollView);
        make.size.mas_equalTo(self.icon.image.size);
    }];
    [self.descLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon.mas_bottom).offset(30);
        make.centerX.mas_equalTo(self.scrollView);
        make.height.mas_equalTo(22);
    }];
    [self.mobileNoField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.descLab.mas_bottom).offset(28);
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.right.mas_equalTo(self.scrollView).offset(-15);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    [self.nextBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mobileNoField.mas_bottom).offset(40);
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.right.mas_equalTo(self.scrollView).offset(-15);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.scrollView);
        make.bottom.mas_equalTo(self.scrollView).offset(-20);
    }];
    [super updateViewConstraints];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

#pragma mark - Private
- (void)updateAppearance {
    self.descLab.textColor = SSJ_MAIN_COLOR;
    [self.mobileNoField updateAppearanceAccordingToTheme];
    [self.nextBtn ssj_setBackgroundColor:SSJ_BUTTON_NORMAL_COLOR forState:UIControlStateNormal];
    [self.nextBtn ssj_setBackgroundColor:SSJ_BUTTON_DISABLE_COLOR forState:UIControlStateDisabled];
}

- (void)setUpViews {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.stepView];
    [self.scrollView addSubview:self.icon];
    [self.scrollView addSubview:self.descLab];
    [self.scrollView addSubview:self.mobileNoField];
    [self.scrollView addSubview:self.nextBtn];
}

- (void)setupBindings {
    RAC(self.viewModel,phoneNum) = [self.mobileNoField rac_textSignal];
    RAC(self.nextBtn,enabled) = self.viewModel.enableVerifySignal;
//    RAC(self.mobileNoField,enabled) = self
    
    @weakify(self);
    [[self.nextBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.mobileNoField resignFirstResponder];
    }];
    
    self.nextBtn.rac_command = self.viewModel.verifyPhoneNumRequestCommand;
    [self.nextBtn.rac_command.executionSignals.switchToLatest subscribeNext:^(NSNumber *result) {
        @strongify(self);
        if ([result boolValue]) {
//            NSError *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"此手机号已经注册过了，换一个吧"}];
//            [SSJAlertViewAdapter showError:error completion:^{
//                [self.mobileNoField becomeFirstResponder];
//            }];
            [CDAutoHideMessageHUD showMessage:@"此手机号已经绑定过了，换一个吧"];
            [self.mobileNoField becomeFirstResponder];
        } else {
            SSJChangeMobileNoThirdViewController *thirdVC = [[SSJChangeMobileNoThirdViewController alloc] init];
            thirdVC.mobileNo = self.mobileNoField.text;
            [self.navigationController pushViewController:thirdVC animated:YES];
        }
    } error:NULL];
}

#pragma mark - Lazyloading
- (TPKeyboardAvoidingScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] init];
    }
    return _scrollView;
}

- (SSJChangeMobileNoStepView *)stepView {
    if (!_stepView) {
        _stepView = [[SSJChangeMobileNoStepView alloc] initWithStep:3];
        _stepView.currentStep = 2;
    }
    return _stepView;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bind_No_mobile"]];
    }
    return _icon;
}

- (UILabel *)descLab {
    if (!_descLab) {
        _descLab = [[UILabel alloc] init];
        _descLab.text = @"新手机号，新的开始";
        _descLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _descLab;
}

- (SSJMobileNoField *)mobileNoField {
    if (!_mobileNoField) {
        _mobileNoField = [[SSJMobileNoField alloc] init];
    }
    return _mobileNoField;
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextBtn.clipsToBounds = YES;
        _nextBtn.layer.cornerRadius = 6;
        _nextBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _nextBtn;
}

- (SSJLoginVerifyPhoneNumViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[SSJLoginVerifyPhoneNumViewModel alloc] init];
        _viewModel.agreeProtocol = YES;
    }
    return _viewModel;
}

@end
