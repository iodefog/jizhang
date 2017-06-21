//
//  SSJLoginVerifyPhoneNumViewModel.h
//  SuiShouJi
//
//  Created by yi cai on 2017/6/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SSJBaseNetworkService;

@interface SSJLoginVerifyPhoneNumViewModel : NSObject

/**
 请求验证手机号命令
 */
@property (nonatomic, strong) RACCommand *verifyPhoneNumRequestCommand;

/**是否允许点击验证手机号下一步信号*/
@property (nonatomic, strong) RACSignal *enableVerifySignal;

/**微信登录命令*/
@property (nonatomic, strong) RACCommand *wxBtnCommand;

/**qq登录命令*/
@property (nonatomic, strong) RACCommand *qqBtnCommand;

/**同意协议*/
@property (nonatomic, assign, getter=isAgreeProtocol) BOOL agreeProtocol;

/**<#注释#>*/
@property (nonatomic, strong) SSJBaseNetworkService *netWorkService;

/**手机号*/
@property (nonatomic, copy) NSString *phoneNum;
@end
