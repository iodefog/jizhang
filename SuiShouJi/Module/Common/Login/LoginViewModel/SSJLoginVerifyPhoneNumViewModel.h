//
//  SSJLoginVerifyPhoneNumViewModel.h
//  SuiShouJi
//
//  Created by yi cai on 2017/6/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJBaseNetworkService.h"
@class SSJThirdPartLoginItem;

@interface SSJLoginVerifyPhoneNumViewModel : NSObject

@property (nonatomic, strong) SSJBaseNetworkService *netWorkService;
/**
 请求验证手机号命令
 */
@property (nonatomic, strong) RACCommand *verifyPhoneNumRequestCommand;

/**微信登录命令*/
@property (nonatomic, strong) RACCommand *wxLoginCommand;

/**qq登录命令*/
@property (nonatomic, strong) RACCommand *qqLoginCommand;

/**手机号密码登录命令*/
@property (nonatomic, strong) RACCommand *normalLoginCommand;

/**注册并登录命令*/
@property (nonatomic, strong) RACCommand *registerCommand;

/**注册并登录命令*/
@property (nonatomic, strong) RACCommand *forgetPwdCommand;

/**获取验证码命令*/
@property (nonatomic, strong) RACCommand *getVerificationCodeCommand;

/**重新获取图形验证码命令*/
@property (nonatomic, strong) RACCommand *reGetVerificationCodeCommand;

/**是否允许点击验证手机号下一步信号*/
@property (nonatomic, strong) RACSignal *enableVerifySignal;

/**是否允许点击注册并登录按钮信号*/
@property (nonatomic, strong) RACSignal *enableRegAndLoginSignal;

/**手机号密码登录时是否允许点击登录按钮信号*/
@property (nonatomic, strong) RACSignal *enableNormalLoginSignal;

//忘记密码

/**同意协议*/
@property (nonatomic, assign, getter=isAgreeProtocol) BOOL agreeProtocol;

///**是否是图形验证码*/
//@property (nonatomic, assign, getter=isAgreeProtocol) BOOL agreeProtocol;

/**手机号*/
@property (nonatomic, copy) NSString *phoneNum;

/**验证码*/
@property (nonatomic, copy) NSString *verificationCode;

/**密码   */
@property (nonatomic, copy) NSString *passwardNum;

/**注册or忘记密码类型 */
@property (nonatomic, assign) SSJRegistAndForgetPasswordType regOrForType;

/**图形验证码*/
@property (nonatomic, copy) NSString *graphNum;

/**第三方登录model*/
@property (nonatomic, strong) SSJThirdPartLoginItem *thirdPartLoginItem;

//用户账户类型数据
@property (nonatomic,strong) NSArray *fundInfoArray;

//-----------------------------------------------------------------
// 注意：
// bookBillsArray、billType、userBillArray是用来把收支类别数据迁移到新表中
// 如果返回了userBillTypeArray就不会返回bookBillsArray、billType、userBillArray；反之一样
//-----------------------------------------------------------------
//用户用过的收支类别数据（包含自定义类别）；用于对数据进行迁移；结构：@[@{booksid:账本id,cbillid:类别id}]
@property (nonatomic, copy) NSArray *bookBillsArray;

//自定义类别数据（对应老表bk_bill_type）；结构：@{@"ID":@{...}, ...}，ID即billId
@property (nonatomic, copy) NSDictionary<NSString *, NSDictionary *> *billTypeInfo;

//用户收支类别数据（对应老表bk_user_bill结构）；结构：@{@"ID":@{...},...}，ID是cbillid_cbooksid拼接结果
@property (nonatomic, copy) NSDictionary<NSString *, NSDictionary *> *userBillInfo;

//用户收支类别数据（对应新表bk_user_bill_type结构）
@property (nonatomic, copy) NSArray *userBillTypeArray;
//-----------------------------------------------------------------

//用户账本类型数据
@property (nonatomic,strong) NSArray *booksTypeArray;

//用户成员类型数据
@property (nonatomic,strong) NSArray *membersArray;

//???
@property (nonatomic,strong) NSArray *customCategoryArray;

//登录用户的accesstoken
@property ( nonatomic,strong) NSString *accesstoken;

@end
