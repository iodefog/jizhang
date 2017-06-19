//
//  SSJShareManager.h
//  SuiShouJi
//
//  Created by ricky on 2017/3/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UShareUI/UShareUI.h>
#import <UShareUI/UMSocialUIManager.h>

@interface SSJShareManager : NSObject

typedef NS_ENUM(NSUInteger, SSJShareType) {
    SSJShareTypeTextOnly = 0,            //  分享文字
    SSJShareTypeImageOnly = 1,           //  分享图片
    SSJShareTypeUrl = 2,                 //  分享url
};


+ (void)shareWithType:(SSJShareType)type
                image:(UIImage *)image
               UrlStr:(NSString *)str
                title:(NSString *)title
              content:(NSString *)content
         PlatformType:(NSArray *)platforms
         inController:(UIViewController *)controller
         ShareSuccess:(void(^)(UMSocialShareResponse *response))success;

@end
