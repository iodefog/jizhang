//
//  SSJGeTuiManager.h
//  SuiShouJi
//
//  Created by ricky on 2017/2/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeTuiSdk.h"

@interface SSJGeTuiManager : NSObject

+ (void)SSJGeTuiManagerWithDelegate:(id<GeTuiSdkDelegate>)delegate;

+ (void)pushToViewControllerWithUserInfo:(NSDictionary *)userInfo;

@end
