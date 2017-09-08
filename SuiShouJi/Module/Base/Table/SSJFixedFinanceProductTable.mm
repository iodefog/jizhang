//
//  SSJUserTreeTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceProductTable.h"

@implementation SSJFixedFinanceProductTable

@synthesize productId;
@synthesize productName;
@synthesize userId;
@synthesize remindId;
@synthesize thisFundid;
@synthesize targetFundid;
@synthesize etargetFundid;
@synthesize money;
@synthesize memo;
@synthesize rate;
@synthesize rateType;
@synthesize time;
@synthesize timeType;
@synthesize interestType;
@synthesize startDate;
@synthesize endDate;
@synthesize isEnd;


//The order of the definitions is the order of the fields in the database
WCDB_IMPLEMENTATION(SSJFixedFinanceProductTable)

WCDB_SYNTHESIZE_COLUMN(SSJFixedFinanceProductTable, productId, "CPRODUCTID")
WCDB_SYNTHESIZE_COLUMN(SSJFixedFinanceProductTable, userId, "CUSERID")
WCDB_SYNTHESIZE_COLUMN(SSJFixedFinanceProductTable, productName, "CPRODUCTNAME")
WCDB_SYNTHESIZE_COLUMN(SSJFixedFinanceProductTable, memo, "CMEMO")
WCDB_SYNTHESIZE_COLUMN(SSJFixedFinanceProductTable, thisFundid, "CTHISFUNDID")
WCDB_SYNTHESIZE_COLUMN(SSJFixedFinanceProductTable, targetFundid, "CTARGETFUNDID")
WCDB_SYNTHESIZE_COLUMN(SSJFixedFinanceProductTable, etargetFundid, "CETARGETFUNDID")
WCDB_SYNTHESIZE_COLUMN(SSJFixedFinanceProductTable, money, "IMONEY")
WCDB_SYNTHESIZE_COLUMN(SSJFixedFinanceProductTable, rate, "IRATE")
WCDB_SYNTHESIZE_COLUMN(SSJFixedFinanceProductTable, rateType, "IRATETYPE")
WCDB_SYNTHESIZE_COLUMN(SSJFixedFinanceProductTable, time, "ITIME")
WCDB_SYNTHESIZE_COLUMN(SSJFixedFinanceProductTable, timeType, "ITIMETYPE")
WCDB_SYNTHESIZE_COLUMN(SSJFixedFinanceProductTable, interestType, "INTERESTTYPE")
WCDB_SYNTHESIZE_COLUMN(SSJFixedFinanceProductTable, startDate, "CSTARTDATE")
WCDB_SYNTHESIZE_COLUMN(SSJFixedFinanceProductTable, endDate, "CENDDATE")
WCDB_SYNTHESIZE_COLUMN(SSJFixedFinanceProductTable, isEnd, "ISEND")
WCDB_SYNTHESIZE_COLUMN(SSJFixedFinanceProductTable, remindId, "CREMINDID")
WCDB_SYNTHESIZE_COLUMN(SSJFixedFinanceProductTable, writeDate, "CWRITEDATE")
WCDB_SYNTHESIZE_COLUMN(SSJFixedFinanceProductTable, version, "IVERSION")
WCDB_SYNTHESIZE_COLUMN(SSJFixedFinanceProductTable, operatorType, "OPERATORTYPE")

//Primary Key
WCDB_PRIMARY(SSJFixedFinanceProductTable, productId)


WCDB_NOT_NULL(SSJFixedFinanceProductTable, userId)
WCDB_NOT_NULL(SSJFixedFinanceProductTable, productName)
WCDB_NOT_NULL(SSJFixedFinanceProductTable, thisFundid)
WCDB_NOT_NULL(SSJFixedFinanceProductTable, targetFundid)
WCDB_NOT_NULL(SSJFixedFinanceProductTable, money)
WCDB_NOT_NULL(SSJFixedFinanceProductTable, time)
WCDB_NOT_NULL(SSJFixedFinanceProductTable, timeType)

@end
