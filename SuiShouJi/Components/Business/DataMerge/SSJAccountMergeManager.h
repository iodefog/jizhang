//
//  SSJAccountMergeManager.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJBaseTableMerge.h"
#import "SSJUserBaseTable.h"

@interface SSJAccountMergeManager : NSObject

- (void)startMergeWithSourceUserId:(NSString *)sourceUserId
                      targetUserId:(NSString *)targetUserId
                         startDate:(NSDate *)startDate
                           endDate:(NSDate *)endDate
                         mergeType:(SSJMergeDataType)type
                           Success:(void(^)())success
                           failure:(void (^)(NSError *error))failure;

- (NSString *)getCurrentUnloggedUserId;

- (BOOL)needToMergeOrNot;

- (void)saveLastMergeTime;

- (SSJUserBaseTable *)getCurrentUser;

@end
