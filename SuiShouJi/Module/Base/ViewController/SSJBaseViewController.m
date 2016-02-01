//
//  SSJBaseViewController.m
//  MoneyMore
//
//  Created by old lang on 15-3-22.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "UIViewController+SSJPageFlow.h"
#import "MobClick.h"
#import "SSJLoginViewController.h"

@interface SSJBaseViewController () <UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIBarButtonItem *syncLoadingItem;

@end

@implementation SSJBaseViewController

#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataIfNeeded) name:SSJSyncDataSuccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSyncLoadingIndicator) name:SSJShowSyncLoadingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSyncLoadingIndicator) name:SSJHideSyncLoadingNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
    [self addTapGestureRecognizerIfNeeded];
    
    if (self.navigationController && [[self.navigationController viewControllers] count] > 1) {
        if (!self.navigationItem.leftBarButtonItem) {
            [self ssj_showBackButtonWithTarget:self selector:@selector(ssj_backOffAction)];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor ssj_colorWithHex:@"#cccccc"];
    self.navigationController.navigationBar.barTintColor = nil;
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:21],
                                                                    NSForegroundColorAttributeName:[UIColor blackColor]};
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.title.length) {
        [MobClick beginLogPageView:self.title];
    }
    if (self.navigationController && [[self.navigationController viewControllers] count] > 1) {
        self.navigationController.interactivePopGestureRecognizer.enabled=YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled=NO;
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.title.length) {
        [MobClick endLogPageView:self.title];
    }
}

- (void)reloadDataIfNeeded {
    if (SSJVisibalController() == self) {
        [self reloadDataAfterSync];
    }
}

- (void)reloadDataAfterSync {
    
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidStart:(SSJBaseNetworkService *)service {
    
}

/* 将接口返回的code 值转换为前端现实用的文字
 9001 token已注销
 9002 验证失败,token已过期
 9003 密码已修改
 9004 账户已禁用
 9005 未查到相关token记录
 9006 查询token信息出错
 9007 token验证不通过
 9009 未登录
 */
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    NSInteger codeint = [service.returnCode integerValue];
    
    if (codeint == 1) {
        return;
    }
    
    NSString *message = service.desc.length > 0 ? service.desc : SSJ_ERROR_MESSAGE;
    
    if (codeint == 9001
        || codeint == 9002
        || codeint == 9003
        || codeint == 9005
        || codeint == 9006
        || codeint == 9007
        || codeint == 9009) {
        
        SSJClearLoginInfo();
        
        if (service.showLoginControllerIfTokenInvalid
            && ![SSJVisibalController() isKindOfClass:[SSJLoginViewController class]]) {
            
            if (service.showMessageIfErrorOccured) {
                [CDAutoHideMessageHUD showMessage:message];
            }
            
            __weak typeof(self) weakSelf = self;
            SSJLoginViewController *loginVC = [[SSJLoginViewController alloc] initWithNibName:nil bundle:nil];
            loginVC.finishHandle = ^(UIViewController *controller) {
                controller.backController = weakSelf;
                [controller ssj_backOffAction];
            };
            loginVC.cancelHandle = ^(UIViewController *controller) {
                controller.backController = [weakSelf ssj_previousViewController];
                [controller ssj_backOffAction];
            };
            
            [loginVC ssj_showBackButtonWithTarget:loginVC selector:@selector(backOffAction)];
            UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [self presentViewController:naviVC animated:YES completion:NULL];
        }
        
    } else {
        if (service.showMessageIfErrorOccured) {
            [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:message action:[SSJAlertViewAction actionWithTitle:@"确认" handler:NULL], nil];
        }
    }
}

- (void)serverDidCancel:(SSJBaseNetworkService *)service {
    
}

- (void)server:(SSJBaseNetworkService *)service didFailLoadWithError:(NSError *)error {
    if (error.code == NSURLErrorUserCancelledAuthentication ||
        error.code == NSURLErrorCancelled) {
//        [SSJAppConfigManager loadSSLCertInfo];
    }
    
    NSString *errorMessage = SSJMessageWithErrorCode(error);
    [CDAutoHideMessageHUD showMessage:errorMessage ?: SSJ_ERROR_MESSAGE];
}

#pragma mark - Private
- (void)addTapGestureRecognizerIfNeeded {
    if (_hideKeyboradWhenTouch) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
        tapGesture.delegate = self;
        [self.view addGestureRecognizer:tapGesture];
    }
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (UIBarButtonItem *)syncLoadingItem {
    if (!_syncLoadingItem) {
        UIView *syncLoadingView = [[UIView alloc] init];
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicator startAnimating];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = @"同步中...";
        label.font = [UIFont systemFontOfSize:14];
        [label sizeToFit];
        
        [syncLoadingView addSubview:indicator];
        [syncLoadingView addSubview:label];
        
        CGFloat gap = 5;
        CGFloat width = label.width + indicator.width + gap;
        CGFloat height = MAX(label.height, indicator.height);
        syncLoadingView.size = CGSizeMake(width, height);
        
        label.left = indicator.right + gap;
        indicator.centerY = label.centerY = syncLoadingView.height * 0.5;
        
        _syncLoadingItem = [[UIBarButtonItem alloc] initWithCustomView:syncLoadingView];
    }
    return _syncLoadingItem;
}

- (void)showSyncLoadingIndicator {
    NSMutableArray *leftItems = [self.navigationItem.leftBarButtonItems mutableCopy];
    if (!leftItems) {
        leftItems = [@[] mutableCopy];
    }
    
    [leftItems addObject:self.syncLoadingItem];
    [self.navigationItem setLeftBarButtonItems:leftItems animated:YES];
}

- (void)hideSyncLoadingIndicator {
    NSMutableArray *leftItems = [self.navigationItem.leftBarButtonItems mutableCopy];
    [leftItems removeObject:self.syncLoadingItem];
    [self.navigationItem setLeftBarButtonItems:leftItems animated:YES];
}

@end
