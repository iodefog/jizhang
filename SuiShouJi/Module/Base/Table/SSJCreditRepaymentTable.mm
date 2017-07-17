//
//  SSJCreditRepaymentTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCreditRepaymentTable.h"

@implementation SSJCreditRepaymentTable

@synthesize repaymentId;
@synthesize instalmentCount;
@synthesize applyDate;
@synthesize cardId;
@synthesize repaymentMoney;
@synthesize poudageRate;
@synthesize memo;
@synthesize userId;
@synthesize version;
@synthesize writeDate;
@synthesize operatorType;
@synthesize repaymentMonth;

WCDB_IMPLEMENTATION(SSJCreditRepaymentTable)

WCDB_SYNTHESIZE_COLUMN(SSJCreditRepaymentTable, repaymentId, "CREPAYMENTID")
WCDB_SYNTHESIZE_COLUMN(SSJCreditRepaymentTable, instalmentCount, "IINSTALMENTCOUNT")
WCDB_SYNTHESIZE_COLUMN(SSJCreditRepaymentTable, applyDate, "CAPPLYDATE")
WCDB_SYNTHESIZE_COLUMN(SSJCreditRepaymentTable, cardId, "CCARDID")
WCDB_SYNTHESIZE_COLUMN(SSJCreditRepaymentTable, repaymentMoney, "REPAYMENTMONEY")
WCDB_SYNTHESIZE_COLUMN(SSJCreditRepaymentTable, poudageRate, "IPOUNDAGERATE")
WCDB_SYNTHESIZE_COLUMN(SSJCreditRepaymentTable, memo, "CMEMO")
WCDB_SYNTHESIZE_COLUMN(SSJCreditRepaymentTable, userId, "CUSERID")
WCDB_SYNTHESIZE_COLUMN(SSJCreditRepaymentTable, version, "OPERATORTYPE")
WCDB_SYNTHESIZE_COLUMN(SSJCreditRepaymentTable, writeDate, "CWRITEDATE")
WCDB_SYNTHESIZE_COLUMN(SSJCreditRepaymentTable, operatorType, "IVERSION")
WCDB_SYNTHESIZE_COLUMN(SSJCreditRepaymentTable, repaymentMonth, "CREPAYMENTMONTH")

WCDB_PRIMARY(SSJCreditRepaymentTable, repaymentId)


@end
