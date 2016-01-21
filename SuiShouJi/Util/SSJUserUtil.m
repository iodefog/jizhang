//
//  SSJUserUtil.m
//  SuiShouJi
//
//  Created by old lang on 16/1/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJUserUtil.h"

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

static NSString *const kSSJUserIdListKey = @"kSSJUserIdInfoKey";
static NSString *const kSSJUserIdInfoIdKey = @"kSSJUserIdInfoIdKey";
static NSString *const kSSJUserIdInfoStateKey = @"kSSJUserIdInfoStateKey";

//  获取列表中
NSString *SSJGetUnregisteredUserId() {
    NSArray *list = [[NSUserDefaults standardUserDefaults] arrayForKey:kSSJUserIdListKey];
    NSDictionary *userIdInfo = [list lastObject];
    if ([userIdInfo isKindOfClass:[NSDictionary class]]) {
        NSNumber *state = userIdInfo[kSSJUserIdInfoStateKey];
        if (state) {
            if (![state boolValue]) {
                return userIdInfo[kSSJUserIdInfoIdKey];
            }
        }
    }
    return nil;
}

//  添加新的userid到列表中
BOOL SSJAddNewUserId(NSString *userId) {
    NSMutableArray *list = [[[NSUserDefaults standardUserDefaults] arrayForKey:kSSJUserIdListKey] mutableCopy];
    [list addObject:@{kSSJUserIdInfoIdKey:userId, kSSJUserIdInfoStateKey:@NO}];
    [[NSUserDefaults standardUserDefaults] setObject:list forKey:kSSJUserIdListKey];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

//  获取新的userid
NSString *SSJGetNewUserId() {
    NSDate *datenow = [NSDate date];
    NSTimeInterval timeSince1970 = [datenow timeIntervalSince1970]*1000;
    NSString *timeSp = [NSString stringWithFormat:@"%lld", (int64_t)timeSince1970];
    NSString *userId = [[[NSString stringWithFormat:@"%@%@",SSJUUID(),timeSp] ssj_md5HexDigest] lowercaseString];
    return userId;
}

static NSString *const kSSJUserIdKey = @"kSSJUserIdKey";

NSString *SSJGetUserId() {
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:kSSJUserIdKey];
    if (userId.length > 0) {
        return userId;
    }
    
    userId = SSJGetUnregisteredUserId();
    if (userId.length) {
        return userId;
    }
    
    userId = SSJGetNewUserId();
    
    if (!SSJAddNewUserId(userId)) {
        SSJPRINT(@">>> SSJWarning:an error occured when add new user id into user list");
    }
    
    if (!SSJSetUserId(userId)) {
        SSJPRINT(@">>> SSJWarning:an error occured when save new user id");
    }
    
    return userId;
}

BOOL SSJSetUserId(NSString *userId) {
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:kSSJUserIdKey];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

static const void *kSSJUSERIDQueueKey = &kSSJUSERIDQueueKey;

NSString *SSJUSERID() {
    static dispatch_queue_t que = nil;
    static dispatch_once_t onceToken;
    static void *userIdQueueContext = &userIdQueueContext;
    dispatch_once(&onceToken, ^{
        if (!que) {
            que = dispatch_queue_create("com.ShuiShouJi.SSJUSERID", DISPATCH_QUEUE_SERIAL);
            dispatch_queue_set_specific(que, kSSJUSERIDQueueKey, userIdQueueContext, NULL);
        }
    });
    
    void *context = dispatch_get_specific(kSSJUSERIDQueueKey);
    if (context == userIdQueueContext) {
        return SSJGetUserId();
    }
    
    __block NSString *userId = nil;
    dispatch_sync(que, ^{
        userId = SSJGetUserId();
    });
    return userId;
}

BOOL SSJRegisterUserId(NSString *userId) {
    NSMutableArray *list = [[[NSUserDefaults standardUserDefaults] arrayForKey:kSSJUserIdListKey] mutableCopy];
    NSDictionary *userIdInfo = [list lastObject];
    
    if ([userIdInfo isKindOfClass:[NSDictionary class]]) {
        NSString *lastUserId = userIdInfo[kSSJUserIdInfoIdKey];
        BOOL isRegistered = [userIdInfo[kSSJUserIdInfoStateKey] boolValue];
        
        if ([lastUserId isEqualToString:userId] && !isRegistered) {
            NSMutableDictionary *newInfo = [userIdInfo mutableCopy];
            [newInfo setObject:@YES forKey:kSSJUserIdInfoStateKey];
            [[NSUserDefaults standardUserDefaults] setObject:list forKey:kSSJUserIdListKey];
            return [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    return NO;
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
