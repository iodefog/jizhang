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
#import "SSJStartChecker.h"
#import "SSJBookkeepingTreeCheckInModel.h"
#import "SSJBookkeepingTreeCheckInService.h"
#import "SSJBookkeepingTreeStore.h"
#import "SSJDatabaseQueue.h"
#import "SSJBookkeepingTreeHelper.h"

// 请求启动接口超时时间
static const NSTimeInterval kLoadStartAPITimeout = 1;

// 请求签到接口超时时间
static const NSTimeInterval kLoadCheckInAPITimeout = 60;

// 加载服务器下发启动页超时时间
static const NSTimeInterval kLoadStartImgTimeout = 2;

// 加载记账树图片超时时间
static const NSTimeInterval kLoadTreeImgTimeout = 60;

// 启动页、记账树图片、引导页之间过渡时间
static const NSTimeInterval kTransitionDuration = 0.3;

@interface SSJStartViewManager () <SSJBaseNetworkServiceDelegate>

@property (nonatomic, strong) SSJServerLaunchView *launchView;

//@property (nonatomic, strong) SSJBookkeepingTreeView *treeView;

@property (nonatomic, strong) SSJGuideView *guideView;

@property (nonatomic, strong) SSJBookkeepingTreeCheckInService *checkInService;

@property (nonatomic, strong) SSJBookkeepingTreeCheckInModel *checkInModel;

@property (nonatomic, strong) void (^completion)(SSJStartViewManager *);

//@property (nonatomic) BOOL shouldRequestCheckIn;

@end

@implementation SSJStartViewManager

- (void)dealloc {
    
}

- (void)showWithCompletion:(void(^)(SSJStartViewManager *))completion {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    _completion = completion;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    _launchView = [[SSJServerLaunchView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [window addSubview:_launchView];
    
    [self requestStartAPI];
    
    __block BOOL hasUserTreeTable;
    // 如果没有本地签到表（升级新版本，数据库还没升级完成的情况下），不能请求签到接口
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        hasUserTreeTable = [db tableExists:@"bk_user_tree"];
    }];
    
    // 如果没有userid，就不调用签到接口，签到接口需要userid（第一次启动初始化数据库未完成前，userid为空）
    if (hasUserTreeTable && SSJUSERID().length) {
        [self requestCheckIn];
    }
}

// 请求启动接口，检测是否有更新、苹果是否正在审核、加载下发启动页
- (void)requestStartAPI {
    __weak typeof(self) wself = self;
    [[SSJStartChecker sharedInstance] checkWithTimeoutInterval:kLoadStartAPITimeout success:^(BOOL isInReview, SSJAppUpdateType type) {
        NSString *startImgUrl = [SSJStartChecker sharedInstance].startImageUrl;
        [wself.launchView downloadImgWithUrl:startImgUrl timeout:kLoadStartImgTimeout completion:^{
            [wself showGuideViewIfNeeded];
        }];
    } failure:^(NSString *message) {
        [wself showGuideViewIfNeeded];
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

- (void)serverDidFinished:(SSJBaseNetworkService *)service {
#ifdef DEBUG
    [CDAutoHideMessageHUD showMessage:@"签到接口请求成功"];
#endif
    
    // 1：签到成功 2：已经签过到 else：签到失败
    if ([_checkInService.returnCode isEqualToString:@"1"]) {
        
        _checkInModel = _checkInService.checkInModel;
        [SSJBookkeepingTreeStore saveCheckInModel:_checkInModel error:nil];
        [self loadTreeViewIfNeeded];
        
    } else if ([_checkInService.returnCode isEqualToString:@"2"]) {
        
        // 如果本地保存的最近一次签到时间和服务端返回的不一致，说明本地没有保存最新的签到记录
        _checkInModel = [SSJBookkeepingTreeStore queryCheckInInfoWithUserId:SSJUSERID() error:nil];
        if (![_checkInModel.lastCheckInDate isEqualToString:_checkInService.checkInModel.lastCheckInDate]) {
            _checkInModel = _checkInService.checkInModel;
            [SSJBookkeepingTreeStore saveCheckInModel:_checkInService.checkInModel error:nil];
            [self loadTreeViewIfNeeded];
        }
        
    }
}

- (void)server:(SSJBaseNetworkService *)service didFailLoadWithError:(NSError *)error {
#ifdef DEBUG
    [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"签到接口请求失败,error:%@", [error localizedDescription]]];
#endif
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
- (void)showGuideViewIfNeeded {
//    UIView *currentView = _treeView ?: _launchView;
    UIView *currentView = _launchView;
    if (SSJIsFirstLaunchForCurrentVersion()) {
        if (!_guideView) {
            _guideView = [[SSJGuideView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            _guideView.beginHandle = ^(SSJGuideView *guideView) {
                [guideView dismiss:YES];
            };
        }
        [UIView transitionFromView:currentView toView:_guideView duration:kTransitionDuration options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
            if (_completion) {
                _completion(self);
                _completion = nil;
            }
        }];
    } else {
        [UIView animateWithDuration:0.5f animations:^(void){
            currentView.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
            currentView.alpha = 0;
        } completion:^(BOOL finished){
            [currentView removeFromSuperview];
            if (_completion) {
                _completion(self);
                _completion = nil;
            }
        }];
    }
}

@end
