//
//  AppDelegate.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/11.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import "SSJWeiXinLoginHelper.h"
#import "SSJBaseNetworkService.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate,SSJBaseNetworkServiceDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic, strong) SSJWeiXinLoginHelper *weiXinLogin;

@end

