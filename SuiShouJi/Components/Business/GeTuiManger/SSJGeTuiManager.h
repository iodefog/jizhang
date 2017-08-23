//
//  SSJGeTuiManager.h
//  SuiShouJi
//
//  Created by ricky on 2017/2/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GTSDK/GeTuiSdk.h>

@interface SSJGeTuiManager : NSObject

+ (instancetype)shareManager;

- (void)SSJGeTuiManagerWithDelegate:(id<GeTuiSdkDelegate>)delegate;

- (void)pushToViewControllerWithUserInfo:(NSDictionary *)userInfo;

- (void)registerRemoteNotificationWithDelegate:(id)delegate;
@end
