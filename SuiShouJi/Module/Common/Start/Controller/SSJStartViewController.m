//
//  SSJStartViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/4/12.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJStartViewController.h"
#import "SSJGuideView.h"
#import "SSJStartView.h"
#import "SSJStartChecker.h"
#import "SSJBookkeepingTreeCheckInService.h"
#import "SSJBookkeepingTreeCheckInModel.h"
#import "SSJBookkeepingTreeStore.h"

#import "SSJMotionPasswordViewController.h"
#import "SSJBookKeepingHomeViewController.h"
#import "SSJMineHomeViewController.h"
#import "SSJFinancingHomeViewController.h"
#import "SSJReportFormsViewController.h"

static const NSTimeInterval kTransitionDuration = 0.3;

@interface SSJStartViewController ()

@property (nonatomic) BOOL isFirstLaunchForCurrentVersion;

@property (nonatomic) BOOL isServerStartViewShowed;

// 默认的启动页
@property (nonatomic, strong) UIImageView *defaultView;

@property (nonatomic, strong) UIImageView *startView;

@property (nonatomic, strong) SSJBookkeepingTreeCheckInService *checkInService;

@property (nonatomic, strong) SSJBookkeepingTreeCheckInModel *checkInModel;

@end

@implementation SSJStartViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isFirstLaunchForCurrentVersion = SSJIsFirstLaunchForCurrentVersion();
    _isServerStartViewShowed = _isFirstLaunchForCurrentVersion;
    
    _defaultView = [[UIImageView alloc] initWithImage:[UIImage ssj_compatibleImageNamed:@"default"]];
    _defaultView.frame = self.view.bounds;
    [self.view addSubview:_defaultView];
    
    if (!_isFirstLaunchForCurrentVersion) {
        _startView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_startView];
    }
    
    [self requestCheckIn];
    [self requestStartAPI];
}

// 请求签到接口
- (void)requestCheckIn {
    if (!_checkInService) {
        _checkInService = [[SSJBookkeepingTreeCheckInService alloc] initWithDelegate:self];
        _checkInService.showLodingIndicator = NO;
    }
    [_checkInService checkIn];
}

// 请求启动接口，检测是否有更新、苹果是否正在审核、加载下发启动页
- (void)requestStartAPI {
    __weak typeof(self) wself = self;
    [[SSJStartChecker sharedInstance] checkWithSuccess:^(BOOL isInReview, SSJAppUpdateType type) {
        // 如果是当前版本第一次启动就不显示服务端下发的启动页
        if (wself.isFirstLaunchForCurrentVersion) {
            [wself showTreeView];
            return;
        }
        // 有下发启动页，就显示；没有就显示记账树
        NSString *startImgUrl = [SSJStartChecker sharedInstance].startImageUrl;
        if (startImgUrl.length) {
            [wself showStartViewWithUrl:[NSURL URLWithString:startImgUrl]];
        } else {
            [wself showTreeView];
        }
    } failure:^(NSString *message) {
        [wself showGuideViewIfNeeded];
    }];
}

// 显示服务端下发的启动页
- (void)showStartViewWithUrl:(NSURL *)url {
    __weak typeof(self) wself = self;
    SDWebImageManager *manager = [[SDWebImageManager alloc] init];
    manager.imageDownloader.downloadTimeout = 2;
    [manager downloadImageWithURL:url options:SDWebImageContinueInBackground progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (!image || error) {
            return;
        }
        dispatch_main_sync_safe(^{
            [UIView transitionWithView:wself.startView duration:kTransitionDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                wself.startView.image = image;
            } completion:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    wself.isServerStartViewShowed = YES;
                    if (wself.checkInService.isLoaded) {
                        [wself showTreeView];
                    }
                });
            }];
        });
    }];
}

// 显示记账树启动页
- (void)showTreeView {
    if (_isFirstLaunchForCurrentVersion) {
        if (_checkInService.isLoaded) {
            [UIView transitionWithView:_defaultView duration:kTransitionDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                _defaultView.image = [UIImage imageNamed:[self treeName]];
            } completion:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                });
            }];
        }
    } else {
        
    }
    
    
}

// 当前版本第一次启动显示引导页
- (void)showGuideViewIfNeeded {
    if (_isFirstLaunchForCurrentVersion) {
        SSJGuideView *guideView = [[SSJGuideView alloc] initWithFrame:self.view.bounds];
        [guideView showWithFinish:^{
            [SSJMotionPasswordViewController verifyMotionPasswordIfNeeded:NULL];
        }];
    } else {
        [SSJMotionPasswordViewController verifyMotionPasswordIfNeeded:NULL];
    }
}

// 设置根控制器
- (void)resetRootViewController {
    SSJBookKeepingHomeViewController *bookKeepingVC = [[SSJBookKeepingHomeViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *bookKeepingNavi = [[UINavigationController alloc] initWithRootViewController:bookKeepingVC];
    bookKeepingNavi.tabBarItem.title = @"记账";
    bookKeepingNavi.tabBarItem.image = [UIImage imageNamed:@"tab_accounte_nor"];
    
    SSJReportFormsViewController *reportFormsVC = [[SSJReportFormsViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *reportFormsNavi = [[UINavigationController alloc] initWithRootViewController:reportFormsVC];
    reportFormsNavi.tabBarItem.title = @"报表";
    reportFormsNavi.tabBarItem.image = [UIImage imageNamed:@"tab_form_nor"];
    
    SSJFinancingHomeViewController *financingVC = [[SSJFinancingHomeViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *financingNavi = [[UINavigationController alloc] initWithRootViewController:financingVC];
    financingNavi.tabBarItem.title = @"资金";
    financingNavi.tabBarItem.image = [UIImage imageNamed:@"tab_founds_nor"];
    
    SSJMineHomeViewController *moreVC = [[SSJMineHomeViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
    UINavigationController *moreNavi = [[UINavigationController alloc] initWithRootViewController:moreVC];
    moreNavi.tabBarItem.title = @"更多";
    moreNavi.tabBarItem.image = [UIImage imageNamed:@"tab_more_nor"];
    
    UITabBarController *tabBarVC = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    tabBarVC.tabBar.barTintColor = [UIColor whiteColor];
    tabBarVC.tabBar.tintColor = [UIColor ssj_colorWithHex:@"#47cfbe"];
    tabBarVC.viewControllers = @[bookKeepingNavi, reportFormsNavi, financingNavi, moreNavi];
    [UIApplication sharedApplication].keyWindow.rootViewController = tabBarVC;
}

// 返回记账树图片名称
- (NSString *)treeName {
    NSInteger checkTimes = _checkInModel.checkInTimes;
    if (checkTimes >= 0 && checkTimes <= 7) {
        return @"tree_level_1";
    } else if (checkTimes >= 8 && checkTimes <= 30) {
        return @"tree_level_2";
    } else if (checkTimes >= 31 && checkTimes <= 50) {
        return @"tree_level_3";
    } else if (checkTimes >= 51 && checkTimes <= 100) {
        return @"tree_level_4";
    } else if (checkTimes >= 101 && checkTimes <= 180) {
        return @"tree_level_5";
    } else if (checkTimes >= 181 && checkTimes <= 300) {
        return @"tree_level_6";
    } else if (checkTimes >= 301 && checkTimes <= 450) {
        return @"tree_level_7";
    } else if (checkTimes >= 451 && checkTimes <= 599) {
        return @"tree_level_8";
    } else if (checkTimes >= 600) {
        return @"tree_level_9";
    } else {
        return @"";
    }
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    if (service == _checkInService) {
        // 1：签到成功 2：已经签过到 else：签到失败
        if ([_checkInService.returnCode isEqualToString:@"1"]) {
            
            _checkInModel = _checkInService.checkInModel;
            [SSJBookkeepingTreeStore saveCheckInModel:_checkInService.checkInModel error:nil];
            
        } else if ([_checkInService.returnCode isEqualToString:@"2"]) {
            
            // 如果本地保存的最近一次签到时间和服务端返回的不一致，说明本地没有保存最新的签到记录
            _checkInModel = [SSJBookkeepingTreeStore queryCheckInInfoWithUserId:SSJUSERID() error:nil];
            if (![_checkInModel.lastCheckInDate isEqualToString:_checkInService.checkInModel.lastCheckInDate]) {
                _checkInModel = _checkInService.checkInModel;
                [SSJBookkeepingTreeStore saveCheckInModel:_checkInService.checkInModel error:nil];
            }
            
        } else {
            // 根据本地保存的签到记录，显示记账树等级
            _checkInModel = [SSJBookkeepingTreeStore queryCheckInInfoWithUserId:SSJUSERID() error:nil];
        }
        
        if (_isServerStartViewShowed) {
            [self showTreeView];
        }
    }
}

- (void)server:(SSJBaseNetworkService *)service didFailLoadWithError:(NSError *)error {
    if (service == _checkInService) {
        _checkInModel = [SSJBookkeepingTreeStore queryCheckInInfoWithUserId:SSJUSERID() error:nil];
        if (_isServerStartViewShowed) {
            [self showTreeView];
        }
    }
}

@end
