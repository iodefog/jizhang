//
//  SSJRecycleHelper.h
//  SuiShouJi
//
//  Created by old lang on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SSJRecycleListModel;

@interface SSJRecycleHelper : NSObject

+ (void)queryRecycleListModelsWithSuccess:(void(^)(NSArray<SSJRecycleListModel *> *models))success
                                  failure:(nullable void(^)(NSError *error))failure;

+ (void)recoverWithRecycleIDs:(NSArray<NSString *> *)recycleIDs
                      success:(nullable void(^)())success
                      failure:(nullable void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
