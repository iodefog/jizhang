//
//  SSJMobileNoBindingDetailViewController.m
//  SuiShouJi
//
//  Created by old lang on 2017/6/27.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJMobileNoBindingDetailViewController.h"
#import "SSJChangeMobileNoFirstViewController.h"
#import "SSJUserTableManager.h"

@interface SSJMobileNoBindingDetailViewController ()

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *descLab;

@property (nonatomic, strong) UIButton *changeBtn;

@end

@implementation SSJMobileNoBindingDetailViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"手机号";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadMobileNo:^{
        [self setUpViews];
        [self updateAppearance];
        [self.view setNeedsUpdateConstraints];
    }];
}

- (void)updateViewConstraints {
    [self.icon mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(SSJ_NAVIBAR_BOTTOM + 46);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(98, 103));
    }];
    [self.descLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.icon.mas_bottom).offset(25);
        make.height.mas_equalTo(22);
        make.centerX.mas_equalTo(self.view);
    }];
    [self.changeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.descLab.mas_bottom).offset(50);
        make.left.mas_equalTo(self.view).offset(15);
        make.right.mas_equalTo(self.view).offset(-15);
        make.height.mas_equalTo(44);
        make.centerX.mas_equalTo(self.view);
    }];
    [super updateViewConstraints];
}

#pragma mark - Theme
- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

#pragma mark - Private
- (void)loadMobileNo:(void(^)())completion {
    [self.view ssj_showLoadingIndicator];
    [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
        [self.view ssj_hideLoadingIndicator];
        [self updateMobileNoLab:userItem.mobileNo];
        if (completion) {
            completion();
        }
    } failure:^(NSError * _Nonnull error) {
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showError:error];
    }];
}

- (void)setUpViews {
    [self.view addSubview:self.icon];
    [self.view addSubview:self.descLab];
    [self.view addSubview:self.changeBtn];
}

- (void)updateAppearance {
    self.descLab.textColor = SSJ_MAIN_COLOR;
    [self.changeBtn ssj_setBackgroundColor:SSJ_BUTTON_NORMAL_COLOR forState:UIControlStateNormal];
    [self.changeBtn ssj_setBackgroundColor:SSJ_BUTTON_DISABLE_COLOR forState:UIControlStateDisabled];
}

- (void)updateMobileNoLab:(NSString *)mobileNo {
    if (mobileNo.length >= 7) {
        mobileNo = [mobileNo stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        self.descLab.text = [NSString stringWithFormat:@"已绑定手机号：%@", mobileNo];
    }
}

#pragma mark - Lazyloading
- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bind_No_phone"]];
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

- (UIButton *)changeBtn {
    if (!_changeBtn) {
        _changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeBtn.clipsToBounds = YES;
        _changeBtn.layer.cornerRadius = 6;
        _changeBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_changeBtn setTitle:@"更换手机号" forState:UIControlStateNormal];
        [_changeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[_changeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            SSJChangeMobileNoFirstViewController *firstVC = [[SSJChangeMobileNoFirstViewController alloc] init];
            [self.navigationController pushViewController:firstVC animated:YES];
        }];
    }
    return _changeBtn;
}

@end
