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
//点击头像回调
typedef void (^weiXinLoginSuccessBlock)(NSString *nickName , NSString *iconUrl , NSString *openId);

@property (nonatomic, copy) weiXinLoginSuccessBlock weiXinLoginSuccessBlock;

@end
