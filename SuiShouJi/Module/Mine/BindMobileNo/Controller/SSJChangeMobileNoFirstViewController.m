//
//  SSJChangeMobileNoFirstViewController.m
//  SuiShouJi
//
//  Created by old lang on 2017/6/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJChangeMobileNoFirstViewController.h"

#import "TPKeyboardAvoidingScrollView.h"
#import "SSJChangeMobileNoStepView.h"
#import "SSJUserTableManager.h"

@interface SSJChangeMobileNoFirstViewController ()

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, strong) SSJChangeMobileNoStepView *stepView;

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *descLab;

@property (nonatomic, strong) UITextField *authCodeField;

@property (nonatomic, strong) UIButton *nextBtn;

@property (nonatomic, strong) UIButton *changeWayBtn;

@end

@implementation SSJChangeMobileNoFirstViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"验证原手机号";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadMobileNo:^{
        [self setUpViews];
        [self.view setNeedsUpdateConstraints];
    }];
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
    }];
    [self.authCodeField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.descLab.mas_bottom).offset(28);
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.right.mas_equalTo(self.scrollView).offset(-15);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    [self.nextBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.authCodeField.mas_bottom).offset(40);
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.right.mas_equalTo(self.scrollView).offset(-15);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    [self.changeWayBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nextBtn.mas_bottom).offset(0);
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.size.mas_equalTo(CGSizeMake(106, 38));
        make.bottom.mas_equalTo(self.scrollView).offset(-20);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    [super updateViewConstraints];
}

#pragma mark - Private
- (void)loadMobileNo:(void(^)())completion {
    [self.view ssj_showLoadingIndicator];
    [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
        [self.view ssj_hideLoadingIndicator];
//        [self updateMobileNoLab:userItem.mobileNo];
        if (completion) {
            completion();
        }
    } failure:^(NSError * _Nonnull error) {
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showError:error];
    }];
}

- (void)updateAppearance {
    self.descLab.textColor = SSJ_MAIN_COLOR;
    //    [self.authCodeField updateAppearanceAccordingToTheme];
    //    [self.passwordField updateAppearanceAccordingToTheme];
    [self.nextBtn ssj_setBackgroundColor:SSJ_BUTTON_NORMAL_COLOR forState:UIControlStateNormal];
    [self.nextBtn ssj_setBackgroundColor:SSJ_BUTTON_DISABLE_COLOR forState:UIControlStateDisabled];
    [self.changeWayBtn setTitleColor:SSJ_MAIN_COLOR forState:UIControlStateNormal];
}

- (void)setUpViews {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.stepView];
    [self.scrollView addSubview:self.icon];
    [self.scrollView addSubview:self.descLab];
    [self.scrollView addSubview:self.authCodeField];
    [self.scrollView addSubview:self.nextBtn];
    [self.scrollView addSubview:self.changeWayBtn];
}

#pragma mark - Lazyloading
- (TPKeyboardAvoidingScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:self.view.bounds];
    }
    return _scrollView;
}

- (SSJChangeMobileNoStepView *)stepView {
    if (!_stepView) {
        _stepView = [[SSJChangeMobileNoStepView alloc] initWithStep:3];
        _stepView.currentStep = 1;
    }
    return _stepView;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bind_No_SMS"]];
    }
    return _icon;
}

- (UILabel *)descLab {
    if (!_descLab) {
        _descLab = [[UILabel alloc] init];
        _descLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _descLab;
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextBtn.clipsToBounds = YES;
        _nextBtn.layer.cornerRadius = 3;
        _nextBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _nextBtn;
}

- (UIButton *)changeWayBtn {
    if (!_changeWayBtn) {
        _changeWayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeWayBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [_changeWayBtn setTitle:@"手机号丢失或停用" forState:UIControlStateNormal];
    }
    return _changeWayBtn;
}

@end
