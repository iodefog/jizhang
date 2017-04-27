//
//  AppDelegate.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/11.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "AppDelegate.h"

#import "SSJDatabaseQueue.h"
#import "SSJUserDefaultDataCreater.h"
#import "SSJUserTableManager.h"
#import "SSJDataSynchronizer.h"
#import "SSJDatabaseUpgrader.h"
#import "SSJRegularManager.h"
#import "SSJThirdPartyLoginManger.h"
#import "SSJMotionPasswordViewController.h"

#import "SSJBookKeepingHomeViewController.h"
#import "SSJMineHomeViewController.h"
#import "SSJFinancingHomeViewController.h"
#import "SSJReportFormsViewController.h"
#import "MMDrawerController.h"
#import "SSJFundingDetailsViewController.h"
#import "SSJLoanDetailViewController.h"
#import "SSJBookKeepingHomeEvaluatePopView.h"

#import "SSJGradientMaskView.h"
#import "SSJCreditCardItem.h"

#import "SSJLocalNotificationHelper.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "SSJStartViewManager.h"
#import "SSJStartViewManager.h"
#import <UShareUI/UMSocialUIManager.h>

//#import "SSJPatchUpdateService.h"
//#import "SSJJspatchAnalyze.h"
//#import "SSJJsPatchItem.h"
#import "SSJBooksTypeSelectViewController.h"
//#import "JPEngine.h"
#import "SSJUmengManager.h"
#import "SSJLocalNotificationHelper.h"
#import "SSJLocalNotificationStore.h"
#import "SSJThemeUpdate.h"
#import "SSJDomainManager.h"
#import "SSJLoanHelper.h"
#import "SSJAnaliyticsManager.h"
#import "SSJCustomThemeManager.h"

#import "SSJNetworkReachabilityManager.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

//  进入后台超过的时限后进入锁屏
static const NSTimeInterval kLockScreenDelay = 60;

static NSString *const kEnterBackgroundTimeKey = @"kEnterBackgroundTimeKey";

//微信desc
static NSString *const kWeiXinDescription = @"weixinLogin";

void SCYSaveEnterBackgroundTime() {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kEnterBackgroundTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSDate *SCYEnterBackgroundTime() {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kEnterBackgroundTimeKey];
}

@interface AppDelegate ()

@property (nonatomic, strong) SSJStartViewManager *startViewManager;

@property(nonatomic, strong) SSJGradientMaskView *maskView;

@end

@implementation AppDelegate

#pragma mark - Lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 此方法最好第一个调用
    SSJMigrateLaunchTimesInfo();
    SSJAddLaunchTimesForCurrentVersion();
    
    [SSJNetworkReachabilityManager startMonitoring];

#ifdef DEBUG
//    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"patch1" ofType:@"js"];
//    NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
//    [JPEngine evaluateScript:script];
#endif
    
    [SSJUmengManager umengShare];
    [SSJAnaliyticsManager SSJAnaliytics];
    [SSJGeTuiManager SSJGeTuiManagerWithDelegate:self];
    
    [MQManager setScheduledAgentWithAgentId:@"" agentGroupId:SSJMQDefualtGroupId scheduleRule:MQScheduleRulesRedirectGroup];
    
    [self initializeDatabaseWithFinishHandler:^{
        //  启动时强制同步一次
        if (SSJIsUserLogined()) {
            [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:NULL failure:NULL];
        }
        
        //  开启定时同步
        [[SSJDataSynchronizer shareInstance] startTimingSync];
        
        // 1.7.0之前有每日提醒，此版本后提醒改变了，所以要取消之前所有提醒
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [SSJRegularManager registerRegularTaskNotification];
        [SSJLocalNotificationStore queryForreminderListForUserId:SSJUSERID() WithSuccess:^(NSArray<SSJReminderItem *> *result) {
            for (SSJReminderItem *item in result) {
                [SSJLocalNotificationHelper registerLocalNotificationWithremindItem:item];
            }
        } failure:^(NSError *error) {
            SSJPRINT(@"警告：同步后注册本地通知失败 error:%@", [error localizedDescription]);
        }];
        
        UILocalNotification *notifcation = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
        if (notifcation) {
            SSJDispatchMainAsync(^{
                [self pushToControllerWithNotification:notifcation];
            });
        }
        
    }];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self setRootViewController];
    
    [SSJThemeSetting updateTabbarAppearance];
    
    //如果第一次打开记录当前时间
    if (SSJLaunchTimesForCurrentVersion() == 1) {
        [[NSUserDefaults standardUserDefaults]setObject:[NSDate date]forKey:SSJLastPopTimeKey];
//        [SSJJspatchAnalyze removePatch];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SSJThemeUpdate updateLocalThemesIfneeded];
        });
        
    }
    
    NSInteger appversion = [[SSJAppVersion() stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
    
    if (SSJLaunchTimesForCurrentVersion() == 1 && appversion >= 240) {
        [SSJCustomThemeManager initializeCustomTheme];
    }
    
    //每次启动打一次补丁
//    [SSJJspatchAnalyze SSJJsPatchAnalyzePatch];
    
    //微信登录
    [WXApi registerApp:SSJDetailSettingForSource(@"WeiXinKey")];
    
    _startViewManager = [[SSJStartViewManager alloc] init];
    [_startViewManager showWithCompletion:^(SSJStartViewManager *manager){
        [SSJMotionPasswordViewController verifyMotionPasswordIfNeeded:^(BOOL isVerified){
            // 没有进入手势密码，直接进入首页的话，就调用reloadWithAnimation显示首页数据加载动画;
            // 因为从手势密码返回到首页会触发首页的viewWillAppear，在这个方法中也做了数据刷新，会把加载动画覆盖掉
            UITabBarController *tabVC = (UITabBarController *)((MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController).centerViewController;
            UINavigationController *navi = [tabVC.viewControllers firstObject];
            SSJBookKeepingHomeViewController *homeVC = [navi.viewControllers firstObject];
            if (![homeVC isKindOfClass:[SSJBookKeepingHomeViewController class]]) {
                return;
            }
            if (isVerified) {
                homeVC.allowRefresh = YES;
                homeVC.hasLoad = NO;
            } else {
                [homeVC reloadWithAnimation];
            }
        } animated:NO];
        manager = nil;
    }];
    
    [SSJDomainManager requestDomain];
    
    // 美恰sdk设置
    [MQManager initWithAppkey:SSJMQAppKey completion:^(NSString *clientId, NSError *error) {
        
    }];
    
    //保存app启动时间，判断是否为新用户
    [SSJBookKeepingHomeEvaluatePopView evaluatePopViewConfiguration];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [GeTuiSdk setBadge:0];
    //每次从后台进入打一次补丁
//    [SSJJspatchAnalyze SSJJsPatchAnalyzePatch];
    
    // 当程序从后台进入前台，检测是否自动补充定期记账和预算，因为程序在后台不能收到本地通知
    [SSJRegularManager supplementCycleRecordsForUserId:SSJUSERID() success:NULL failure:NULL];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    [self pushToControllerWithNotification:notification];
    
    //  收到本地通知后，检测通知是否自动补充定期记账和预算的通知，是的话就进行补充，反之忽略
    [SSJRegularManager performRegularTaskWithLocalNotification:notification];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //App 进入后台时，关闭美洽服务
    [MQManager closeMeiqiaService];
    SCYSaveEnterBackgroundTime();
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

    NSDate *backgroundTime = SCYEnterBackgroundTime();
    NSTimeInterval interval = [backgroundTime timeIntervalSinceDate:[NSDate date]];
    interval = ABS(interval);
    if (interval >= kLockScreenDelay) {
        [SSJMotionPasswordViewController verifyMotionPasswordIfNeeded:NULL animated:NO];
    }
    // App 进入前台时，开启美洽服务
    [MQManager openMeiqiaService];
}

//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
//    [MQManager registerDeviceToken:deviceToken];
//}

#pragma mark - Getter
- (SSJGradientMaskView *)maskView{
    if (!_maskView) {
        _maskView = [[SSJGradientMaskView alloc]initWithFrame:CGRectMake(0, 0, SSJSCREENWITH, SSJSCREENHEIGHT)];
    }
    return _maskView;
}

#pragma mark - Private
//  初始化数据库
- (void)initializeDatabaseWithFinishHandler:(void (^)(void))finishHandler {
    [[NSNotificationCenter defaultCenter] postNotificationName:SSJInitDatabaseDidBeginNotification object:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *dbDocumentPath = SSJSQLitePath();
        SSJPRINT(@"%@", dbDocumentPath);
        
        NSError *error = nil;
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:dbDocumentPath]) {
            //  迁移数据库到document中
            NSString *dbBundlePath = [[NSBundle mainBundle] pathForResource:@"mydatabase" ofType:@"db"];
            
            if (![[NSFileManager defaultManager] copyItemAtPath:dbBundlePath toPath:dbDocumentPath error:&error]) {
                SSJPRINT(@"move database error:%@",[error localizedDescription]);
            }
            
            //  载入用户id
            [SSJUserTableManager reloadUserIdWithError:nil];
            
            //  创建默认的同步表记录
            [SSJUserDefaultDataCreater createDefaultSyncRecordWithError:nil];
            
            //  创建默认的资金账户
            [SSJUserDefaultDataCreater createDefaultFundAccountsWithError:nil];

        } else {
            //  升级数据库
            [SSJDatabaseUpgrader upgradeDatabase];
        }

        //  创建默认的收支类型
        [SSJUserDefaultDataCreater createDefaultBillTypesIfNeededWithError:nil];
        
        //  创建默认的账本
        [SSJUserDefaultDataCreater createDefaultBooksTypeWithError:nil];
        
        //  创建默认的成员
        [SSJUserDefaultDataCreater createDefaultMembersWithError:nil];
        
        SSJDispatchMainSync(^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SSJInitDatabaseDidFinishNotification object:nil];
        });
        
        if (finishHandler) {
            finishHandler();
        }
    });
}


// 设置根控制器
- (void)setRootViewController {
    SSJBookKeepingHomeViewController *bookKeepingVC = [[SSJBookKeepingHomeViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *bookKeepingNavi = [[UINavigationController alloc] initWithRootViewController:bookKeepingVC];
    bookKeepingNavi.tabBarItem.title = @"记账";
    
    SSJReportFormsViewController *reportFormsVC = [[SSJReportFormsViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *reportFormsNavi = [[UINavigationController alloc] initWithRootViewController:reportFormsVC];
    reportFormsNavi.tabBarItem.title = @"报表";
    
    SSJFinancingHomeViewController *financingVC = [[SSJFinancingHomeViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *financingNavi = [[UINavigationController alloc] initWithRootViewController:financingVC];
    financingNavi.tabBarItem.title = @"资金";
    
    SSJMineHomeViewController *moreVC = [[SSJMineHomeViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *moreNavi = [[UINavigationController alloc] initWithRootViewController:moreVC];
    moreNavi.tabBarItem.title = @"更多";
    
    UITabBarController *tabBarVC = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    tabBarVC.viewControllers = @[bookKeepingNavi, reportFormsNavi, financingNavi, moreNavi];
    
    SSJBooksTypeSelectViewController *booksTypeVC = [[SSJBooksTypeSelectViewController alloc]init];
    UINavigationController *booksNav = [[UINavigationController alloc] initWithRootViewController:booksTypeVC];

    MMDrawerController *drawerController = [[MMDrawerController alloc]
                             initWithCenterViewController:tabBarVC
                             leftDrawerViewController:booksNav
                             rightDrawerViewController:nil];
    [drawerController setShowsShadow:NO];
    [drawerController setMaximumLeftDrawerWidth:SSJSCREENWITH * 0.8];
    [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    drawerController.view.backgroundColor = [UIColor whiteColor];
    

//    drawerController.showsShadow = YES;
    [drawerController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
        self.maskView.currentAplha = percentVisible;
        if (percentVisible > 0.f) {
            [drawerController.centerViewController.view addSubview:self.maskView];
        }else{
            [self.maskView removeFromSuperview];
        }
    }];
    
    [UIApplication sharedApplication].keyWindow.rootViewController = drawerController;
}
    
#pragma mark - qq快登
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    return [TencentOAuth HandleOpenURL:url] ||
    [WXApi handleOpenURL:url delegate:[SSJThirdPartyLoginManger shareInstance].weixinLogin];
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [TencentOAuth HandleOpenURL:url] ||
    [WXApi handleOpenURL:url delegate:[SSJThirdPartyLoginManger shareInstance].weixinLogin];
}

#pragma mark - 根据推送的内容跳转不同的页面
- (void)pushToControllerWithNotification:(UILocalNotification *)notification{
    if ([notification.userInfo[@"key"] isEqualToString:SSJReminderNotificationKey]) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:notification.alertBody action:[SSJAlertViewAction actionWithTitle:@"知道了" handler:NULL],nil];
        }else{
            UIViewController *currentVc = SSJVisibalController();
            NSDictionary *userinfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
            SSJReminderItem *remindItem = [SSJReminderItem mj_objectWithKeyValues:[userinfo objectForKey:@"remindItem"]];
            if (remindItem.remindType == SSJReminderTypeCreditCard) {
                SSJCreditCardItem *cardItem = [[SSJCreditCardItem alloc]init];
                if (!remindItem.fundId.length) {
                    remindItem.fundId = [self getCreditCardIdForRemindId:remindItem.remindId];
                }
                cardItem.cardId = remindItem.fundId;
                SSJFundingDetailsViewController *creditCardVc = [[SSJFundingDetailsViewController alloc]init];
                creditCardVc.item = cardItem;
                [currentVc.navigationController pushViewController:creditCardVc animated:YES];
            }else if(remindItem.remindType == SSJReminderTypeBorrowing){
                SSJLoanDetailViewController *loanVc = [[SSJLoanDetailViewController alloc]init];
                if (!remindItem.fundId.length) {
                    remindItem.fundId = [self getLoanIdForRemindId:remindItem.remindId];
                }
                loanVc.loanID = remindItem.fundId;
                loanVc.fundColor = [SSJLoanHelper queryForFundColorWithLoanId:remindItem.fundId];
                [currentVc.navigationController pushViewController:loanVc animated:YES];
            }
        }
    }

}


#pragma mark - 获取当前推送的账户id
- (NSString *)getCreditCardIdForRemindId:(NSString *)remindID{
    __block NSString *cardId;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        cardId = [db stringForQuery:@"select cfundid from bk_user_credit where cremindid = ? and cuserid = ?",remindID,SSJUSERID()];
    }];
    return cardId;
}

- (NSString *)getLoanIdForRemindId:(NSString *)remindID{
    __block NSString *loanId;
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        loanId = [db stringForQuery:@"select loanid from bk_loan where cremindid = ? and cuserid = ?",remindID,SSJUSERID()];
    }];
    return loanId;
}

#pragma mark - 远程通知有关的
/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // [ GTSdk ]：向个推服务器注册deviceToken
    [GeTuiSdk registerDeviceToken:token];
}

/** 远程通知注册失败委托 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    SSJPRINT(@"\n>>>[DeviceToken Error]:%@\n\n", error.description);
}

#pragma mark - APP运行中接收到通知(推送)处理 - iOS 10以下版本收到推送

/** APP已经接收到“远程”通知(推送) - 透传推送消息  */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        return;
    }
    
    // [ GTSdk ]：将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:userInfo];
    
    // 控制台打印接收APNs信息
    SSJPRINT(@"\n>>>[Receive RemoteNotification]:%@\n\n", userInfo);
    
    completionHandler(UIBackgroundFetchResultNewData);
    
    [SSJGeTuiManager pushToViewControllerWithUserInfo:userInfo];
    
}

//- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
//    
//}

#pragma mark - iOS 10中收到推送消息

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
//  iOS 10: App在前台获取到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    SSJPRINT(@"willPresentNotification：%@", notification.request.content.userInfo);
    
    // 根据APP需要，判断是否要提示用户Badge、Sound、Alert
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

//  iOS 10: 点击通知进入App时触发
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    SSJPRINT(@"didReceiveNotification：%@", response.notification.request.content.userInfo);
    
    // [ GTSdk ]：将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:response.notification.request.content.userInfo];
    
    completionHandler();
}
#endif

@end
