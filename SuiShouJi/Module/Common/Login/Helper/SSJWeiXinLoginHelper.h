//
//  SSJWeiXinLoginHelper.h
//  SuiShouJi
//
//  Created by ricky on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WXApi.h>

@interface SSJWeiXinLoginHelper : NSObject<WXApiDelegate>

/**
 *  返回唯一实例对象
 */
+ (instancetype)shareInstance;

//微信登陆成功的回调
typedef void (^weiXinLoginSuccessBlock)(NSString *nickName , NSString *iconUrl , NSString *openId);

//微信登录的方法
-(void)weixinLoginWithSucessBlock:(weiXinLoginSuccessBlock)sucessBlock;

@end
