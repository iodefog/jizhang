
//
//  SSJBaseViewController.m
//  MoneyMore
//
//  Created by old lang on 15-3-22.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "UIViewController+SSJPageFlow.h"
#import <UMMobClick/MobClick.h>
#import "SSJLoginViewController.h"
#import "SSJUserTableManager.h"
#import "UIViewController+MMDrawerController.h"
#import "SSJBookKeepingHomeViewController.h"
#import "SSJBooksTypeSelectViewController.h"
#import "SSJLoginViewController+SSJCategory.h"

@interface SSJBaseViewController () <UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *backgroundView;

@property (nonatomic, strong) UIBarButtonItem *syncLoadingItem;

@property (nonatomic) BOOL isDatabaseInitFinished;

@end

@implementation SSJBaseViewController

#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _appliesTheme = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataIfNeeded) name:SSJSyncDataSuccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSyncLoadingIndicator) name:SSJShowSyncLoadingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSyncLoadingIndicator) name:SSJHideSyncLoadingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishInitDatabase) name:SSJInitDatabaseDidFinishNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
    
    if (_appliesTheme) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];
        
        _backgroundView = [[UIImageView alloc] initWithImage:[UIImage ssj_compatibleThemeImageNamed:@"background"]];
        _backgroundView.frame = self.view.bounds;
        [self.view addSubview:_backgroundView];
    }
    
    if (self.navigationController && [[self.navigationController viewControllers] count] > 1) {
        if (!self.navigationItem.leftBarButtonItem) {
            [self ssj_showBackButtonWithTarget:self selector:@selector(goBackAction)];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self isKindOfClass:[SSJBookKeepingHomeViewController class]] || [self isKindOfClass:[SSJBooksTypeSelectViewController class]]) {
        self.mm_drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    }else{
        self.mm_drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeNone;
    }
    
    [self updateNavigationAppearance];
    [[UIApplication sharedApplication] setStatusBarStyle:SSJ_CURRENT_THEME.statusBarStyle];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:[self statisticsTitle]];
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
    [MobClick endLogPageView:[self statisticsTitle]];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return SSJ_CURRENT_THEME.statusBarStyle;
}

#pragma mark - UIResponder
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (self.hideKeyboradWhenTouch) {
        [self.view endEditing:YES];
    }
}

- (void)touchesCancelled:(nullable NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    if (self.hideKeyboradWhenTouch) {
        [self.view endEditing:YES];
    }
}

#pragma mark - Public
- (void)goBackAction {
    [self ssj_backOffAction];
}

- (void)reloadDataAfterSync {
    
}

- (void)reloadDataAfterInitDatabase {
    
}

- (void)updateAppearanceAfterThemeChanged {
    [_backgroundView ssj_setCompatibleThemeImageWithName:@"background"];
    [self updateNavigationAppearance];
    [[UIApplication sharedApplication] setStatusBarStyle:SSJ_CURRENT_THEME.statusBarStyle];
}

#pragma mark - Notification
- (void)reloadDataIfNeeded {
    if (SSJVisibalController() == self
        && self.isDatabaseInitFinished) {
        [self reloadDataAfterSync];
    }
}

- (void)didFinishInitDatabase {
    self.isDatabaseInitFinished = YES;
    if (SSJVisibalController() == self) {
        [self reloadDataAfterInitDatabase];
    }
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
        
        if ([SSJLoginViewController reloginIfNeeded] && service.showMessageIfErrorOccured) {
            [CDAutoHideMessageHUD showMessage:message];
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

- (NSString *)statisticsTitle {
    if (_statisticsTitle.length) {
        return _statisticsTitle;
    }
    
    if (self.title.length) {
        return self.title;
    }
    
    if (self.navigationItem.title.length) {
        return self.navigationItem.title;
    }
    
    if (self.tabBarItem.title.length) {
        return self.tabBarItem.title;
    }
    
    return @"";
}

- (void)updateNavigationAppearance {
    SSJThemeModel *themeModel = _appliesTheme ? [SSJThemeSetting currentThemeModel] : [SSJThemeSetting defaultThemeModel];
    self.navigationController.navigationBar.tintColor = [UIColor ssj_colorWithHex:themeModel.naviBarTintColor];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:themeModel.naviBarBackgroundColor alpha:themeModel.backgroundAlpha] size:CGSizeZero] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:21],
                                                                    NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:themeModel.naviBarTitleColor]};
}

@end
