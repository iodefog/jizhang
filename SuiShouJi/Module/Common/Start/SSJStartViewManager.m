//
//  SSJStartViewManager.m
//  SuiShouJi
//
//  Created by old lang on 16/4/15.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJStartViewManager.h"
#import "SSJServerLaunchView.h"
#import "SSJBookkeepingTreeView.h"
#import "SSJGuideView.h"
#import "SSJUserSignLaunchView.h"

#import "SSJStartChecker.h"
#import "SSJBookkeepingTreeCheckInModel.h"
#import "SSJStartLunchItem.h"

#import "SSJBookkeepingTreeCheckInService.h"
#import "SSJUserSignNetworkService.h"

#import "SSJBookkeepingTreeStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJBookkeepingTreeHelper.h"
#import "SSJUserTableManager.h"

// 请求启动接口超时时间
static const NSTimeInterval kLoadStartAPITimeout = 1;

// 请求签到接口超时时间
static const NSTimeInterval kLoadCheckInAPITimeout = 60;

// 加载服务器下发启动页超时时间
static const NSTimeInterval kLoadStartImgTimeout = 1;

// 加载记账树图片超时时间
static const NSTimeInterval kLoadTreeImgTimeout = 60;

// 启动页、记账树图片、引导页之间过渡时间
static const NSTimeInterval kTransitionDuration = 0.3;

@interface SSJStartViewManager () <SSJBaseNetworkServiceDelegate>

@property (nonatomic, strong) SSJServerLaunchView *launchView;

//@property (nonatomic, strong) SSJBookkeepingTreeView *treeView;

@property (nonatomic, strong) SSJGuideView *guideView;

@property (nonatomic, strong) SSJBookkeepingTreeCheckInService *checkInService;

/**启动页*/
@property (nonatomic, strong) SSJUserSignNetworkService *startLunchService;

@property (nonatomic, strong) SSJBookkeepingTreeCheckInModel *checkInModel;

/**启动模型*/
@property (nonatomic, strong) SSJStartLunchItem *startLunchItem;

@property (nonatomic, strong) void (^completion)(SSJStartViewManager *);

//@property (nonatomic) BOOL shouldRequestCheckIn;

/**<#注释#>*/
@property (nonatomic, strong) SSJUserSignLaunchView *userSignLaunchView;

@end

@implementation SSJStartViewManager

- (void)dealloc {
}

- (void)showWithCompletion:(void(^)(SSJStartViewManager *))completion {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    _completion = completion;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.launchView];
    
    [self requestStartAPI];
    [self.startLunchService requestUserSign];
    
    // 如果没有本地签到表（升级新版本，数据库还没升级完成的情况下），不能请求签到接口
    // 如果没有userid，就不调用签到接口，签到接口需要userid（第一次启动初始化数据库未完成前，userid为空）
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        if ([db tableExists:@"bk_user_tree"] && SSJUSERID().length) {
            [self requestCheckIn];
        }
    }];
}

// 请求启动接口，检测是否有更新、苹果是否正在审核、
//加载下发启动页新版本删除
- (void)requestStartAPI {
    __weak typeof(self) wself = self;
    [[SSJStartChecker sharedInstance] checkWithTimeoutInterval:kLoadStartAPITimeout success:^(BOOL isInReview, SSJAppUpdateType type) {
//        NSString *startImgUrl = [SSJStartChecker sharedInstance].startImageUrl;
//        if (!startImgUrl) {
//            [wself showGuideViewIfNeeded];
//            return;
//        }
//        
//        [wself.launchView downloadImgWithUrl:startImgUrl timeout:kLoadStartImgTimeout completion:^{
//            [wself showGuideViewIfNeededWithFirstView:self.launchView];
//        }];
        
    } failure:^(NSString *message) {
//        [wself showGuideViewIfNeeded];
    }];
}

// 请求签到接口
- (void)requestCheckIn {
    if (!_checkInService) {
        _checkInService = [[SSJBookkeepingTreeCheckInService alloc] initWithDelegate:self];
        _checkInService.showLodingIndicator = NO;
        _checkInService.timeoutInterval = kLoadCheckInAPITimeout;
    }
    [_checkInService checkIn];
#ifdef DEBUG
    [CDAutoHideMessageHUD showMessage:@"请求签到接口"];
#endif
}

#pragma mark - SSJBaseNetworkServiceDelegate

- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    if (service == self.checkInService) {
#ifdef DEBUG
        [CDAutoHideMessageHUD showMessage:@"签到接口请求成功"];
#endif
        
        // 1：签到成功 2：已经签过到 else：签到失败
        if ([_checkInService.returnCode isEqualToString:@"1"]) {
            
            _checkInModel = _checkInService.checkInModel;
            [SSJBookkeepingTreeStore saveCheckInModel:_checkInModel success:NULL failure:NULL];
            [self loadTreeViewIfNeeded];
            
        } else if ([_checkInService.returnCode isEqualToString:@"2"]) {
            
            // 如果本地保存的最近一次签到时间和服务端返回的不一致，说明本地没有保存最新的签到记录
            [SSJBookkeepingTreeStore queryCheckInInfoWithUserId:SSJUSERID() success:^(SSJBookkeepingTreeCheckInModel * _Nonnull model) {
                _checkInModel = model;
                if (![_checkInModel.lastCheckInDate isEqualToString:_checkInService.checkInModel.lastCheckInDate]) {
                    _checkInModel = _checkInService.checkInModel;
                    [SSJBookkeepingTreeStore saveCheckInModel:_checkInModel success:NULL failure:NULL];
                    [self loadTreeViewIfNeeded];
                }
            } failure:^(NSError * _Nonnull error) {
                [SSJAlertViewAdapter showError:error];
            }];
        }
    } else if (service == self.startLunchService) {
        if (SSJLaunchTimesForCurrentVersion() == 1) {
            [self showGuideViewIfNeededWithFirstView:self.launchView];
            return;
        };
        if (![self.startLunchService.returnCode isEqualToString:@"1"]) return;
        self.startLunchItem = self.startLunchService.statrLunchItem;
        if (!self.startLunchItem) return;
        
        __weak typeof(self) wself = self;
        if ([self.startLunchItem.open isEqualToString:@"0"]) {//是否下发 0 调用本地图片 1 使用下发type判断
        //本地图片
            [self showGuideViewIfNeededWithFirstView:self.launchView];
            return;
        }
        
        if (self.startLunchItem.type == 0) {//0:静态图片,1:动态图片,2:图文
            [self.launchView downloadImgWithUrl:self.startLunchItem.startImageUrl timeout:kLoadStartImgTimeout completion:^{
                [self showGuideViewIfNeededWithFirstView:self.launchView];
            }];
        } else if (self.startLunchItem.type == 2) {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            if (self.launchView.superview) {
                [self.launchView removeFromSuperview];
            }
            [window addSubview:self.userSignLaunchView];
            
            [self.userSignLaunchView showWith:self.startLunchItem timeout:kLoadStartImgTimeout completion:^{
                [self showGuideViewIfNeededWithFirstView:self.userSignLaunchView];
            }];
            
        }
    }
}

- (void)server:(SSJBaseNetworkService *)service didFailLoadWithError:(NSError *)error {
#ifdef DEBUG
    [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"签到接口请求失败,error:%@", [error localizedDescription]]];
#endif
    if (service == self.startLunchService) {
        [self showGuideViewIfNeededWithFirstView:_launchView];
    }
}

- (void)loadTreeViewIfNeeded {
    // 签到接口没有请求完成，直接返回
    if (!_checkInService.isLoaded) {
        return;
    }
    
    if (_checkInModel) {
        // 加载记账树启动图
        [SSJBookkeepingTreeHelper loadTreeImageWithUrlPath:_checkInModel.treeImgUrl timeout:kLoadTreeImgTimeout finish:NULL];
        // 加载记账树gif图片
        [SSJBookkeepingTreeHelper loadTreeGifImageDataWithUrlPath:_checkInModel.treeGifUrl finish:NULL];
    }
}

// 当前版本第一次启动显示引导页
- (void)showGuideViewIfNeededWithFirstView:(UIView *)view {
    __block UIView *firstView = view;
    if (SSJLaunchTimesForCurrentVersion() == 1) {
        if (!_guideView) {
            __weak typeof(self) wself = self;
            _guideView = [[SSJGuideView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            _guideView.beginHandle = ^(SSJGuideView *guideView) {
                [guideView dismiss:YES];
                if (wself.completion) {
                    wself.completion(wself);
                    wself.completion = nil;
                }
            };
        }
        
        [UIView transitionFromView:firstView toView:_guideView duration:kTransitionDuration options:UIViewAnimationOptionTransitionCrossDissolve completion:NULL];
        
        firstView = nil;
        
    } else {
        [UIView animateWithDuration:0.5f animations:^(void){
            firstView.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
            firstView.alpha = 0;
        } completion:^(BOOL finished){
            [firstView removeFromSuperview];
            firstView = nil;
        }];
//
        if (_completion) {
            _completion(self);
            _completion = nil;
        }
    }
}


#pragma mark -Lazy
- (SSJUserSignNetworkService *)startLunchService {
    if (!_startLunchService) {
        _startLunchService = [[SSJUserSignNetworkService alloc] initWithDelegate:self];
        _startLunchService.timeoutInterval = 1;
    }
    return _startLunchService;
}


- (SSJUserSignLaunchView *)userSignLaunchView {
    if (!_userSignLaunchView) {
        _userSignLaunchView = [[SSJUserSignLaunchView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        MJWeakSelf;
        _userSignLaunchView.skipBtnBlock = ^(UIButton *btn) {
            [weakSelf showGuideViewIfNeededWithFirstView:weakSelf.userSignLaunchView];
        };
    }
    return _userSignLaunchView;
}

- (SSJServerLaunchView *)launchView {
    if (!_launchView) {
        _launchView = [[SSJServerLaunchView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _launchView;
}

@end
