//
//  SSJLoanTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJLoanTable : NSObject <WCTTableCoding>

@property (nonatomic, retain) NSString* loanId;

@property (nonatomic, retain) NSString* userId;

@property (nonatomic, retain) NSString* lender;

@property (nonatomic, retain) NSString* money;

@property (nonatomic, retain) NSString* fundId;

@property (nonatomic, retain) NSString* targetFundid;

@property (nonatomic, retain) NSString* endTargetFundid;

@property (nonatomic, retain) NSString* borrowDate;

@property (nonatomic, retain) NSString* repaymentDate;

@property (nonatomic, retain) NSString* endDate;

@property (nonatomic, assign) double rate;

@property (nonatomic, retain) NSString* memo;

@property (nonatomic, assign) int interest;

@property (nonatomic, retain) NSString* remindId;

@property (nonatomic, assign) SSJLoginType type;

@property (nonatomic, assign) int end;

@property (nonatomic, assign) int interestType;

@property (nonatomic, retain) NSString* writeDate;

@property (nonatomic, assign) int operatorType;

@property (nonatomic, assign) long long version;

WCDB_PROPERTY(loanId)
WCDB_PROPERTY(userId)
WCDB_PROPERTY(lender)
WCDB_PROPERTY(money)
WCDB_PROPERTY(fundId)
WCDB_PROPERTY(targetFundid)
WCDB_PROPERTY(endTargetFundid)
WCDB_PROPERTY(borrowDate)
WCDB_PROPERTY(repaymentDate)
WCDB_PROPERTY(endDate)
WCDB_PROPERTY(rate)
WCDB_PROPERTY(memo)
WCDB_PROPERTY(interest)
WCDB_PROPERTY(remindId)
WCDB_PROPERTY(type)
WCDB_PROPERTY(end)
WCDB_PROPERTY(interestType)
WCDB_PROPERTY(writeDate)
WCDB_PROPERTY(operatorType)
WCDB_PROPERTY(version)


@end
