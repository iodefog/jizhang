//
//  SSJLoanTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJLoanTable.h"

@implementation SSJLoanTable

@synthesize loanId;
@synthesize userId;
@synthesize lender;
@synthesize money;
@synthesize fundId;
@synthesize targetFundid;
@synthesize endTargetFundid;
@synthesize borrowDate;
@synthesize repaymentDate;
@synthesize endDate;
@synthesize rate;
@synthesize memo;
@synthesize interest;
@synthesize remindId;
@synthesize type;
@synthesize end;
@synthesize interestType;
@synthesize operatorType;
@synthesize version;

WCDB_IMPLEMENTATION(SSJLoanTable)

WCDB_SYNTHESIZE_COLUMN(SSJLoanTable, loanId, "LOANID")
WCDB_SYNTHESIZE_COLUMN(SSJLoanTable, userId, "CUSERID")
WCDB_SYNTHESIZE_COLUMN(SSJLoanTable, lender, "LENDER")
WCDB_SYNTHESIZE_COLUMN(SSJLoanTable, money, "JMONEY")
WCDB_SYNTHESIZE_COLUMN(SSJLoanTable, fundId, "CTHEFUNDID")
WCDB_SYNTHESIZE_COLUMN(SSJLoanTable, targetFundid, "CTARGETFUNDID")
WCDB_SYNTHESIZE_COLUMN(SSJLoanTable, endTargetFundid, "CETARGET")
WCDB_SYNTHESIZE_COLUMN(SSJLoanTable, borrowDate, "CBORROWDATE")
WCDB_SYNTHESIZE_COLUMN(SSJLoanTable, repaymentDate, "CREPAYMENTDATE")
WCDB_SYNTHESIZE_COLUMN(SSJLoanTable, endDate, "CENDDATE")
WCDB_SYNTHESIZE_COLUMN(SSJLoanTable, rate, "RATE")
WCDB_SYNTHESIZE_COLUMN(SSJLoanTable, memo, "MEMO")
WCDB_SYNTHESIZE_COLUMN(SSJLoanTable, interest, "INTEREST")
WCDB_SYNTHESIZE_COLUMN(SSJLoanTable, remindId, "CREMINDID")
WCDB_SYNTHESIZE_COLUMN(SSJLoanTable, type, "ITYPE")
WCDB_SYNTHESIZE_COLUMN(SSJLoanTable, end, "IEND")
WCDB_SYNTHESIZE_COLUMN(SSJLoanTable, interestType, "INTERESTTYPE")
WCDB_SYNTHESIZE_COLUMN(SSJLoanTable, writeDate, "ITYPE")
WCDB_SYNTHESIZE_COLUMN(SSJLoanTable, operatorType, "ITYPE")
WCDB_SYNTHESIZE_COLUMN(SSJLoanTable, version, "ITYPE")


@end
