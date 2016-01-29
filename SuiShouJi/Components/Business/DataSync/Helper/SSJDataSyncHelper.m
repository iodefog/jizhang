//
//  SSJDataSyncHelper.m
//  SuiShouJi
//
//  Created by old lang on 16/1/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJDataSyncHelper.h"

static NSString *const SSJCurrentSyncUserIdKey = @"SSJCurrentSyncUserIdKey";

BOOL SSJSetCurrentSyncUserId(NSString *userid) {
    [[NSUserDefaults standardUserDefaults] setObject:userid forKey:SSJCurrentSyncUserIdKey];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString *SSJCurrentSyncUserId() {
    return [[NSUserDefaults standardUserDefaults] stringForKey:SSJCurrentSyncUserIdKey];
}