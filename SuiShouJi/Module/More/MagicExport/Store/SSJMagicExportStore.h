//
//  SSJMagicExportStore.h
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJMagicExportStore : NSObject

+ (void)queryTheFirstBillDateWithSuccess:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

@end
