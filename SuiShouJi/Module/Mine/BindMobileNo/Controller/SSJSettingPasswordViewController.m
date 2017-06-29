//
//  SSJSettingPasswordViewController.m
//  SuiShouJi
//
//  Created by old lang on 2017/6/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJSettingPasswordViewController.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface SSJSettingPasswordViewController ()

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *descLab;

@property (nonatomic, strong) UITextField *authCodeField;

@property (nonatomic, strong) UITextField *passwordField;

@property (nonatomic, strong) UIButton *bindingBtn;

@end

@implementation SSJSettingPasswordViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle];
    [self setUpViews];
    [self setUpBindings];
    [self updateAppearance];
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints {
    [self.scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(SSJ_NAVIBAR_BOTTOM, 0, 0, 0));
    }];
    [self.icon mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView).offset(30);
        make.centerX.mas_equalTo(self.scrollView);
        make.size.mas_equalTo(CGSizeMake(74, 94));
    }];
    [self.descLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon.mas_bottom).offset(30);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    [self.authCodeField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.descLab.mas_bottom).offset(18);
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.right.mas_equalTo(self.scrollView).offset(-15);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    [self.passwordField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.authCodeField.mas_bottom).offset(18);
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.right.mas_equalTo(self.scrollView).offset(-15);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.scrollView);
    }];
    [self.bindingBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.passwordField.mas_bottom).offset(34);
        make.left.mas_equalTo(self.scrollView).offset(15);
        make.bottom.mas_equalTo(self.scrollView).offset(-40);
        make.right.mas_equalTo(self.scrollView).offset(-15);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.scrollView);
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
    //    [self.authCodeField updateAppearanceAccordingToTheme];
    //    [self.passwordField updateAppearanceAccordingToTheme];
    [self.bindingBtn ssj_setBackgroundColor:SSJ_BUTTON_NORMAL_COLOR forState:UIControlStateNormal];
    [self.bindingBtn ssj_setBackgroundColor:SSJ_BUTTON_DISABLE_COLOR forState:UIControlStateDisabled];
}

- (void)setTitle {
    switch (self.type) {
        case SSJSettingPasswordTypeMobileNoBinding:
            self.title = @"绑定手机号";
            break;
            
        case SSJSettingPasswordTypeResettingPassword:
            self.title = @"重设密码";
            break;
    }
}

- (void)setUpViews {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.icon];
    [self.scrollView addSubview:self.descLab];
    [self.scrollView addSubview:self.authCodeField];
    [self.scrollView addSubview:self.passwordField];
    [self.scrollView addSubview:self.bindingBtn];
}

- (void)setUpBindings {
    
}

#pragma mark - Lazyloading
- (TPKeyboardAvoidingScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:self.view.bounds];
    }
    return _scrollView;
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

- (UIButton *)bindingBtn {
    if (!_bindingBtn) {
        _bindingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _bindingBtn.clipsToBounds = YES;
        _bindingBtn.layer.cornerRadius = 6;
        _bindingBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_bindingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        switch (self.type) {
            case SSJSettingPasswordTypeMobileNoBinding:
                [_bindingBtn setTitle:@"绑定" forState:UIControlStateNormal];
                break;
                
            case SSJSettingPasswordTypeResettingPassword:
                [_bindingBtn setTitle:@"确定" forState:UIControlStateNormal];
                break;
        }
    }
    return _bindingBtn;
}

@end
