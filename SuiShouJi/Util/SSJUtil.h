//
//  SSJUtil.h
//  SuiShouJi
//
//  Created by old lang on 15/10/27.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class UIViewController;

/**
 *  返回完整的接口地址
 *
 *  @param api 接口路径
 *
 *  @return (NSString *)
 */
NSString* SSJURLWithAPI(NSString* api);

NSString* SSJImageURLWithAPI(NSString* api);

/**
 *  返回本地APP名字
 *
 *  @return (NSString *)
 */
NSString *SSJAppName();

/**
 *  获取plist文件中的url scheme
 *
 *  @return (NSString *)
 */
NSString *SSJURLScheme();

/**
 *  返回本地APP版本
 *
 *  @return (NSString *)
 */
NSString *SSJAppVersion();

/**
 *   系统版本
 *
 *   @return (float)
 */
float SSJSystemVersion();

/**
 *  返回当前控制器
 *
 *  @return (UIViewController *)
 */
UIViewController *SSJVisibalController();

/**
 *  获取当前的渠道值
 *
 *  @return (NSString *)
 */
NSString *SSJDefaultSource();

/**
 *  是否为苹果市场的渠道包
 */
BOOL SSJIsAppStoreSource();

/**
 *  根据错误返回相应的提示，如果没有对应的错误提示，就返回nil
 *
 *  @param error 错误
 *  @return (NSString *) 错误提示
 */
NSString *SSJMessageWithErrorCode(NSError *error);

/**
 *  校验姓名是否合法
 *
 *  @return (BOOL)
 */
BOOL checkName(NSString *userName);

/**
 *  当前版本是否第一次启动
 */
BOOL SSJIsFirstLaunchForCurrentVersion();

/**
 *  增加当前版本的启动次数
 */
void SSJAddLaunchTimesForCurrentVersion();

/**
 *  返回存储证书的目录
 *
 *  @return (NSString *)
 */
NSString *SSJSSLCertificatePath();

/**
 *  存储证书
 *
 *  @param certificate 证书
 *  @return (BOOL) 是否保存成功
 */
BOOL SSJSaveSSLCertificate(NSData *certificate);

/**
 *  返回沙盒Document目录
 *
 *  @return (NSString *)
 */
NSString *SSJDocumentPath();

/**
 *  返回数据库文件目录
 *
 *  @return (NSString *)
 */
NSString *SSJSQLitePath();

/**
 *  获取qq客服联系人列表，例如：@[@{@"cqqnum": @"2766500669",@"crealname": @"婷婷"}]
 *
 *  @param certificate 证书
 *  @return (BOOL) 是否保存成功
 */
NSArray *SSJQQList();

/**
 *  存储qq客服联系人列表
 *
 *  @param qqList qq客服数组，例如：@[@{@"cqqnum": @"2766500669",@"crealname": @"婷婷"}]
 *  @return (BOOL) 是否保存成功
 */
BOOL SSJSaveQQList(NSArray *qqList);

/**
 *  获取用户唯一设备编号
 *
 *  @return (NSString *)
 */
NSString *SSJUUID();

/**
 *  将图片存进沙盒
 *
 *  @param image 要保存的图片
 *  @param imageName 图片名称
 *
 *  @return (BOOL) 是否保存成功
 */
void SSJSaveImage(UIImage *image , NSString *imageName);

/**
 *  取出图片在沙盒中的路径
 *
 *  @param imageName 图片名称
 *
 *  @return (NSString *)
 */
NSString *SSJImagePath(NSString *imageName);


/**
 *  根据图片名获取图片
 *
 *  @param imageName @param imageName 图片名称
 *
 *  @return @return (UIImage *)
 */
UIImage *SSJGetChargeImage(NSString *imageName);


