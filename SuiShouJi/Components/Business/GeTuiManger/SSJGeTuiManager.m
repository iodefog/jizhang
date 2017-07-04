//
//  SSJGeTuiManager.m
//  SuiShouJi
//
//  Created by ricky on 2017/2/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJGeTuiManager.h"
#import <UserNotifications/UserNotifications.h>
#import "SSJPushInfoItem.h"
#import "SSJBookKeepingHomeViewController.h"
#import "SSJRecordMakingViewController.h"
#import "SSJCalendarViewController.h"
#import "SSJReportFormsViewController.h"
#import "SSJFinancingHomeViewController.h"
#import "SSJLoanListViewController.h"
#import "SSJLoanListViewController.h"
#import "SSJBookkeepingTreeViewController.h"
#import "SSJCircleChargeSettingViewController.h"
#import "SSJBudgetEditViewController.h"
#import "SSJSummaryBooksViewController.h"
#import "SSJThemeHomeViewController.h"
#import "SSJReminderViewController.h"
#import "SSJNormalWebViewController.h"
#import "SSJAnnouncementWebViewController.h"
#import "SSJBudgetListViewController.h"
#import "UIViewController+MMDrawerController.h"


@interface SSJGeTuiManager()
/**delegate*/
@property (nonatomic) id delegate;
@end

@implementation SSJGeTuiManager
+ (instancetype) shareManager {
    static dispatch_once_t onceToken;
    static SSJGeTuiManager *geTuiManager;
    dispatch_once(&onceToken, ^{
        geTuiManager = [[SSJGeTuiManager alloc] init];
    });
    return geTuiManager;
}

- (void)SSJGeTuiManagerWithDelegate:(id<GeTuiSdkDelegate>)delegate {
    NSString *appID;
    NSString *appSecret;
    NSString *appKey;
#ifdef PRODUCTION
    appID = SSJDetailSettingForSource(@"GeTuiAppID");
    appSecret = SSJDetailSettingForSource(@"GeTuiAppKey");
    appKey = SSJDetailSettingForSource(@"GeTuiAppSecret");
#else
    appID = SSJDetailSettingForSource(@"GeTuTestiAppID");
    appSecret = SSJDetailSettingForSource(@"GeTuiTestAppKey");
    appKey = SSJDetailSettingForSource(@"GeTuiTestAppSecret");
#endif
    [GeTuiSdk startSdkWithAppId:appID appKey:appKey appSecret:appSecret delegate:delegate];
    self.delegate = delegate;
//    [self registerRemoteNotificationWithDelegate:delegate];
}

- (void)registerRemoteNotificationWithDelegate:(id)delegate {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SSJNoticeAlertKey];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self.delegate;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
            }
        }];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    
}

- (void)pushToViewControllerWithUserInfo:(NSDictionary *)userInfo {
    if (!userInfo) {
        return;
    }
    
    NSDictionary *dic = [userInfo objectForKey:@"customKey"];
    
    SSJPushInfoItem *pushItem = [SSJPushInfoItem mj_objectWithKeyValues:dic];
    
    UIViewController *currentVc = SSJVisibalController();
    
    if (![pushItem.pushTarget isEqualToString:@"SSJBooksTypeSelectViewController"]) {
        [currentVc.mm_drawerController closeDrawerAnimated:NO completion:NULL];
        currentVc = SSJVisibalController();
    }
    
    if (pushItem.pushType == 1) {
        if ([pushItem.pushTarget isEqualToString:@"SSJBookKeepingHomeViewController"]) {
            return;
        } else if ([pushItem.pushTarget isEqualToString:@"SSJRecordMakingViewController"]) {
            SSJRecordMakingViewController *recodeMakingVc = [[SSJRecordMakingViewController alloc] init];
            [currentVc.navigationController pushViewController:recodeMakingVc animated:YES];
        } else if ([pushItem.pushTarget isEqualToString:@"SSJCalendarViewController"]) {
            SSJCalendarViewController *calendarVc = [[SSJCalendarViewController alloc] init];
            [currentVc.navigationController pushViewController:calendarVc animated:YES];
        } else if ([pushItem.pushTarget isEqualToString:@"SSJReportFormsViewController"]) {
            SSJReportFormsViewController *reportFormsVc = [[SSJReportFormsViewController alloc] init];
            [currentVc.navigationController pushViewController:reportFormsVc animated:YES];
        } else if ([pushItem.pushTarget isEqualToString:@"SSJFinancingHomeViewController"]) {
            SSJFinancingHomeViewController *financingHomeVc = [[SSJFinancingHomeViewController alloc] init];
            [currentVc.navigationController pushViewController:financingHomeVc animated:YES];
        } else if ([pushItem.pushTarget isEqualToString:@"SSJBookkeepingTreeViewController"]) {
            SSJBookkeepingTreeViewController *bookKeepingTreeVc = [[SSJBookkeepingTreeViewController alloc] init];
            [currentVc.navigationController pushViewController:bookKeepingTreeVc animated:YES];
        } else if ([pushItem.pushTarget isEqualToString:@"SSJCircleChargeSettingViewController"]) {
            SSJCircleChargeSettingViewController *circleChargeVc = [[SSJCircleChargeSettingViewController alloc] init];
            [currentVc.navigationController pushViewController:circleChargeVc animated:YES];
        } else if ([pushItem.pushTarget isEqualToString:@"SSJBudgetEditViewController"]) {
            SSJBudgetEditViewController *budgetEditeVc = [[SSJBudgetEditViewController alloc] init];
            budgetEditeVc.isEdit = NO;
            [currentVc.navigationController pushViewController:budgetEditeVc animated:YES];
        } else if ([pushItem.pushTarget isEqualToString:@"SSJBudgetListViewController"]) {
            SSJBudgetListViewController *budgetListVc = [[SSJBudgetListViewController alloc] init];
            [currentVc.navigationController pushViewController:budgetListVc animated:YES];
        } else if ([pushItem.pushTarget isEqualToString:@"SSJBooksTypeSelectViewController"]) {
            [currentVc.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:NULL];
        } else if ([pushItem.pushTarget isEqualToString:@"SSJSummaryBooksViewController"]) {
            SSJSummaryBooksViewController *summaryBooksVc = [[SSJSummaryBooksViewController alloc] init];
            [currentVc.navigationController pushViewController:summaryBooksVc animated:YES];
        } else if ([pushItem.pushTarget isEqualToString:@"SSJThemeHomeViewController"]) {
            SSJThemeHomeViewController *themeVc = [[SSJThemeHomeViewController alloc] init];
            [currentVc.navigationController pushViewController:themeVc animated:YES];
        } else if ([pushItem.pushTarget isEqualToString:@"SSJReminderViewController"]) {
            SSJReminderViewController *reminderVc = [[SSJReminderViewController alloc] init];
            [currentVc.navigationController pushViewController:reminderVc animated:YES];
        }

    } else if (pushItem.pushType == 0) {
        SSJNormalWebViewController *webVc = [SSJNormalWebViewController webViewVCWithURL:[NSURL URLWithString:pushItem.pushTarget]];
        [currentVc.navigationController pushViewController:webVc animated:YES];
    } else if (pushItem.pushType == 2) {
        SSJAnnouncementWebViewController *webVc = [SSJAnnouncementWebViewController webViewVCWithURL:[NSURL URLWithString:pushItem.pushTarget]];
        [currentVc.navigationController pushViewController:webVc animated:YES];
    }
    
    }

@end
