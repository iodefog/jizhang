//
//  SSJLoanModel.h
//  SuiShouJi
//
//  Created by old lang on 16/8/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SSJLoanType) {
    SSJLoanTypeLend,    // 借出
    SSJLoanTypeBorrow   // 借入
};

@interface SSJLoanModel : NSObject

@property (nonatomic, copy) NSString *ID;

// 用户ID
@property (nonatomic, copy) NSString *userID;

// 借款人／欠款人
@property (nonatomic, copy) NSString *lender;

// 借入／借出金额
@property (nonatomic, copy) NSString *jMoney;

// 借入／借出所属账户
@property (nonatomic, copy) NSString *fundID;

// 借入／借出目标账户
@property (nonatomic, copy) NSString *targetFundID;

// 借入／借出日期
@property (nonatomic, copy) NSString *borrowDate;

// 期限日期
@property (nonatomic, copy) NSString *repaymentDate;

// 利率
@property (nonatomic, copy) NSString *rate;

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

@property (nonatomic, copy) NSString *writeDate;

+ (NSDictionary *)propertyMapping;

@end
