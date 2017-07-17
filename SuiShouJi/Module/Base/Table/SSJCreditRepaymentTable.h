//
//  SSJCreditRepaymentTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJCreditRepaymentTable : NSObject <WCTTableCoding>

@property (nonatomic, retain) NSString* repaymentId;

@property (nonatomic, retain) NSString* instalmentCount;

@property (nonatomic, retain) NSString* applyDate;

@property (nonatomic, retain) NSString* cardId;

@property (nonatomic, retain) NSString* repaymentMoney;

@property (nonatomic, assign) double poudageRate;

@property (nonatomic, retain) NSString* memo;

@property (nonatomic, retain) NSString* userId;

@property (nonatomic, assign) long long version;

@property (nonatomic, retain) NSString* writeDate;

@property (nonatomic, assign) int operatorType;

@property (nonatomic, retain) NSString* repaymentMonth;


WCDB_PROPERTY(repaymentId)
WCDB_PROPERTY(instalmentCount)
WCDB_PROPERTY(applyDate)
WCDB_PROPERTY(cardId)
WCDB_PROPERTY(repaymentMoney)
WCDB_PROPERTY(poudageRate)
WCDB_PROPERTY(memo)
WCDB_PROPERTY(userId)
WCDB_PROPERTY(version)
WCDB_PROPERTY(writeDate)
WCDB_PROPERTY(operatorType)
WCDB_PROPERTY(repaymentMonth)


@end
