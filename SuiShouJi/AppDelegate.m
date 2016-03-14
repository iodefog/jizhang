//
//  AppDelegate.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/11.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "AppDelegate.h"
#import "SSJBookKeepingHomeViewController.h"
#import "SSJMineHomeViewController.h"
#import "SSJFinancingHomeViewController.h"
#import "SSJReportFormsViewController.h"
#import "SSJMotionPasswordViewController.h"
#import "SSJGuideView.h"

#import "SSJLocalNotificationHelper.h"
#import "SSJDatabaseQueue.h"
#import "SSJUserDefaultDataCreater.h"
#import "SSJUserTableManager.h"
#import "SSJDataSynchronizer.h"
#import "SSJStartChecker.h"
#import "SSJDatabaseUpgrader.h"
#import "SSJRegularManager.h"

#import "UMSocialWechatHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "UMFeedback.h"
#import "MobClick.h"

//  进入后台超过的时限后进入锁屏
static const NSTimeInterval kLockScreenDelay = 60;

//  友盟key
static NSString *const kUMAppKey = @"566e6f12e0f55ac052003f62";

static NSString *const kEnterBackgroundTimeKey = @"kEnterBackgroundTimeKey";

void SCYSaveEnterBackgroundTime() {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kEnterBackgroundTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSDate *SCYEnterBackgroundTime() {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kEnterBackgroundTimeKey];
}

@implementation AppDelegate

#pragma mark - Lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //如果第一次打开记录当前时间
    if (SSJIsFirstLaunchForCurrentVersion()) {
        [[NSUserDefaults standardUserDefaults]setObject:[NSDate date]forKey:SSJLastPopTimeKey];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:SSJHaveLoginOrRegistKey];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:SSJHaveEnterFundingHomeKey];
        [self setLocalNotification];
    }
    
    //  添加友盟统计
    [self umengTrack];
    
    //  添加友盟分享
    [self umengShare];
    
    //   添加友盟反馈
    [self umengFeedBack];
    
    //  初始化数据库
    [self initializeDatabaseWithFinishHandler:^{
        //  启动时强制同步一次
        [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:NULL failure:NULL];
        
        //  开启定时同步
        [[SSJDataSynchronizer shareInstance] startTimingSync];
    }];
    
    //  设置根控制器
    [self setRootViewController];
    
    //  当前版本第一次启动显示引导页
    if (SSJIsFirstLaunchForCurrentVersion()) {
        SSJGuideView *guideView = [[SSJGuideView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [guideView showWithFinish:^{
            [self showMotionPasswordIfNeeded];
        }];
    } else {
        [self showMotionPasswordIfNeeded];
    }
    
    //  请求启动接口，检测是否有更新、苹果是否正在审核
    [[SSJStartChecker sharedInstance] checkWithSuccess:NULL failure:NULL];

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    //  收到本地通知后，检测通知是否自动补充定期记账和预算的通知，是的话就进行补充，反之忽略
    [SSJRegularManager performRegularTaskWithLocalNotification:notification];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    SCYSaveEnterBackgroundTime();
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //  当程序从后台进入前台，检测是否自动补充定期记账和预算，因为程序在后台不能收到本地通知
    [SSJRegularManager supplementBookkeepingIfNeededForUserId:SSJUSERID() withSuccess:NULL failure:NULL];
    [SSJRegularManager supplementBudgetIfNeededForUserId:SSJUSERID() withSuccess:NULL failure:NULL];
    
    NSDate *backgroundTime = SCYEnterBackgroundTime();
    NSTimeInterval interval = [backgroundTime timeIntervalSinceDate:[NSDate date]];
    interval = ABS(interval);
    if (interval >= kLockScreenDelay) {
        [self showMotionPasswordIfNeeded];
    }
}

#pragma mark - Private
//  设置根控制器
- (void)setRootViewController {
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
    self.window.rootViewController = tabBarVC;
}

//  初始化数据库
- (void)initializeDatabaseWithFinishHandler:(void (^)(void))finishHandler {
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
            
            //  创建默认的资金帐户
            [SSJUserDefaultDataCreater createDefaultFundAccountsWithError:nil];
        } else {
            //  升级数据库
            [SSJDatabaseUpgrader upgradeDatabase];
        }

        //  创建默认的收支类型
        [SSJUserDefaultDataCreater createDefaultBillTypesIfNeededWithError:nil];
        
        finishHandler();
    });
}

//注册通知
-(void)setLocalNotification{
    NSString *baseDateStr = [NSString stringWithFormat:@"%@ 20:00:00",[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]];
    NSDate *baseDate = [NSDate dateWithString:baseDateStr formatString:@"yyyy-MM-dd HH:mm:ss"];
    if ([baseDate isEarlierThan:[NSDate date]]) {
        baseDate = [baseDate dateByAddingDays:1];
    }
    [SSJLocalNotificationHelper cancelLocalNotificationWithKey:SSJChargeReminderNotification];
    [SSJLocalNotificationHelper registerLocalNotificationWithFireDate:baseDate repeatIterval:NSCalendarUnitDay notificationKey:SSJChargeReminderNotification];
}

//  如果手势密码开启，进入手势密码页面
- (void)showMotionPasswordIfNeeded {
    //  如果当前页面已经是手势密码，直接返回
    if ([SSJVisibalController() isKindOfClass:[SSJMotionPasswordViewController class]]) {
        return;
    }
    
    SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"motionPWD", @"motionPWDState"] forUserId:SSJUSERID()];
    if ([userItem.motionPWDState boolValue]) {
        if (userItem.motionPWD.length) {
            SSJMotionPasswordViewController *motionVC = [[SSJMotionPasswordViewController alloc] init];
            motionVC.type = SSJMotionPasswordViewControllerTypeVerification;
            UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:motionVC];
            [self.window.rootViewController presentViewController:naviVC animated:YES completion:NULL];
        } else {
            SSJAlertViewAction *nextAction = [SSJAlertViewAction actionWithTitle:@"下次再说" handler:^(SSJAlertViewAction *action) {
                //  关闭手势密码
                SSJUserItem *userItem = [[SSJUserItem alloc] init];
                userItem.userId = SSJUSERID();
                userItem.motionPWDState = @"0";
                [SSJUserTableManager saveUserItem:userItem];
            }];
            SSJAlertViewAction *sureAction = [SSJAlertViewAction actionWithTitle:@"去设置" handler:^(SSJAlertViewAction *action) {
                SSJMotionPasswordViewController *motionVC = [[SSJMotionPasswordViewController alloc] init];
                motionVC.type = SSJMotionPasswordViewControllerTypeSetting;
                UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:motionVC];
                [self.window.rootViewController presentViewController:naviVC animated:YES completion:NULL];
            }];
            [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"" action:nextAction, sureAction, nil];
        }
    }
}

#pragma mark - 友盟
/* 友盟统计 */
- (void)umengTrack {
    [MobClick setCrashReportEnabled:YES]; // 如果不需要捕捉异常，注释掉此行
#ifdef DEBUG
    //    [MobClick setLogEnabled:YES];
#endif
    [MobClick setAppVersion:SSJAppVersion()]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    //  reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
    //  channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App Store"渠道
    [MobClick startWithAppkey:kUMAppKey reportPolicy:(ReportPolicy)BATCH channelId:SSJDefaultSource()];
}

/* 友盟分享 */
-(void)umengShare{
    [UMSocialData setAppKey:kUMAppKey];
    [UMSocialWechatHandler setWXAppId:@"wxf77f7a5867124dfd" appSecret:@"597d6402c3cd82ff12ba0e81abd34b1a" url:@"http://1.9188.com/h5/jizhangApp/"];
    [UMSocialData defaultData].extConfig.wechatSessionData.title = @"9188记账，一种快速实现财务自由的方式～";
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"";
//    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:@"4058368695"
//                                              
//                                         RedirectURL:SSJAppStoreAddress];
    [UMSocialQQHandler setQQWithAppId:@"1105133385" appKey:@"mgRX8CiiIIrCoyu6" url:@"http://1.9188.com/h5/jizhangApp/"];
    [UMSocialData defaultData].extConfig.qqData.title = @"9188记账，一种快速实现财务自由的方式～";
}

/* 友盟意见反馈 */
-(void)umengFeedBack{
    [UMFeedback setAppkey:kUMAppKey];
}

#pragma mark - qq快登
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [TencentOAuth HandleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [TencentOAuth HandleOpenURL:url];
}
@end
