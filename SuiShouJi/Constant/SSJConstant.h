//
//  SSJConstant.h
//  SuiShouJi
//
//  Created by old lang on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

///------------------------------------------
/// @name 枚举
///------------------------------------------
#pragma mark - 枚举

//  注册、忘记密码类型
typedef NS_ENUM(NSInteger, SSJRegistAndForgetPasswordType) {
    SSJRegistAndForgetPasswordTypeRegist,           //  注册
    SSJRegistAndForgetPasswordTypeForgetPassword    //  忘记密码
};

//  验证码类型： 0短信 1语音
typedef NS_ENUM(NSInteger, SSJLoginAndRegisterPasswordChannelType) {
    SSJLoginAndRegisterPasswordChannelTypeSMS,           //  注册
    SSJLoginAndRegisterPasswordChannelTypeVoice    //  忘记密码
};

typedef NS_ENUM(NSInteger, SSJSyncSettingType) {
    SSJSyncSettingTypeWWAN = 0,
    SSJSyncSettingTypeWIFI //
};

//  自定义错误码，从10000开始
typedef NS_ENUM(NSInteger, SSJErrorCode) {
    SSJErrorCodeUndefined = 10000,
    SSJErrorCodeDataSyncBusy = 10001,
    SSJErrorCodeDataSyncFailed = 10002,
    SSJErrorCodeImageSyncFailed = 10003,
    SSJErrorCodeNoImageSyncNeedToSync = 10004,
};

//  用户登录方式
typedef NS_ENUM(NSUInteger, SSJLoginType) {
    SSJLoginTypeNormal,
    SSJLoginTypeQQ,
    SSJLoginTypeWeiXin
};

//  收支类型
typedef NS_ENUM(NSInteger, SSJBillType) {
    SSJBillTypeUnknown = -1,  // 未知
    SSJBillTypeIncome = 0,    // 收入
    SSJBillTypePay = 1,       // 支出
    SSJBillTypeSurplus = 2    // 结余(收入＋支出)
};

//  流水类型
typedef NS_ENUM(NSInteger, SSJChargeIdType) {
    SSJChargeIdTypeNormal = 0,        // 普通记账
    SSJChargeIdTypeCircleConfig = 1,  // 周期记账
    SSJChargeIdTypeLoan = 2,          // 借贷
    SSJChargeIdTypeRepayment = 3,     // 还款
    SSJChargeIdTypeTransfer = 4,      // 转账（老版本）
    SSJChargeIdTypeCyclicTransfer = 5, // 周期转账（2.1.0新增）
    SSJChargeIdTypeShareBooks = 6     // 共享账本（2.5.0新增）
};

//  预算周期
typedef NS_ENUM(NSUInteger, SSJBudgetPeriodType) {
    SSJBudgetPeriodTypeWeek = 0,    //  每周
    SSJBudgetPeriodTypeMonth = 1,   //  每月
    SSJBudgetPeriodTypeYear = 2     //  每年
};

/**
 时间维度

 - SSJTimeDimensionDay: 日
 - SSJTimeDimensionWeek: 周
 - SSJTimeDimensionMonth: 月
 */
typedef NS_ENUM(NSInteger, SSJTimeDimension) {
    SSJTimeDimensionUnknown = -1,
    SSJTimeDimensionDay = 0,
    SSJTimeDimensionWeek = 1,
    SSJTimeDimensionMonth = 2
};

/**
 循环周期类型

 - SSJCyclePeriodTypeOnce: 仅一次
 - SSJCyclePeriodTypeDaily: 每天
 - SSJCyclePeriodTypeWorkday: 每个工作日
 - SSJCyclePeriodTypePerWeekend: 每周末
 - SSJCyclePeriodTypeWeekly: 每周
 - SSJCyclePeriodTypePerMonth: 每周末（周六、周日）
 - SSJCyclePeriodTypeLastDayPerMonth: 每月最后一天
 - SSJCyclePeriodTypePerYear: 每年
 */
typedef NS_ENUM(NSInteger, SSJCyclePeriodType) {
    SSJCyclePeriodTypeOnce = -1,
    SSJCyclePeriodTypeDaily = 0,
    SSJCyclePeriodTypeWorkday = 1,
    SSJCyclePeriodTypePerWeekend = 2,
    SSJCyclePeriodTypeWeekly = 3,
    SSJCyclePeriodTypePerMonth = 4,
    SSJCyclePeriodTypeLastDayPerMonth = 5,
    SSJCyclePeriodTypePerYear = 6
};

/**
 账本类型

 - SSJDefaultBooksTypeDaily: 日常
 - SSJDefaultBooksTypeBusiness: 生意
 - SSJDefaultBooksTypeMarriage: 结婚
 - SSJDefaultBooksTypeDecoration: 装修
 - SSJDefaultBooksTypeTravel: 旅行
 */
typedef NS_ENUM(NSInteger, SSJBooksType) {
    SSJBooksTypeDaily = 0,
    SSJBooksTypeBusiness = 1,
    SSJBooksTypeMarriage = 2,
    SSJBooksTypeDecoration = 3,
    SSJBooksTypeTravel = 4
};

/**
 共享账本成员状态
 
 - SSJShareBooksMemberStateNormal: 正常
 - SSJShareBooksMemberStateQuitted: 主动退出
 - SSJShareBooksMemberStateKickedOut: 被踢出
 */
typedef NS_ENUM(NSInteger, SSJShareBooksMemberState) {
    SSJShareBooksMemberStateNormal = 0,
    SSJShareBooksMemberStateQuitted = 1,
    SSJShareBooksMemberStateKickedOut = 2
};



/**
 账本类型

 - SSJBooksCategoryPersional: 个人账本
 - SSJBooksCategoryPublic: 共享账本
 */
typedef NS_ENUM(NSInteger, SSJBooksCategory) {
    SSJBooksCategoryPersional = 0,
    SSJBooksCategoryPublic = 1
};


//  资金账户资产负债类型
typedef NS_ENUM(NSInteger, SSJAccountType) {
    SSJAccountTypeassets = 0,           //  账户类型资产
    SSJAccountTypeliabilities = 1       //  账户类型负债
};

//  信用卡类型
typedef NS_ENUM(NSInteger, SSJCrediteCardType) {
    SSJCrediteCardTypeCrediteCard = 0,    //  信用卡类型信用卡
    SSJCrediteCardTypeAlipay = 1          //  信用卡类型蚂蚁花呗
};


///------------------------------------------
/// @name 基本数据常量
///------------------------------------------
#pragma mark - 基本数据常量
extern const int64_t SSJDefaultSyncVersion;

extern const float SSJMaskAlpha;

extern const NSTimeInterval SSJRequestTimeDuration;

extern const NSUInteger SSJAuthCodeLength;

///------------------------------------------
/// @name 字符串常量
///------------------------------------------
#pragma mark - 字符串常量
//
extern NSString *const SSJErrorDomain;

//  同步加密密钥字符串
extern NSString *const SSJSyncPrivateKey;

//  用户协议url
extern NSString *const SSJUserProtocolUrl;

//微信appid
extern NSString *const SSJWeiXinAppKey;

//微信desc
extern NSString *const SSJWeiXinDescription;

//微信secret
extern NSString *const SSJWeiXinSecret;

//qq appid
extern NSString *const SSJQQAppId;

//qq appkey
extern NSString *const SSJQQAppKey;

//阿里百川 appkey
extern NSString *const SSJYWAppKey;

//微博appkey
extern NSString *const SSJWeiBoAppKey;

//微博secret
extern NSString *const SSJWeiBoSecret;

//美恰appkey
extern NSString *const SSJMQAppKey;

//美恰secret
extern NSString *const SSJMQSecret;

//美恰默认客服组
extern NSString *const SSJMQDefualtGroupId;

//预算超支红色
extern NSString *const SSJOverrunRedColorValue;

//预算剩余绿色
extern NSString *const SSJSurplusGreenColorValue;

// 所有账本id
extern NSString *const SSJAllBooksIds;

// 所有收支类别id
extern NSString *const SSJAllBillTypeId;

// 所有成员id
extern NSString *const SSJAllMembersId;

/** -------------------- KEY -------------------- */
#pragma mark - KEY
//保存上次弹窗的时间
extern NSString *const SSJLastPopTimeKey;

//保存上次保存的广告标识
extern NSString *const SSJLastSavedIdfaKey;

//保存是否登录或者注册过
extern NSString *const SSJHaveLoginOrRegistKey;

//是否进入过资金账户首页
extern NSString *const SSJHaveEnterFundingHomeKey;

//用户的登录方式
extern NSString *const SSJUserLoginTypeKey;

//上一次下载的补丁的key
extern NSString *const SSJLastPatchVersionKey;

//当前使用的账本
extern NSString *const SSJCurrentBooksTypeKey;

//上一次下载的补丁的key
extern NSString *const SSJLastLoggedUserItemKey;

//  本地通知的key
extern NSString *const SSJReminderNotificationKey;

//  已经读过的公告的key
extern NSString *const SSJAnnouncementHaveReadKey;

//保存当前账本类型：共享or个人
extern NSString *const SSJBookCategoryKey;

/** --------------- Notification --------------- */
#pragma mark - Notification
//  数据同步成功通知
extern NSString *const SSJSyncDataSuccessNotification;

//  数据同步失败通知
extern NSString *const SSJSyncDataFailureNotification;

//  图片同步成功通知
extern NSString *const SSJSyncImageSuccessNotification;

//  图片同步失败通知
extern NSString *const SSJSyncImageFailureNotification;

//  登录或者注册成功通知
extern NSString *const SSJLoginOrRegisterNotification;

//  初始化数据库开始的通知
extern NSString *const SSJInitDatabaseDidBeginNotification;

//  初始化数据库完成的通知
extern NSString *const SSJInitDatabaseDidFinishNotification;

//  切换账本的通知
extern NSString *const SSJBooksTypeDidChangeNotification;

//  本地通知的key
extern NSString *const SSJHomeContinueLoadingNotification;
