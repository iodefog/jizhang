//
//  SSJDomainManager.h
//  SuiShouJi
//
//  Created by old lang on 16/10/21.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJDomainManager : NSObject

/**
 接口域名

 @return <#return value description#>
 */
+ (NSURL *)domain;

/**
 图片域名

 @return <#return value description#>
 */
+ (NSURL *)imageDomain;

/**
 请求下发域名
 */
+ (void)requestDomain;

@end
