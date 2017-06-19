//
//  SSJStartChecker.m
//  SuiShouJi
//
//  Created by old lang on 16/2/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJStartChecker.h"
#import "SSJStartNetworkService.h"
#import "SSJStartUpgradeAlertView.h"

static const NSUInteger kMaxLoadUpdateItmes = 0; //  加载更新信息失败的次数限制

@interface SSJStartChecker () <SSJBaseNetworkServiceDelegate>

//  请求成功的回调
@property (nonatomic, copy) void (^success)(BOOL, SSJAppUpdateType);

//  请求失败的回调
@property (nonatomic, copy) void (^failure)(NSString *);

//  网络请求
@property (nonatomic, strong) SSJStartNetworkService *networkService;

//  检查更新失败次数
@property (nonatomic) NSUInteger checkUpdateFailureTimes;

@property (nonatomic) NSTimeInterval timeout;

@end

@implementation SSJStartChecker

+ (instancetype)sharedInstance {
    static SSJStartChecker *checker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!checker) {
            checker = [[SSJStartChecker alloc] init];
        }
    });
    return checker;
}

- (void)checkWithSuccess:(void(^)(BOOL isInReview, SSJAppUpdateType type))success
                 failure:(void(^)(NSString *message))failure {
    [self checkWithTimeoutInterval:60 success:success failure:failure];
}

- (void)checkWithTimeoutInterval:(NSTimeInterval)timeout
                         success:(void(^)(BOOL isInReview, SSJAppUpdateType type))success
                         failure:(void(^)(NSString *message))failure {
    _timeout = timeout;
    self.success = success;
    self.failure = failure;
    [self checkUpdate];
}

- (BOOL)isInReview {
    return self.networkService.isInReview;
}

- (NSString *)remindMassage{
    return self.networkService.remindMassage;
}

- (NSString *)startImageUrl{
    return self.networkService.startImage;
}

- (NSString *)lottieUrl{
    return self.networkService.lottieUrl;
}

- (NSString *)animUrl{
    return self.networkService.animImage;
}

- (NSString *)serviceNum{
    return self.networkService.serviceNumber;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [self gotoUpdate];
    }
}

#pragma mark - SCYBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    if ([self.networkService.returnCode isEqualToString:@"1"]) {
        [self finishCheckUpdate];
        
        [MQManager setScheduledAgentWithAgentId:@"" agentGroupId:self.networkService.mqGroupId scheduleRule:MQScheduleRulesRedirectGroup];
#ifdef DEBUG
        [CDAutoHideMessageHUD showMessage:@"启动接口请求成功"];
        SSJPRINT(@">>> 启动接口请求成功");
#endif
    } else {
        [self loadUpdateInfoAfterFailureIfNeededWithErrorMessage:service.desc];
    }
}

- (void)server:(SSJBaseNetworkService *)service didFailLoadWithError:(NSError *)error {
    NSString *message = service.desc;
    if (message.length == 0) {
        message = SSJMessageWithErrorCode(error);
    }
    [self loadUpdateInfoAfterFailureIfNeededWithErrorMessage:message];
}

#pragma mark - Private
//  请求服务端是否有更新
- (void)checkUpdate {
    if (!self.networkService) {
        self.networkService = [[SSJStartNetworkService alloc] initWithDelegate:self];
        self.networkService.showLodingIndicator = NO;
    }
    self.networkService.timeoutInterval = _timeout;
    [self.networkService request];
#ifdef DEBUG
    [CDAutoHideMessageHUD showMessage:@"启动接口请求开始"];
    SSJPRINT(@">>> 启动接口请求开始");
#endif
}

//  请求失败后继续请求
- (void)loadUpdateInfoAfterFailureIfNeededWithErrorMessage:(NSString *)message {
    if (self.checkUpdateFailureTimes < kMaxLoadUpdateItmes) {
        self.checkUpdateFailureTimes ++;
        [self checkUpdate];
#ifdef DEBUG
        [CDAutoHideMessageHUD showMessage:@"启动接口请求失败，正在重试"];
        SSJPRINT(@">>> 启动接口请求失败，正在重试");
#endif
    } else {
        _isChecked = YES;
        _isCheckedSuccess = NO;
        if (self.failure) {
            NSString *errorMessage = message.length > 0 ? message : SSJ_ERROR_MESSAGE;
            self.failure(errorMessage);
        }
        
        self.success = nil;
        self.failure = nil;
#ifdef DEBUG
        [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"启动接口请求失败,error:%@", message ?: @""]];
#endif
    }
}

//  完成请求
- (void)finishCheckUpdate {
    _isChecked = YES;
    _isCheckedSuccess = YES;
    SSJAppUpdateType updateType = SSJAppUpdateTypeNone;
    if ([self.networkService.type isEqualToString:@"0"]) {
        updateType = SSJAppUpdateTypeUpdate;
    } else if ([self.networkService.type isEqualToString:@"1"]) {
        updateType = SSJAppUpdateTypeForceUpdate;
    }
    
    if (self.success) {
        self.success(NO, updateType);
    }
    
    self.success = nil;
    self.failure = nil;
    
    if ([self isInReview]) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    switch (updateType) {
        case SSJAppUpdateTypeNone:
            break;
            
        case SSJAppUpdateTypeUpdate: {
            SSJStartUpgradeAlertView *alertView = [[SSJStartUpgradeAlertView alloc] initWithTitle:@"我升级啦" message:[[NSAttributedString alloc] initWithString:self.networkService.content attributes:nil] cancelButtonTitle:@"取消" sureButtonTitle:@"去升级" cancelButtonClickHandler:^(SSJStartUpgradeAlertView *alert) {
                [alert dismiss];
            } sureButtonClickHandler:^(SSJStartUpgradeAlertView *alert) {
                [alert dismiss];
                [weakSelf gotoUpdate];
            }];
            [alertView show];
        }   break;
            
        case SSJAppUpdateTypeForceUpdate: {
            SSJStartUpgradeAlertView *alertView = [[SSJStartUpgradeAlertView alloc] initWithTitle:@"我升级啦" message:[[NSAttributedString alloc] initWithString:self.networkService.content attributes:nil] cancelButtonTitle:nil sureButtonTitle:@"去升级" cancelButtonClickHandler:NULL sureButtonClickHandler:^(SSJStartUpgradeAlertView *alert) {
                [weakSelf gotoUpdate];
            }];
            [alertView show];
        }   break;
    }
}

//  前往升级
- (void)gotoUpdate {
    NSURL *updateUrl = [NSURL URLWithString:self.networkService.url];
    
    //  appstore渠道包
    UIWebView *webView = [[UIWebView alloc] init];
    NSURLRequest *request = [NSURLRequest requestWithURL:updateUrl];
    [webView loadRequest:request];
    [SSJVisibalController().view addSubview:webView];
    
//    //  企业渠道包
//    if ([[UIApplication sharedApplication] canOpenURL:updateUrl]) {
//        [[UIApplication sharedApplication] openURL:updateUrl];
//    }
}

@end
