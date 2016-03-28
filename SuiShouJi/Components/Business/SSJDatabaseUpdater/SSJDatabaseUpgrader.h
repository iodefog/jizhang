//
//  SSJDatabaseUpgrader.h
//  SuiShouJi
//
//  Created by old lang on 16/3/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJDatabaseUpgrader : NSObject

+ (NSError *)upgradeDatabase;

+ (void)upgradeDatabaseWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure;

@end
