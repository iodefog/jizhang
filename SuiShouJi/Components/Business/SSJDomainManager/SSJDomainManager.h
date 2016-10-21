//
//  SSJDomainManager.h
//  SuiShouJi
//
//  Created by old lang on 16/10/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJDomainManager : NSObject

+ (void)requestDomainWithSuccess:(void(^)())success failure:(void(^)(NSError *error))failure;

+ (NSString *)domain;

@end
