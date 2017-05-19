//
//  SSJUserItem.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJUserItem : NSObject <NSCopying>

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

//  个性签名
@property (nonatomic, copy) NSString *signature;

//  客户端修改时间（目前只有修改昵称、个性签名才能改这个属性）
@property (nonatomic, copy) NSString *writeDate;

//  手势密码显示轨迹（1为显示 0为隐藏）
@property (nonatomic, copy) NSString *motionTrackState;

//  指纹解锁（1为显示 0为隐藏）
@property (nonatomic, copy) NSString *fingerPrintState;

//  当前选中的账本id(默认为0)
@property(nonatomic, copy) NSString *currentBooksId;

@property(nonatomic, copy) NSString *loginType;

@property(nonatomic, copy) NSString *openId;

// 是否提示过用户设置手势密码
@property(nonatomic, copy) NSString *remindSettingMotionPWD;

// 用户导出数据的邮箱地址
@property(nonatomic, copy) NSString *email;

// 用户最后一条建议回复时间
@property(nonatomic, copy) NSString *adviceTime;

+ (NSDictionary *)propertyMapping;

@end
