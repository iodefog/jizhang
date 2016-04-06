//
//  SSJMagicExportStore.h
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SSJMagicExportStoreBeginDateKey;
extern NSString *const SSJMagicExportStoreEndDateKey;

@interface SSJMagicExportStore : NSObject

+ (void)queryBillPeriodWithSuccess:(void (^)(NSDictionary<NSString *, NSDate *> *result))success failure:(void (^)(NSError *error))failure;

+ (void)queryAllBillDateWithSuccess:(void (^)(NSArray<NSDate *> *result))success failure:(void (^)(NSError *error))failure;

@end
