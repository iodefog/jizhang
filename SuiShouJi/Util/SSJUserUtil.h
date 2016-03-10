//
//  SSJUserUtil.h
//  SuiShouJi
//
//  Created by old lang on 16/1/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  存储服务器返回的appid，如果要清除就传nil
 *
 *  @param id appid
 */
BOOL SSJSaveAppId(NSString *appId);

/**
 *  返回appid
 *
 *  @return (NSString *)
 */
NSString *SSJAppId();

/**
 *  存储token，如果要清除就传nil
 *
 *  @param token token字符串
 */
BOOL SSJSaveAccessToken(NSString *token);

/**
 *  获取token
 *
 *  @return (NSString *)
 */
NSString *SSJAccessToken();

/**
 *  存储用户是否登录
 *
 *  @param logined 是否登录
 *  @return (BOOL) 是否存储成功
 */
BOOL SSJSaveUserLogined(BOOL logined);

/**
 *  返回用户是否登录
 *
 *  @return (NSString *)
 */
BOOL SSJIsUserLogined();

/**
 *  清除用户登录信息
 *
 *  @return (BOOL) 是否清除成功
 */
void SSJClearLoginInfo();

/**
 *  设置userid；如果要清空，就设置为nil
 *
 *  @param userId 用户唯一编号
 *  @return (BOOL) 是否设置成功
 */
BOOL SSJSetUserId(NSString *userId);

/**
 *  获取USERID
 *
 *  @return (NSString *) 用户唯一编号
 */
NSString *SSJUSERID();

/**
 *  获取当前同步记录版本号
 *
 *  @return (int64_t) 当前同步记录版本号
 */
int64_t SSJSyncVersion();

/**
 *  更新当前同步记录版本号
 *
 *  @param version 新版本号
 *  @return (BOOL) 是否更新成功
 */
BOOL SSJUpdateSyncVersion(int64_t version);

SSJSyncSettingType SSJSyncSetting();

BOOL SSJSaveSyncSetting(SSJSyncSettingType setting);

