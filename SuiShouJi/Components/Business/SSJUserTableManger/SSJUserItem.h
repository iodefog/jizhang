//
//  SSJUserItem.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@interface SSJUserItem : SSJBaseItem

//  用户id
@property (nonatomic, copy) NSString *userId;

//  登录密码
@property (nonatomic, copy) NSString *loginPWD;

//  资金密码
@property (nonatomic, copy) NSString *fundPWD;

//  手势密码
@property (nonatomic, copy) NSString *motionPWD;

//  手势密码开启状态（1:开启 0:关闭）
@property (nonatomic, copy) NSString *motionPWDState;

//  用户昵称
@property (nonatomic, copy) NSString *nickName;

//  手机号码
@property (nonatomic, copy) NSString *mobileNo;

//  真实姓名
@property (nonatomic, copy) NSString *realName;

//  身份证号码
@property (nonatomic, copy) NSString *idCardNo;

//  头像
@property (nonatomic, copy) NSString *icon;

//  注册状态（0:未注册 1:已注册）
@property (nonatomic, copy) NSString *registerState;

//  默认资金帐户创建状态（0:为创建 1:已创建）
@property (nonatomic, copy) NSString *defaultFundAcctState;
//
//  默认资金帐户创建状态（0:为创建 1:已创建）
@property (nonatomic, copy) NSString *defaultBooksTypeState;
//
//  默认资金帐户创建状态（0:为创建 1:已创建）
@property (nonatomic, copy) NSString *defaultMemberState;

//  个性签名
@property (nonatomic, strong) NSString *signature;

//  客户端修改时间（目前只有修改昵称、个性签名才能改这个属性）
@property (nonatomic, copy) NSString *writeDate;

//  手势密码显示轨迹（1为显示 0为隐藏）
@property (nonatomic, copy) NSString *motionTrackState;

//  指纹解锁（1为显示 0为隐藏）
@property (nonatomic, copy) NSString *fingerPrintState;

//  当前选中的账本id(默认为0)
@property(nonatomic, strong) NSString *currentBooksId;

@property(nonatomic, strong) NSString *loginType;

@property(nonatomic, strong) NSString *openId;

// 是否提示过用户设置手势密码
@property(nonatomic, strong) NSString *remindSettingMotionPWD;

// 用户导出数据的邮箱地址
@property(nonatomic, copy) NSString *email;

+ (NSDictionary *)propertyMapping;

@end
