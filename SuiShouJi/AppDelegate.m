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

#import "SSJGradientMaskView.h"
#import "SSJCreditCardItem.h"

#import "SSJLocalNotificationHelper.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "SSJStartViewManager.h"
#import "SSJStartViewManager.h"

#import "SSJPatchUpdateService.h"
#import "SSJJspatchAnalyze.h"
#import "SSJJsPatchItem.h"
#import "SSJBooksTypeSelectViewController.h"
#import "JPEngine.h"
#import "SSJNetworkReachabilityManager.h"
#import "SSJUmengManager.h"
#import "SSJLocalNotificationHelper.h"
#import "SSJLocalNotificationStore.h"

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

@property(nonatomic, strong) SSJPatchUpdateService *service;

@property(nonatomic, strong) SSJGradientMaskView *maskView;
@end

@implementation AppDelegate

#pragma mark - Lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifdef DEBUG
//    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"js"];
//    NSString *script = [NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
//    [JPEngine evaluateScript:script];
#endif
    
    [self analyzeJspatch];
    
    [SSJUmengManager umengTrack];
    [SSJUmengManager umengShare];
        
    [self.service requestPatchWithCurrentVersion:SSJAppVersion()];
    
    [self initializeDatabaseWithFinishHandler:^{
        //  启动时强制同步一次
        [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:NULL failure:NULL];
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
    [SSJNetworkReachabilityManager startMonitoring];
    
    //如果第一次打开记录当前时间
    if (SSJIsFirstLaunchForCurrentVersion()) {
        [[NSUserDefaults standardUserDefaults]setObject:[NSDate date]forKey:SSJLastPopTimeKey];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:SSJHaveLoginOrRegistKey];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:SSJHaveEnterFundingHomeKey];
    }
    
    //微信登录
    [WXApi registerApp:SSJDetailSettingForSource(@"WeiXinKey") withDescription:kWeiXinDescription];
    
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

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    [self pushToControllerWithNotification:notification];
    
        //  收到本地通知后，检测通知是否自动补充定期记账和预算的通知，是的话就进行补充，反之忽略
    [SSJRegularManager performRegularTaskWithLocalNotification:notification];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    SCYSaveEnterBackgroundTime();
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // 当程序从后台进入前台，检测是否自动补充定期记账和预算，因为程序在后台不能收到本地通知
    [SSJRegularManager supplementBookkeepingIfNeededForUserId:SSJUSERID() withSuccess:NULL failure:NULL];
    [SSJRegularManager supplementBudgetIfNeededForUserId:SSJUSERID() withSuccess:NULL failure:NULL];
    
    NSDate *backgroundTime = SCYEnterBackgroundTime();
    NSTimeInterval interval = [backgroundTime timeIntervalSinceDate:[NSDate date]];
    interval = ABS(interval);
    if (interval >= kLockScreenDelay) {
        [SSJMotionPasswordViewController verifyMotionPasswordIfNeeded:NULL animated:NO];
    }
}

#pragma mark - Getter
-(SSJPatchUpdateService *)service{
    if (!_service) {
        _service = [[SSJPatchUpdateService alloc]initWithDelegate:self];
    }
    return _service;
}

-(SSJGradientMaskView *)maskView{
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
            
            //  创建默认的资金帐户
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

- (void)serverDidFinished:(SSJBaseNetworkService *)service{
    if ([service.returnCode isEqualToString:@"1"]) {
        for (int i = 0; i < self.service.patchArray.count; i ++) {
            SSJJsPatchItem *item = [self.service.patchArray objectAtIndex:i];
            if ([item.patchVersion integerValue] > [SSJLastPatchVersion() integerValue]) {
                [SSJJspatchAnalyze SSJJsPatchAnalyzeWithUrl:item.patchUrl MD5:item.patchMD5 patchVersion:item.patchVersion];
            }
        }
    }
}

-(void)analyzeJspatch{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (SSJLastPatchVersion()) {
            for (int i = 0; i <= [SSJLastPatchVersion() integerValue]; i ++) {
                NSString *path = [SSJDocumentPath() stringByAppendingPathComponent:[NSString stringWithFormat:@"JsPatch/patch%d.js",i]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    [JPEngine startEngine];
                    NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
                    [JPEngine evaluateScript:script];
                }
            }
        }
    });
}

#pragma mark - qq快登
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [TencentOAuth HandleOpenURL:url] ||
    [WXApi handleOpenURL:url delegate:[SSJThirdPartyLoginManger shareInstance].weixinLogin];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [TencentOAuth HandleOpenURL:url] ||
    [WXApi handleOpenURL:url delegate:[SSJThirdPartyLoginManger shareInstance].weixinLogin];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
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

@end
