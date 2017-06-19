//
//  SSJUserDefaultDataCreater.h
//  SuiShouJi
//
//  Created by old lang on 16/1/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface SSJUserDefaultDataCreater : NSObject

/**
 创建用户的默认数据（资金账户、收支类型、账本、成员）

 @param userId 用户id
 @param error 错误
 */
+ (void)createAllDefaultDataWithUserId:(NSString *)userId error:(NSError **)error;

/**
 *  创建用户的默认数据（资金账户、收支类型、账本、成员）
 *
 *  @param success  成功的回调
 *  @param failure  失败的回调
 *  @return (void)
 */
+ (void)asyncCreateAllDefaultDataWithUserId:(NSString *)userId
                                    success:(void (^)(void))success
                                    failure:(void (^)(NSError *error))failure;

@end
