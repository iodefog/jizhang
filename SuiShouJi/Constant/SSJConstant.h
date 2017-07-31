//
//  SSJConstant.h
//  SuiShouJi
//
//  Created by old lang on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIGeometry.h>

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
    SSJErrorCodeLoginPasswordIllegal = 10005,
    SSJErrorCodeMobileNoIllegal = 10006,
    SSJErrorCodeUserCancelLogin = 10007
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

 - SSJBooksTypeDaily: 日常
 - SSJBooksTypeBusiness: 生意
 - SSJBooksTypeMarriage: 结婚
 - SSJBooksTypeDecoration: 装修
 - SSJBooksTypeTravel: 旅行
 - SSJBooksTypeBaby: 宝宝
 */
typedef NS_ENUM(NSInteger, SSJBooksType) {
    SSJBooksTypeDaily = 0,
    SSJBooksTypeBusiness = 1,
    SSJBooksTypeMarriage = 2,
    SSJBooksTypeDecoration = 3,
    SSJBooksTypeTravel = 4,
    SSJBooksTypeBaby = 5
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


typedef NS_ENUM(NSUInteger, SSJAdviceType) {
    SSJAdviceTypeAdvice,//产品建议
    SSJAdviceTypeFault,//使用故障
    SSJAdviceTypeTuCao,//我要吐槽
};

/**
 特殊收支类别id

 - SSJSpecialBillIdCloseOutEarning: 平账收入
 - SSJSpecialBillIdCloseOutExpense: 平账支出
 - SSJSpecialBillIdBalanceRollIn: 转入
 - SSJSpecialBillIdBalanceRollOut: 转出
 - SSJSpecialBillIdLoanInterestEarning: 借贷利息收入
 - SSJSpecialBillIdLoanInterestExpense: 借贷利息支出
 - SSJSpecialBillIdLoanChangeEarning: 借贷变更收入
 - SSJSpecialBillIdLoanChangeExpense: 借贷变更支出
 - SSJSpecialBillIdLoanBalanceRollIn: 借贷余额转入
 - SSJSpecialBillIdLoanBalanceRollOut: 借贷余额转出
 - SSJSpecialBillIdCreditAgingPrincipal: 信用卡分期本金
 - SSJSpecialBillIdCreditAgingPoundage: 信用卡分期手续费
 - SSJSpecialBillIdShareBooksCloseOutEarning: 平帐收入(共享账本)
 - SSJSpecialBillIdShareBooksCloseOutExpense: 平帐支出(共享账本)
 */
typedef NS_ENUM(NSUInteger, SSJSpecialBillId) {
    SSJSpecialBillIdCloseOutEarning = 1,
    SSJSpecialBillIdCloseOutExpense = 2,
    SSJSpecialBillIdBalanceRollIn = 3,
    SSJSpecialBillIdBalanceRollOut = 4,
    SSJSpecialBillIdLoanInterestEarning = 5,
    SSJSpecialBillIdLoanInterestExpense = 6,
    SSJSpecialBillIdLoanChangeEarning = 7,
    SSJSpecialBillIdLoanChangeExpense = 8,
    SSJSpecialBillIdLoanBalanceRollIn = 9,
    SSJSpecialBillIdLoanBalanceRollOut = 10,
    SSJSpecialBillIdCreditAgingPrincipal = 11,
    SSJSpecialBillIdCreditAgingPoundage = 12,
    SSJSpecialBillIdShareBooksCloseOutEarning = 13,
    SSJSpecialBillIdShareBooksCloseOutExpense = 14
};

typedef NS_ENUM(NSInteger, SSJReminderType) {
    SSJReminderTypeNormal,       //自定义提醒
    SSJReminderTypeCharge,       //记账提醒
    SSJReminderTypeCreditCard,   //信用卡提醒
    SSJReminderTypeBorrowing,     //借贷提醒提醒
    SSJReminderTypeWish           //愿望提醒
};

typedef NS_ENUM(NSInteger, SSJWishState) {
    SSJWishStateNormalIng,       //进行中且没有完成
    SSJWishStateFinish,          //正常完成
    SSJWishStateTermination,     //终止
    SSJWishStateOverfulFinish,   //超额完成
    SSJReminderTypeRestart,      //重新启动（终止后重新启动）
    SSJWishStateDelete           //删除
};

typedef NS_ENUM(NSInteger, SSJWishType) {
    SSJWishTypeCustom,          // 自定义
    SSJWishTypeDefaultFirst,    // 存下人生第一个1万
    SSJWishTypeTravel,          // 一场说走就走的旅行
    SSJWishTypeBuyGift          // 为‘ta’买礼物
};

typedef NS_ENUM(NSInteger, SSJOperatorType) {
    SSJOperatorTypeCreate,          // 新建
    SSJOperatorTypeModify,          // 修改
    SSJOperatorTypeDelete           // 删除
};

typedef NS_ENUM(NSInteger, SSJWishChargeType) {
    SSJWishChargeTypeNormal,          // 金额
    SSJWishChargeTypeStart,           // 开启心愿
    SSJWishChargeTermination,          //终止心愿
    SSJWishChargeTypeRestart,         // 重新启动（终止后重新启动）
    SSJWishChargeTypeFinish           // 完成心愿
};

//支付方式
typedef NS_ENUM(NSInteger, SSJMethodOfPayment) {
    SSJMethodOfPaymentAlipay,          // 支付宝
    SSJMethodOfPaymentWeChat,           // 微信
};

///------------------------------------------
/// @name 基本数据常量
///------------------------------------------
#pragma mark - 基本数据常量
extern const int64_t SSJDefaultSyncVersion;

// 半透明遮罩背景的透明度
extern const float SSJMaskAlpha;

// 按钮禁用状态的透明度
extern const float SSJButtonDisableAlpha;

extern const NSTimeInterval SSJRequestTimeDuration;

extern const NSUInteger SSJAuthCodeLength;

extern const NSUInteger SSJMobileNoLength;

extern const NSUInteger SSJMinPasswordLength;

extern const NSUInteger SSJMaxPasswordLength;

extern const UIEdgeInsets UIEdgeInsetsEmpty;

///------------------------------------------
/// @name 字符串常量
///------------------------------------------
#pragma mark - 字符串常量
//
extern NSString *const SSJErrorDomain;

// 同步加密密钥字符串
extern NSString *const SSJSyncPrivateKey;

// 登录密码加密key
extern NSString *const SSJLoginPWDEncryptionKey;

// 用户协议url
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

//心愿图片名称(自定义)
extern NSString *const SSJWishCustomImageName;

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

//提醒通知弹框
extern NSString *const SSJNoticeRemindKey;

//保存当前账本类型：共享or个人
extern NSString *const SSJBookCategoryKey;

//是否弹出过通知授权弹框key
extern NSString *const SSJNoticeAlertKey;

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

//  记完一笔通知的key
extern NSString *const SSJHomeFinishJZhangNotification;
