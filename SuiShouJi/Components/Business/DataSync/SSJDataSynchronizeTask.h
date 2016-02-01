//
//  SSJDataSynchronizeTask.h
//  SuiShouJi
//
//  Created by old lang on 16/2/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJDataSynchronizeTask : NSObject

/**
 *  开始数据同步
 *
 *  @param success  同步成功回调
 *  @param failure  同步失败回调
 */
- (void)startSyncWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

@end
