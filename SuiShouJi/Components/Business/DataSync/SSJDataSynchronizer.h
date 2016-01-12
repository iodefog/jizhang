//
//  SSJDataSynchronizer.h
//  SuiShouJi
//
//  Created by old lang on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJDataSynchronizer : NSObject

+ (instancetype)shareInstance;

- (void)startSyncWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

@end
