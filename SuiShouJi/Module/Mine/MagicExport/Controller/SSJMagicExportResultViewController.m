//
//  SSJMagicExportResultViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/4/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportResultViewController.h"
#import "SSJMagicExportResultCheckMarkView.h"
#import "SSJBookKeepingHomeViewController.h"

@interface SSJMagicExportResultViewController ()

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) SSJMagicExportResultCheckMarkView *checkMark;

@property (nonatomic, strong) UILabel *remindLab;

@property (nonatomic, strong) UIButton *goBackBtn;

@end

@implementation SSJMagicExportResultViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.navigationItem.title = @"数据导出";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.checkMark];
    [self.contentView addSubview:self.remindLab];
    [self.contentView addSubview:self.goBackBtn];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.checkMark startAnimation:^{
        
    }];
}

- (void)goBackHomeAction {
    UITabBarController *tabVC = (UITabBarController *)self.navigationController.tabBarController;
    if ([tabVC isKindOfClass:[UITabBarController class]]) {
        UINavigationController *homeNavi = [tabVC.viewControllers firstObject];
        if ([homeNavi isKindOfClass:[UINavigationController class]]) {
            SSJBookKeepingHomeViewController *homeVC = [homeNavi.viewControllers firstObject];
            if ([homeVC isKindOfClass:[SSJBookKeepingHomeViewController class]]) {
                tabVC.selectedIndex = 0;
                [self.navigationController popToRootViewControllerAnimated:NO];
            }
        }
    }
}

#pragma marm - Getter
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM + 10, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM - 10)];
        _contentView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return _contentView;
}

- (SSJMagicExportResultCheckMarkView *)checkMark {
    if (!_checkMark) {
        _checkMark = [[SSJMagicExportResultCheckMarkView alloc] initWithRadius:30];
        _checkMark.backgroundColor = [UIColor clearColor];
        _checkMark.center = CGPointMake(self.view.width * 0.5, 66);
    }
    return _checkMark;
}

- (UILabel *)remindLab {
    if (!_remindLab) {
        _remindLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 140, self.view.width, 18)];
        _remindLab.backgroundColor = [UIColor clearColor];
        _remindLab.font = [UIFont systemFontOfSize:18];
        _remindLab.textAlignment = NSTextAlignmentCenter;
        _remindLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _remindLab.text = @"提交成功，请至您的邮箱查看";
    }
    return _remindLab;
}

- (UIButton *)goBackBtn {
    if (!_goBackBtn) {
        _goBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _goBackBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_goBackBtn setTitle:@"返回首页" forState:UIControlStateNormal];
        [_goBackBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
        [_goBackBtn addTarget:self action:@selector(goBackHomeAction) forControlEvents:UIControlEventTouchUpInside];
        [_goBackBtn sizeToFit];
        _goBackBtn.center = CGPointMake(self.view.width * 0.5, 260);
    }
    return _goBackBtn;
}

@end
