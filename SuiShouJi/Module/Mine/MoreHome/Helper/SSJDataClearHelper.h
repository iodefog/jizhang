//
//  SSJDataClearManager.h
//  SuiShouJi
//
//  Created by ricky on 16/7/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJDataClearHelper : NSObject

+ (void)clearLocalDataWithSuccess:(void(^)())success
                      failure:(void (^)(NSError *error))failure;


+ (void)clearAllDataWithSuccess:(void(^)())success
                        failure:(void (^)(NSError *error))failure;
@end
