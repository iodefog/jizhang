//
//  SSJLoanModel.h
//  SuiShouJi
//
//  Created by old lang on 16/8/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMResultSet;

typedef NS_ENUM(NSInteger, SSJLoanType) {
    SSJLoanTypeLend,    // 借出
    SSJLoanTypeBorrow   // 借入
};

@interface SSJLoanModel : NSObject <NSCopying>

@property (nonatomic, copy) NSString *ID;

// 用户ID
@property (nonatomic, copy) NSString *userID;

// 借款人／欠款人
@property (nonatomic, copy) NSString *lender;

// 借贷图标
@property (nonatomic, copy) NSString *image;

// 借入／借出金额
@property (nonatomic) double jMoney;

// 借入／借出所属账户
@property (nonatomic, copy) NSString *fundID;

// 借入／借出目标账户
@property (nonatomic, copy) NSString *targetFundID;

// 所属转账流水
@property (nonatomic, copy) NSString *chargeID;

// 目标转账流水
@property (nonatomic, copy) NSString *targetChargeID;

// 结清所属转账流水
@property (nonatomic, copy) NSString *endChargeID;

// 结清目标转账流水
@property (nonatomic, copy) NSString *endTargetChargeID;

// 借入／借出日期
@property (nonatomic, copy) NSDate *borrowDate;

// 期限日期
@property (nonatomic, copy) NSDate *repaymentDate;

// 结清日期
@property (nonatomic, copy) NSDate *endDate;

// 利率
@property (nonatomic) double rate;

// 备注
@property (nonatomic, copy) NSString *memo;

// 提醒ID
@property (nonatomic, copy) NSString *remindID;

// 是否计息
@property (nonatomic) BOOL interest;

// 是否已结清
@property (nonatomic) BOOL closeOut;

// 0:借出 1:借入
@property (nonatomic) SSJLoanType type;

@property (nonatomic) int operatorType;

@property (nonatomic) long long version;

@property (nonatomic, copy) NSDate *writeDate;

+ (instancetype)modelWithResultSet:(FMResultSet *)resultSet;

@end
