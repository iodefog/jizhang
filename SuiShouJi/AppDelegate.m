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
#import "SSJStartView.h"

#import "SSJDatabaseQueue.h"
#import "SSJUserDefaultDataCreater.h"
#import "SSJUserTableManager.h"
#import "SSJDataSynchronizer.h"
#import "SSJStartChecker.h"
#import "SSJDatabaseUpgrader.h"
#import "SSJRegularManager.h"

#import "SSJLocalNotificationHelper.h"

#import <TencentOpenAPI/TencentOAuth.h>

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
    
//    NSDate *beginDate = [NSDate date];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self setRootViewController];
    
    //  请求启动接口
    [self requestStartAPI];
    
    [self initializeDatabaseWithFinishHandler:^{
        //  启动时强制同步一次
        [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:NULL failure:NULL];
        //  开启定时同步
        [[SSJDataSynchronizer shareInstance] startTimingSync];
    }];
    
    //如果第一次打开记录当前时间
    if (SSJIsFirstLaunchForCurrentVersion()) {
        [[NSUserDefaults standardUserDefaults]setObject:[NSDate date]forKey:SSJLastPopTimeKey];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:SSJHaveLoginOrRegistKey];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:SSJHaveEnterFundingHomeKey];
    }
    
    if (SSJIsFirstLaunchForCurrentVersion()) {
        NSString *baseDateStr = [NSString stringWithFormat:@"%@ 20:00:00",[[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd"]];
        NSDate *baseDate = [NSDate dateWithString:baseDateStr formatString:@"yyyy-MM-dd HH:mm:ss"];
        if ([baseDate isEarlierThan:[NSDate date]]) {
            baseDate = [baseDate dateByAddingDays:1];
        }
        [SSJLocalNotificationHelper cancelLocalNotificationWithKey:SSJChargeReminderNotification];
        [SSJLocalNotificationHelper registerLocalNotificationWithFireDate:baseDate repeatIterval:NSCalendarUnitDay notificationKey:SSJChargeReminderNotification];
    }
    
    [SSJRegularManager registerRegularTaskNotification];
    
//    NSLog(@">>> 启动时间：%f", [[NSDate date] timeIntervalSinceDate:beginDate]);

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
    
//    SSJPRINT(@"设置根控制器完成");
}

//  初始化数据库
- (void)initializeDatabaseWithFinishHandler:(void (^)(void))finishHandler {
    [[NSNotificationCenter defaultCenter] postNotificationName:SSJInitDatabaseDidBeginNotification object:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        SSJPRINT(@"<<< 初始化数据库开始 >>>");
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
        
        SSJDispatchMainSync(^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SSJInitDatabaseDidFinishNotification object:nil];
        });
        
        if (finishHandler) {
            finishHandler();
        }
//        SSJPRINT(@"<<< 初始化数据库结束 >>>");
    });
}

//  请求启动接口，检测是否有更新、苹果是否正在审核、加载下发启动页
- (void)requestStartAPI {
    SSJStartView *startView = [[SSJStartView alloc] initWithFrame:self.window.bounds];
    [self.window addSubview:startView];
    [[SSJStartChecker sharedInstance] checkWithSuccess:^(BOOL isInReview, SSJAppUpdateType type) {
        //  如果有下发启动页，就显示
        [startView showWithUrl:[NSURL URLWithString:SSJImageURLWithAPI([SSJStartChecker sharedInstance].startImageUrl)]
                      duration:2
                        finish:^{
                            [startView removeFromSuperview];
                            [self showGuideViewIfNeeded];
                        }];
    } failure:^(NSString *message) {
        [startView removeFromSuperview];
        [self showGuideViewIfNeeded];
    }];
}

//  当前版本第一次启动显示引导页
- (void)showGuideViewIfNeeded {
    if (SSJIsFirstLaunchForCurrentVersion()) {
        SSJGuideView *guideView = [[SSJGuideView alloc] initWithFrame:self.window.bounds];
        [guideView showWithFinish:^{
            [self showMotionPasswordIfNeeded];
        }];
    } else {
        [self showMotionPasswordIfNeeded];
    }
}

//  如果手势密码开启，进入手势密码页面
- (void)showMotionPasswordIfNeeded {
    if (!SSJIsUserLogined()) {
        return;
    }
    
    //  如果当前页面已经是手势密码，直接返回
    if ([SSJVisibalController() isKindOfClass:[SSJMotionPasswordViewController class]]) {
        return;
    }
    
    SSJUserItem *userItem = [SSJUserTableManager queryProperty:@[@"motionPWD", @"motionPWDState"] forUserId:SSJUSERID()];
    if ([userItem.motionPWDState boolValue]) {
        
        //  验证手势密码页面
        if (userItem.motionPWD.length) {
            SSJMotionPasswordViewController *motionVC = [[SSJMotionPasswordViewController alloc] init];
            motionVC.type = SSJMotionPasswordViewControllerTypeVerification;
            motionVC.finishHandle = ^(UIViewController *controller) {
                [controller dismissViewControllerAnimated:YES completion:NULL];
            };
            UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:motionVC];
            [self.window.rootViewController presentViewController:naviVC animated:YES completion:NULL];
            
            return;
        }
        
        //  手势密码没有设置过，提醒用户设置
        SSJAlertViewAction *nextAction = [SSJAlertViewAction actionWithTitle:@"下次再说" handler:^(SSJAlertViewAction *action) {
            //  关闭手势密码
            SSJUserItem *userItem = [[SSJUserItem alloc] init];
            userItem.userId = SSJUSERID();
            userItem.motionPWDState = @"0";
            [SSJUserTableManager saveUserItem:userItem];
        }];
        
        __weak typeof(self) weakSelf = self;
        SSJAlertViewAction *sureAction = [SSJAlertViewAction actionWithTitle:@"去设置" handler:^(SSJAlertViewAction *action) {
            SSJMotionPasswordViewController *motionVC = [[SSJMotionPasswordViewController alloc] init];
            motionVC.type = SSJMotionPasswordViewControllerTypeSetting;
            motionVC.finishHandle = ^(UIViewController *controller) {
                [controller dismissViewControllerAnimated:YES completion:NULL];
            };
            UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:motionVC];
            [weakSelf.window.rootViewController presentViewController:naviVC animated:YES completion:NULL];
        }];
        [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"您还没有设置手势密码，是否去设置？" action:nextAction, sureAction, nil];
    }
}

#pragma mark - qq快登
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [TencentOAuth HandleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [TencentOAuth HandleOpenURL:url];
}
@end
