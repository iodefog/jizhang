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

+ (nullable SSJBookkeepingTreeCheckInModel *)queryCheckInInfoWithUserId:(NSString *)userId error:(NSError **)error;

+ (BOOL)saveCheckInModel:(SSJBookkeepingTreeCheckInModel *)model error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END