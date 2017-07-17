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
FOUNDATION_EXPORT NSString* SSJURLWithAPI(NSString* api);

FOUNDATION_EXPORT NSString* SSJImageURLWithAPI(NSString* api);

/**
 返回bundle id

 @return bundle id
 */
FOUNDATION_EXPORT NSString *SSJBundleID();

/**
 *  返回本地APP名字
 *
 *  @return (NSString *)
 */
FOUNDATION_EXPORT NSString *SSJAppName();

/**
 *  获取plist文件中的url scheme
 *
 *  @return (NSString *)
 */
FOUNDATION_EXPORT NSString *SSJURLScheme();

/**
 *  返回本地APP版本
 *
 *  @return (NSString *)
 */
FOUNDATION_EXPORT NSString *SSJAppVersion();

/**
 *  返回当前应用的图标名称
 *
 *  @return (NSString *)
 */
FOUNDATION_EXPORT NSString *SSJAppIcon();

/**
 *   系统版本
 *
 *   @return (float)
 */
FOUNDATION_EXPORT float SSJSystemVersion();

/**
 *  当前手机型号
 *
 *  @return (NSString *)
 */
FOUNDATION_EXPORT NSString *SSJPhoneModel();

/**
 *  本地补丁最新的版本号
 *
 *  @return (NSString *)
 */
FOUNDATION_EXPORT NSString *SSJLastPatchVersion();


/**
 *  保存补丁当前版本号
 *
 *  @param patchVersion 补丁版本号
 *
 *  @return (void)
 */
FOUNDATION_EXPORT BOOL SSJSavePatchVersion(NSInteger patchVersion);

/**
 *  返回当前控制器
 *
 *  @return (UIViewController *)
 */
FOUNDATION_EXPORT UIViewController *SSJVisibalController();

/**
 *  获取当前的渠道值
 *
 *  @return (NSString *)
 */
FOUNDATION_EXPORT NSString *SSJDefaultSource();

/**
 返回苹果商店下载地址
 
 @return 苹果商店下载地址
 */
FOUNDATION_EXPORT NSString *SSJAppStoreUrl();

/**
 *  返回当前渠道具体配置
 *
 *  @param key 配置的key
 *
 *  @return (NSString *)
 */
FOUNDATION_EXPORT NSString* SSJDetailSettingForSource(NSString *key);

/**
 *  根据错误返回相应的提示，如果没有对应的错误提示，就返回nil
 *
 *  @param error 错误
 *  @return (NSString *) 错误提示
 */
FOUNDATION_EXPORT NSString *SSJMessageWithErrorCode(NSError *error);

/**
 *  校验姓名是否合法
 *
 *  @return (BOOL)
 */
FOUNDATION_EXPORT BOOL checkName(NSString *userName);

/**
 把老版本（1.9.2之前并且包涵1.9.2的）版本启动次数数据进行迁移
 */
FOUNDATION_EXPORT void SSJMigrateLaunchTimesInfo();

/**
 返回不同版本启动次数数据

 @return 不同版本启动次数
 */
FOUNDATION_EXPORT NSDictionary *SSJLaunchTimesInfo();

/**
 返回所有版本的启动次数
 
 @return 所有版本的启动次数
 */
FOUNDATION_EXPORT NSInteger SSJLaunchTimesForAllVersion();

/**
 *  当前版本的启动次数
 */
FOUNDATION_EXPORT NSInteger SSJLaunchTimesForCurrentVersion();

/**
 *  增加当前版本的启动次数
 */
FOUNDATION_EXPORT void SSJAddLaunchTimesForCurrentVersion();

/**
 *  返回存储证书的目录
 *
 *  @return (NSString *)
 */
FOUNDATION_EXPORT NSString *SSJSSLCertificatePath();

/**
 *  存储证书
 *
 *  @param certificate 证书
 *  @return (BOOL) 是否保存成功
 */
FOUNDATION_EXPORT BOOL SSJSaveSSLCertificate(NSData *certificate);

/**
 *  返回沙盒Document目录
 *
 *  @return (NSString *)
 */
FOUNDATION_EXPORT NSString *SSJDocumentPath();

/**
 *  返回数据库文件目录
 *
 *  @return (NSString *)
 */
FOUNDATION_EXPORT NSString *SSJSQLitePath();

/**
 *  获取qq客服联系人列表，例如：@[@{@"cqqnum": @"2766500669",@"crealname": @"婷婷"}]
 *
 *  @param certificate 证书
 *  @return (BOOL) 是否保存成功
 */
FOUNDATION_EXPORT NSArray *SSJQQList();

/**
 *  存储qq客服联系人列表
 *
 *  @param qqList qq客服数组，例如：@[@{@"cqqnum": @"2766500669",@"crealname": @"婷婷"}]
 *  @return (BOOL) 是否保存成功
 */
FOUNDATION_EXPORT BOOL SSJSaveQQList(NSArray *qqList);

/**
 *  获取用户唯一设备编号
 *
 *  @return (NSString *)
 */
FOUNDATION_EXPORT NSString *SSJUUID();

/**
 获取设备唯一编号

 @return 设备唯一编号
 */
FOUNDATION_EXPORT NSString *SSJUniqueID();

/**
 *  将图片存进沙盒
 *
 *  @param image 要保存的图片
 *  @param imageName 图片名称
 *
 *  @return (void)
 */
FOUNDATION_EXPORT BOOL SSJSaveImage(UIImage *image , NSString *imageName);

/**
 *  将缩略图存进沙盒
 *
 *  @param image 要保存的图片
 *  @param imageName 图片名称
 *
 *  @return (void)
 */
FOUNDATION_EXPORT BOOL SSJSaveThumbImage(UIImage *image , NSString *imageName);


/**
 *  取出图片在沙盒中的路径
 *
 *  @param imageName 图片名称
 *
 *  @return (NSString *)
 */
FOUNDATION_EXPORT NSString *SSJImagePath(NSString *imageName);


/**
 *  获取网络图片的url
 *
 *  @param imageName @param imageName 图片名称
 *
 *  @return (NSString *) 图片url地址
 */
FOUNDATION_EXPORT NSString *SSJGetChargeImageUrl(NSString *imageName);


void SSJDispatchMainSync(void (^block)(void));

void SSJDispatchMainAsync(void (^block)(void));

FOUNDATION_EXPORT NSString *SSJTitleForCycleType(SSJCyclePeriodType type);

/**
 毫秒级的整数时间戳

 @return int64_t
 */
FOUNDATION_EXPORT int64_t SSJMilliTimestamp();

/**
 验证登录密码是否合法

 @param pwd 登录密码
 @return BOOL
 */
FOUNDATION_EXPORT BOOL SSJVerifyPassword(NSString *pwd);

/**
 *  交换两个方法的实现，主要用来调试
 *
 *  @param class                交换哪个类中的方法
 *  @param originalSelector     原始方法
 *  @param swizzledSelector     替换的方法
 */
FOUNDATION_EXPORT void SSJSwizzleSelector(Class className, SEL originalSelector, SEL swizzledSelector);

FOUNDATION_EXPORT SSJBooksCategory SSJGetBooksCategory();

FOUNDATION_EXPORT BOOL SSJSaveBooksCategory(SSJBooksCategory category);

FOUNDATION_EXPORT void clearCurrentBooksCategory();

/**
 加入qq群

 @param group qq群号
 @param key ？？？
 @return 如果没有安装qq客户端，就返回NO
 */
FOUNDATION_EXPORT BOOL SSJJoinQQGroup(NSString *group, NSString *key);

/**
 验证指纹成功时得到的数据

 @return <#return value description#>
 */
FOUNDATION_EXPORT NSData *SSJEvaluatedPolicyDomainState();

/**
 保存验证指纹成功后得到的数据

 @param data <#data description#>
 @return <#return value description#>
 */
FOUNDATION_EXPORT BOOL SSJUpdateEvaluatedPolicyDomainState(NSData *data);
