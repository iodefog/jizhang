//
//  SSJWeiXinLoginHelper.h
//  SuiShouJi
//
//  Created by ricky on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "SSJThirdPartLoginItem.h"

@interface SSJWeiXinLoginHelper : NSObject<WXApiDelegate>

//微信登陆成功的回调
typedef void (^weiXinLoginSuccessBlock)(SSJThirdPartLoginItem *item);

//微信登录的方法
- (void)weixinLoginWithSucessBlock:(weiXinLoginSuccessBlock)sucessBlock;

@end
