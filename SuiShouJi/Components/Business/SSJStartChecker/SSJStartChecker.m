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

static const NSUInteger kMaxLoadUpdateItmes = 2; //  加载更新信息失败的次数限制

@interface SSJStartChecker () <SSJBaseNetworkServiceDelegate>

//  请求成功的回调
@property (nonatomic, copy) void (^success)(BOOL, SSJAppUpdateType);

//  请求失败的回调
@property (nonatomic, copy) void (^failure)(NSString *);

//  网络请求
@property (nonatomic, strong) SSJStartNetworkService *networkService;

//  检查更新失败次数
@property (nonatomic) NSUInteger checkUpdateFailureTimes;

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

-(NSString *)startImageUrl{
    return self.networkService.startImage;
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
    [self.networkService request];
}

//  请求失败后继续请求
- (void)loadUpdateInfoAfterFailureIfNeededWithErrorMessage:(NSString *)message {
    self.checkUpdateFailureTimes ++;
    if (self.checkUpdateFailureTimes < kMaxLoadUpdateItmes) {
        [self checkUpdate];
    } else {
        if (self.failure) {
            NSString *errorMessage = message.length > 0 ? message : SSJ_ERROR_MESSAGE;
            self.failure(errorMessage);
        }
    }
}

//  完成请求
- (void)finishCheckUpdate {
    SSJAppUpdateType updateType = SSJAppUpdateTypeNone;
    if ([self.networkService.type isEqualToString:@"0"]) {
        updateType = SSJAppUpdateTypeUpdate;
    } else if ([self.networkService.type isEqualToString:@"1"]) {
        updateType = SSJAppUpdateTypeForceUpdate;
    }
    
    if (self.success) {
        if (self.success) {
            self.success(NO, updateType);
        }
    }
    
    if ([self isInReview]) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    switch (updateType) {
        case SSJAppUpdateTypeNone:
            break;
            
        case SSJAppUpdateTypeUpdate: {
            SSJStartUpgradeAlertView *alertView = [[SSJStartUpgradeAlertView alloc] initWithTitle:@"我升级啦" message:self.networkService.content cancelButtonTitle:@"取消" sureButtonTitle:@"去升级" cancelButtonClickHandler:^(SSJStartUpgradeAlertView *alert) {
                [alert dismiss];
            } sureButtonClickHandler:^(SSJStartUpgradeAlertView *alert) {
                [alert dismiss];
                [weakSelf gotoUpdate];
            }];
            [alertView show];
        }   break;
            
        case SSJAppUpdateTypeForceUpdate: {
            SSJStartUpgradeAlertView *alertView = [[SSJStartUpgradeAlertView alloc] initWithTitle:@"我升级啦" message:self.networkService.content cancelButtonTitle:nil sureButtonTitle:@"去升级" cancelButtonClickHandler:NULL sureButtonClickHandler:^(SSJStartUpgradeAlertView *alert) {
                [weakSelf gotoUpdate];
            }];
            [alertView show];
        }   break;
    }
}

//  前往升级
- (void)gotoUpdate {
    NSURL *updateUrl = [NSURL URLWithString:self.networkService.url];
    if (SSJIsAppStoreSource()) {
        //  appstore渠道包
        UIWebView *webView = [[UIWebView alloc] init];
        NSURLRequest *request = [NSURLRequest requestWithURL:updateUrl];
        [webView loadRequest:request];
        [SSJVisibalController().view addSubview:webView];
    } else {
        //  企业渠道包
        if ([[UIApplication sharedApplication] canOpenURL:updateUrl]) {
            [[UIApplication sharedApplication] openURL:updateUrl];
        }
    }
}

@end
