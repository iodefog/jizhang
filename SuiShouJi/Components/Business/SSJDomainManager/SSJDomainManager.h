//
//  SSJDomainManager.h
//  SuiShouJi
//
//  Created by old lang on 16/10/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
static NSString *const kDefaultDomain = @"https://jz.youyuwo.com"; // 正式环境
@interface SSJDomainManager : NSObject

+ (NSString *)domain;

+ (NSString *)imageDomain;

+ (void)requestDomain;

@end
