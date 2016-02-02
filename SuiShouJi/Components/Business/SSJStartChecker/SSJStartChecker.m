//
//  SSJStartChecker.m
//  SuiShouJi
//
//  Created by old lang on 16/2/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJStartChecker.h"
#import "SSJStartNetworkService.h"

static const NSUInteger kMaxLoadUpdateItmes = 2; //  加载更新信息失败的次数限制

@interface SSJStartChecker () <SSJBaseNetworkServiceDelegate>

//  请求成功的回调
@property (nonatomic, copy) void (^success)(BOOL, SSJAppUpdateType);

//  请求失败的回调
@property (nonatomic, copy) void (^failure)(NSString *);

//  是否正在审核
@property (nonatomic) BOOL isInReview;

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
    
    switch (updateType) {
        case SSJAppUpdateTypeNone:
            [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:@"已是最新版本" action:[SSJAlertViewAction actionWithTitle:@"确认" handler:NULL], nil];
            break;
            
        case SSJAppUpdateTypeUpdate:
            [self showAlertWithSureTitle:@"确定" cancelTitle:@"取消"];
            break;
            
        case SSJAppUpdateTypeForceUpdate:
            [self showAlertWithSureTitle:@"确定" cancelTitle:nil];
            break;
    }
    
//    if (!self.isInReview) {
//        switch (updateType) {
//            case SSJAppUpdateTypeNone:
//                [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:@"已是最新版本" action:[SSJAlertViewAction actionWithTitle:@"确认" handler:NULL], nil];
//                break;
//                
//            case SSJAppUpdateTypeUpdate:
//                [self showAlertWithSureTitle:@"确定" cancelTitle:@"取消"];
//                break;
//                
//            case SSJAppUpdateTypeForceUpdate:
//                [self showAlertWithSureTitle:@"确定" cancelTitle:nil];
//                break;
//        }
//    }
}

//  显示提示框提示更新
- (void)showAlertWithSureTitle:(NSString *)sureTitle cancelTitle:(NSString *)cancelTitle {
    if (SSJSystemVersion() >= 8.0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"版本更新" message:self.networkService.content preferredStyle:UIAlertControllerStyleAlert];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineSpacing = 2.0;
        
        NSDictionary * attributes = @{NSParagraphStyleAttributeName:paragraphStyle,
                                      NSFontAttributeName:[UIFont systemFontOfSize:13.0]};
        
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:self.networkService.content];
        [attributedTitle addAttributes:attributes range:NSMakeRange(0, self.networkService.content.length)];
        [alertController setValue:attributedTitle forKey:@"attributedMessage"];
        
        if (cancelTitle) {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:nil];
            [alertController addAction:cancelAction];
        }
        
        if (sureTitle) {
            __weak typeof(self) block_self = self;
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:sureTitle
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
                                                                   [block_self gotoUpdate];
                                                               }];
            [alertController addAction:sureAction];
        }
        [SSJVisibalController() presentViewController:alertController animated:YES completion:nil];
        
    } else {
        UIAlertView *aler = [[UIAlertView alloc] initWithTitle:@"版本更新" message:self.networkService.content delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:sureTitle, nil];
        [aler show];
    }
}

//  前往appstore升级
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
