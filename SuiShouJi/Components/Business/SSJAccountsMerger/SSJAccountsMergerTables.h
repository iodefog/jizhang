//
//  SSJAccountsMergerTables.h
//  SuiShouJi
//
//  Created by old lang on 16/10/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@protocol SSJAccountsMerge <NSObject>

- (BOOL)mergeFromUserID:(NSString *)userId1 toUserId:(NSString *)userId2 version:(int64_t)version inDatabase:(FMDatabase *)db error:(NSError **)error;

@end

#pragma mark - 提醒表

@interface SSJAccountsMergeRemindTable : NSObject <SSJAccountsMerge>

@end

#pragma mark - 成员表

@interface SSJAccountsMergeMemberTable : NSObject <SSJAccountsMerge>

@end

#pragma mark - 收支类型

@interface SSJAccountsMergeBIllTypeTable : NSObject <SSJAccountsMerge>

@end

#pragma mark - 资金账户

@interface SSJAccountsMergeFundInfoTable : NSObject <SSJAccountsMerge>

@end

#pragma mark - 信用卡

@interface SSJAccountsMergeCreditTable : NSObject <SSJAccountsMerge>

@end

#pragma mark - 账本

@interface SSJAccountsMergeBooksTable : NSObject <SSJAccountsMerge>

@end

#pragma mark - 借贷款

@interface SSJAccountsMergeLoanTable : NSObject <SSJAccountsMerge>

@end

#pragma mark - 周期记账

@interface SSJAccountsMergePeriodChargeTable : NSObject <SSJAccountsMerge>

@end

#pragma mark - 流水

@interface SSJAccountsMergeChargeTable : NSObject <SSJAccountsMerge>

@end

#pragma mark - 成员流水

@interface SSJAccountsMergeMemberChargeTable : NSObject <SSJAccountsMerge>

@end
