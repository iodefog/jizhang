//
//  SSJLoginVerifyPhoneNumViewModel.h
//  SuiShouJi
//
//  Created by yi cai on 2017/6/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SSJBaseNetworkService;
@class SSJThirdPartLoginItem;

@interface SSJLoginVerifyPhoneNumViewModel : NSObject

/**
 请求验证手机号命令
 */
@property (nonatomic, strong) RACCommand *verifyPhoneNumRequestCommand;

/**微信登录命令*/
@property (nonatomic, strong) RACCommand *wxLoginCommand;

/**qq登录命令*/
@property (nonatomic, strong) RACCommand *qqLoginCommand;

/**注册并登录命令*/
@property (nonatomic, strong) RACCommand *registerAndLoginCommand;

/**获取验证码命令*/
@property (nonatomic, strong) RACCommand *getVerificationCodeCommand;

/**重新获取图形验证码命令*/
@property (nonatomic, strong) RACCommand *reGetVerificationCodeCommand;

/**是否允许点击验证手机号下一步信号*/
@property (nonatomic, strong) RACSignal *enableVerifySignal;

/**是否允许点击注册并登录按钮信号*/
@property (nonatomic, strong) RACSignal *enableRegAndLoginSignal;

/**同意协议*/
@property (nonatomic, assign, getter=isAgreeProtocol) BOOL agreeProtocol;

/**手机号*/
@property (nonatomic, copy) NSString *phoneNum;

/**验证码*/
@property (nonatomic, copy) NSString *verificationCode;

/**密码   */
@property (nonatomic, copy) NSString *passwardNum;

/**注册or忘记密码类型 */
@property (nonatomic, assign) SSJRegistAndForgetPasswordType regOrForType;

/**第三方登录model*/
@property (nonatomic, strong) SSJThirdPartLoginItem *thirdPartLoginItem;

//用户账户类型数据
@property (nonatomic,strong) NSArray *fundInfoArray;

//用户记账类型数据
@property (nonatomic,strong) NSArray *userBillArray;

//用户账本类型数据
@property (nonatomic,strong) NSArray *booksTypeArray;

//用户成员类型数据
@property (nonatomic,strong) NSArray *membersArray;

//用户成员类型数据
@property (nonatomic,strong) NSArray *customCategoryArray;

//登录用户的accesstoken
@property ( nonatomic,strong) NSString *accesstoken;

/**vc*/
@property (nonatomic, assign) __kindof UIViewController *vc;
@end
