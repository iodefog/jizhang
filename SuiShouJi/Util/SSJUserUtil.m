//
//  SSJUserUtil.m
//  SuiShouJi
//
//  Created by old lang on 16/1/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserUtil.h"
#import "SSJDatabaseQueue.h"

static NSString *const kAppIdKey = @"kAppIdKey";

void SSJSaveAppId(NSString *appId) {
    [[NSUserDefaults standardUserDefaults] setObject:appId forKey:kAppIdKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString *SSJAppId() {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kAppIdKey];
}

static NSString *const AccessTokenKey = @"AccessTokenKey";

void SSJSaveAccessToken(NSString *token) {
    //    NSString *escapedToken = [token stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:AccessTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString *SSJAccessToken() {
    return [[NSUserDefaults standardUserDefaults] stringForKey:AccessTokenKey];
}

static NSString *const kUserLoginedKey = @"kUserLoginedKey";

BOOL SSJSaveUserLogined(BOOL logined) {
    [[NSUserDefaults standardUserDefaults] setBool:logined forKey:kUserLoginedKey];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

BOOL SSJIsUserLogined() {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserLoginedKey];
}

void SSJClearLoginInfo() {
    SSJSaveAppId(nil);
    SSJSaveAccessToken(nil);
    SSJSaveUserLogined(NO);
}

static NSString *const kSSJUserIdKey = @"kSSJUserIdKey";

BOOL SSJSetUserId(NSString *userId) {
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:kSSJUserIdKey];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString *SSJUSERID() {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kSSJUserIdKey];
}

static NSString *const kSSJSycnVersion = @"kSSJSycnVersion";

int64_t SSJSyncVersion() {
    NSNumber *version = [[NSUserDefaults standardUserDefaults] objectForKey:kSSJSycnVersion];
    if (version) {
        return [version longLongValue];
    }
    return SSJDefaultSyncVersion + 1;
};

BOOL SSJUpdateSyncVersion(int64_t version) {
    [[NSUserDefaults standardUserDefaults] setObject:@(version) forKey:kSSJSycnVersion];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}
