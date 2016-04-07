//
//  SSJThirdPartyLoginManger.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/4/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJWeiXinLoginHelper.h"
#import "SSJQQLoginHelper.h"

@interface SSJThirdPartyLoginManger : NSObject
@property (nonatomic,strong) SSJWeiXinLoginHelper *weixinLogin;
@property (nonatomic,strong) SSJQQLoginHelper *qqLogin;

//返回为一单例
+ (instancetype)shareInstance;
@end
