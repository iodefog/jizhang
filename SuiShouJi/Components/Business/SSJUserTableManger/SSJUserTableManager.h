//
//  SSJUserTableManager.h
//  SuiShouJi
//
//  Created by old lang on 16/1/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@interface SSJUserTableManager : NSObject

+ (void)reloadUserIdWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

+ (NSString *)unregisteredUserIdInDatabase:(FMDatabase *)db error:(NSError **)error;

@end
