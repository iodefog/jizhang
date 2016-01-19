//
//  SSJUserDefaultDataCreater.h
//  SuiShouJi
//
//  Created by old lang on 16/1/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJUserDefaultDataCreater : NSObject

+ (void)createFundAccountsWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

@end
