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
 返回bundle id

 @return bundle id
 */
NSString *SSJBundleID();

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
 *  当前手机型号
 *
 *  @return (NSString *)
 */
NSString *SSJPhoneModel();

/**
 *  本地补丁最新的版本号
 *
 *  @return (NSString *)
 */
NSString *SSJLastPatchVersion();


/**
 *  保存补丁当前版本号
 *
 *  @param patchVersion 补丁版本号
 *
 *  @return (void)
 */
BOOL SSJSavePatchVersion(NSInteger patchVersion);

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
 返回苹果商店下载地址
 
 @return 苹果商店下载地址
 */
NSString *SSJAppStoreUrl();

/**
 *  返回当前渠道具体配置
 *
 *  @param key 配置的key
 *
 *  @return (NSString *)
 */
NSString* SSJDetailSettingForSource(NSString *key);

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
 把老版本（1.9.2之前并且包涵1.9.2的）版本启动次数数据进行迁移
 */
void SSJMigrateLaunchTimesInfo();

/**
 返回不同版本启动次数数据

 @return 不同版本启动次数
 */
NSDictionary *SSJLaunchTimesInfo();

/**
 *  当前版本的启动次数
 */
NSInteger SSJLaunchTimesForCurrentVersion();

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
 获取设备唯一编号

 @return 设备唯一编号
 */
NSString *SSJUniqueID();

/**
 *  将图片存进沙盒
 *
 *  @param image 要保存的图片
 *  @param imageName 图片名称
 *
 *  @return (void)
 */
BOOL SSJSaveImage(UIImage *image , NSString *imageName);

/**
 *  将缩略图存进沙盒
 *
 *  @param image 要保存的图片
 *  @param imageName 图片名称
 *
 *  @return (void)
 */
BOOL SSJSaveThumbImage(UIImage *image , NSString *imageName);


/**
 *  取出图片在沙盒中的路径
 *
 *  @param imageName 图片名称
 *
 *  @return (NSString *)
 */
NSString *SSJImagePath(NSString *imageName);


/**
 *  获取网络图片的url
 *
 *  @param imageName @param imageName 图片名称
 *
 *  @return (NSString *) 图片url地址
 */
NSString *SSJGetChargeImageUrl(NSString *imageName);


void SSJDispatchMainSync(void (^block)(void));

void SSJDispatchMainAsync(void (^block)(void));

NSString *SSJTitleForCycleType(SSJCyclePeriodType type);

/**
 毫秒级的整数时间戳

 @return int64_t
 */
int64_t SSJMilliTimestamp();

/**
 验证登录密码是否合法

 @param pwd 登录密码
 @return BOOL
 */
BOOL SSJVerifyPassword(NSString *pwd);

/**
 *  交换两个方法的实现，主要用来调试
 *
 *  @param class                交换哪个类中的方法
 *  @param originalSelector     原始方法
 *  @param swizzledSelector     替换的方法
 */
void SSJSwizzleSelector(Class class, SEL originalSelector, SEL swizzledSelector);

SSJBooksCategory SSJGetBooksCategory();

BOOL SSJSaveBooksCategory(SSJBooksCategory category);

void clearCurrentBooksCategory();



