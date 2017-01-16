//
//  SSJDomainManager.h
//  SuiShouJi
//
//  Created by old lang on 16/10/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kDefaultDomain = @"https://jz.youyuwo.com";

@interface SSJDomainManager : NSObject


+ (NSString *)domain;

+ (NSString *)imageDomain;

+ (NSString *)formalDomain;

+ (void)requestDomain;

@end
