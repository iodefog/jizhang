//
//  SSJBookkeepingTreeStore.h
//  SuiShouJi
//
//  Created by old lang on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SSJBookkeepingTreeCheckInModel;

@interface SSJBookkeepingTreeStore : NSObject

+ (void)queryCheckInInfoWithUserId:(NSString *)userId success:(void(^)(SSJBookkeepingTreeCheckInModel *model))success failure:(nullable void(^)(NSError *error))failure;

+ (void)saveCheckInModel:(SSJBookkeepingTreeCheckInModel *)model success:(nullable void(^)())success failure:(nullable void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
