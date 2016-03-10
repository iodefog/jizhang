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
#import "SSJDatabaseQueue.h"
#import "SSJLocalNotificationHelper.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaSSOHandler.h"

#import <TencentOpenAPI/TencentOAuth.h>
#import "UMFeedback.h"

#import "SSJUserDefaultDataCreater.h"
#import "MobClick.h"
#import "FMDB.h"
#import "SSJUserTableManager.h"
#import "SSJDataSynchronizer.h"
#import "SSJGuideView.h"
#import "SSJStartChecker.h"
#import "SSJDatabaseUpgrader.h"

@implementation AppDelegate

//  友盟key
static NSString *const kUMAppKey = @"566e6f12e0f55ac052003f62";

//- (void)applicationWillEnterForeground:(UIApplication *)application {
//    
//}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
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
    SSJGuideView *guideView = [[SSJGuideView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [guideView showIfNeeded];
    
    //  请求启动接口，检测是否有更新、苹果是否正在审核
    [[SSJStartChecker sharedInstance] checkWithSuccess:NULL failure:NULL];
    

    
    return YES;
}

- (void)registerRegularTask {
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeNone categories:nil]];
    }
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    NSDate *date = [NSDate date];
    notification.fireDate = [NSDate dateWithYear:[date year] month:[date month] day:[date day]];
    notification.repeatInterval = NSCalendarUnitDay;
    notification.repeatCalendar = [NSCalendar currentCalendar];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
}

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
    moreNavi.tabBarItem.image = [UIImage imageNamed:@"tab_mine_nor"];
    
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
    [UMSocialWechatHandler setWXAppId:@"wxf77f7a5867124dfd" appSecret:@"597d6402c3cd82ff12ba0e81abd34b1a" url:SSJAppStoreAddress];
//    [UMSocialData defaultData].extConfig.wechatSessionData.title = @"9188记账——省钱必备，剁掉买买买～";
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"";
//    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:@"4058368695"
//                                              
//                                         RedirectURL:SSJAppStoreAddress];
    [UMSocialQQHandler setQQWithAppId:@"1105133385" appKey:@"mgRX8CiiIIrCoyu6" url:SSJAppStoreAddress];
    [UMSocialData defaultData].extConfig.qqData.title = @"9188记账——省钱必备，剁掉买买买～";
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
