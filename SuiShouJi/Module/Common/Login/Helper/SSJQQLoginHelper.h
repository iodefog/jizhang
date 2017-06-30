//
//  SSJQQLoginHelper.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/4/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "SSJThirdPartLoginItem.h"

@interface SSJQQLoginHelper : NSObject<TencentSessionDelegate>
//QQ登陆成功的回调
typedef void (^qqLoginSuccessBlock)(SSJThirdPartLoginItem *item);

//QQ登陆失败的回调
typedef void (^qqLoginFailBlock)();

//QQ登录的方法
-(void)qqLoginWithSucessBlock:(qqLoginSuccessBlock)sucessBlock failBlock:(qqLoginFailBlock)failBlock;
@end
