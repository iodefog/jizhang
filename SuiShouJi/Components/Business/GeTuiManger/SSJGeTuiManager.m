//
//  SSJGeTuiManager.m
//  SuiShouJi
//
//  Created by ricky on 2017/2/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJGeTuiManager.h"
#import <UserNotifications/UserNotifications.h>

@interface SSJGeTuiManager()

@end

@implementation SSJGeTuiManager

+ (void)SSJGeTuiManagerWithDelegate:(id<GeTuiSdkDelegate>)delegate {
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
    
}

- (void)registerRemoteNotification {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
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

@end
