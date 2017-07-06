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
    
    // 如果没有本地签到表（升级新版本，数据库还没升级完成的情况下），不能请求签到接口
    // 如果没有userid，就不调用签到接口，签到接口需要userid（第一次启动初始化数据库未完成前，userid为空）
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        if ([db tableExists:@"bk_user_tree"] && SSJUSERID().length) {
            [self requestCheckIn];
        }
    }];
}

// 请求启动接口，检测是否有更新、苹果是否正在审核、加载下发启动页
- (void)requestStartAPI {
    __weak typeof(self) wself = self;
    [[SSJStartChecker sharedInstance] checkWithTimeoutInterval:kLoadStartAPITimeout success:^(BOOL isInReview, SSJAppUpdateType type) {
        NSString *startImgUrl = [SSJStartChecker sharedInstance].startImageUrl;
        if (!startImgUrl) {
            [wself showGuideViewIfNeeded];
            return;
        }
        
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
        
        [UIView transitionFromView:_launchView toView:_guideView duration:kTransitionDuration options:UIViewAnimationOptionTransitionCrossDissolve completion:NULL];
        
        _launchView = nil;
        
    } else {
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [_launchView removeFromSuperview];
//            _launchView = nil;
//        });
        
        [UIView animateWithDuration:0.5f animations:^(void){
            _launchView.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
            _launchView.alpha = 0;
        } completion:^(BOOL finished){
            [_launchView removeFromSuperview];
            _launchView = nil;
        }];
//
        if (_completion) {
            _completion(self);
            _completion = nil;
        }
    }
}

@end
