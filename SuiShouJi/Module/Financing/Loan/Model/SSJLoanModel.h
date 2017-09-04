//
//  SSJLoanModel.h
//  SuiShouJi
//
//  Created by old lang on 16/8/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJLoanCompoundChargeModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FMDatabase;

/**
 计息方式

 - SSJLoanInterestTypeUnknown: 未知
 - SSJLoanInterestTypeOriginalPrincipal: 不改变本金计息
 - SSJLoanInterestTypeChangePrincipal: 改变本金计息
 */
typedef NS_ENUM(NSUInteger, SSJLoanInterestType) {
    SSJLoanInterestTypeUnknown = 0,
    SSJLoanInterestTypeOriginalPrincipal = 1,
    SSJLoanInterestTypeChangePrincipal = 2
};

@class FMResultSet;

@interface SSJLoanModel : NSObject <NSCopying>

@property (nonatomic, copy) NSString *ID;

// 用户ID
@property (nonatomic, copy) NSString *userID;

// 借款人／欠款人
@property (nonatomic, copy) NSString *lender;

// 借贷图标
@property (nonatomic, copy, nullable) NSString *image;

// 剩余借入／借出金额（包含扣除余额变更、追加变更）
@property (nonatomic) double jMoney;

// 借入／借出所属账户
@property (nonatomic, copy) NSString *fundID;

// 借入／借出目标账户(结清前)
@property (nonatomic, copy, nullable) NSString *targetFundID;

// 借入／借出目标账户(结清后)
@property (nonatomic, copy, nullable) NSString *endTargetFundID;

// 借入／借出日期
@property (nonatomic, copy) NSDate *borrowDate;

// 期限日期
@property (nonatomic, copy, nullable) NSDate *repaymentDate;

// 结清日期
@property (nonatomic, copy, nullable) NSDate *endDate;

// 利率
@property (nonatomic) double rate;

// 备注
@property (nonatomic, copy, nullable) NSString *memo;

// 提醒ID
@property (nonatomic, copy, nullable) NSString *remindID;

// 是否计息
@property (nonatomic) BOOL interest;

// 是否已结清
@property (nonatomic) BOOL closeOut;

// 0:借出 1:借入
@property (nonatomic) SSJLoanType type;

// 计息方式
@property (nonatomic) SSJLoanInterestType interestType;

@property (nonatomic) int operatorType;

@property (nonatomic) long long version;

@property (nonatomic, copy) NSDate *writeDate;

@property(nonatomic, copy, nullable) NSString *startColor;

@property(nonatomic, copy, nullable) NSString *endColor;

+ (instancetype)modelWithResultSet:(FMResultSet *)resultSet;

/**
 计算借贷余额

 @param db 数据库对象
 @param error 错误描述对象
 @return 是否计算成功
 */
- (BOOL)caculateMoneyInDatabase:(FMDatabase *)db error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
