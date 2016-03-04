//
//  SSJRegularManager.h
//  SuiShouJi
//
//  Created by old lang on 16/3/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJRegularManager : NSObject

+ (void)registerRegularTask;

+ (void)performRegularTaskWithLocalNotification:(UILocalNotification *)notification;

@end
