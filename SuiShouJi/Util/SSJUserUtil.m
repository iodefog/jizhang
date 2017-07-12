//
//  SSJUserUtil.m
//  SuiShouJi
//
//  Created by old lang on 16/1/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserUtil.h"
#import "SSJDatabaseQueue.h"
#import "SSJUserTableManager.h"
#import "SSJLocalNotificationHelper.h"

static NSString *const kAppIdKey = @"kAppIdKey";

BOOL SSJSaveAppId(NSString *appId) {
    [[NSUserDefaults standardUserDefaults] setObject:appId forKey:kAppIdKey];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString *SSJAppId() {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kAppIdKey];
}

static NSString *const AccessTokenKey = @"AccessTokenKey";

BOOL SSJSaveAccessToken(NSString *token) {
    //    NSString *escapedToken = [token stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:AccessTokenKey];
    return [[NSUserDefaults standardUserDefaults] synchronize];
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

SSJLoginType SSJUserLoginType(){
    return [[NSUserDefaults standardUserDefaults] integerForKey:SSJUserLoginTypeKey];
}

void SSJClearLoginInfo() {
    [SSJLocalNotificationHelper cancelLocalNotificationWithUserId:SSJUSERID()];
    SSJSaveAppId(nil);
    SSJSaveAccessToken(nil);
    SSJSaveUserLogined(NO);
    clearCurrentBooksCategory();
}

static NSString *const kSSJUserIdKey = @"kSSJUserIdKey";

BOOL SSJSetUserId(NSString *userId) {
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:kSSJUserIdKey];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString *SSJUSERID() {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kSSJUserIdKey];
}

NSString *SSJDefaultMemberId() {
    return [NSString stringWithFormat:@"%@-0", SSJUSERID()];
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

static NSString *const kSSJSyncSettingTypeKey = @"kSSJSyncSettingTypeKey";

SSJSyncSettingType SSJSyncSetting() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:kSSJSyncSettingTypeKey];
}

BOOL SSJSaveSyncSetting(SSJSyncSettingType setting) {
    [[NSUserDefaults standardUserDefaults] setInteger:setting forKey:kSSJSyncSettingTypeKey];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}
