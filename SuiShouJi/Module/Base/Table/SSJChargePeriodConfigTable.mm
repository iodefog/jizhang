//
//  SSJChargePeriodConfigTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJChargePeriodConfigTable.h"

@implementation SSJChargePeriodConfigTable

@synthesize configId;
@synthesize userId;
@synthesize billId;
@synthesize fundId;
@synthesize type;
@synthesize money;
@synthesize imgUrl;
@synthesize memo;
@synthesize billDate;
@synthesize state;
@synthesize version;
@synthesize writeDate;
@synthesize operatorType;
@synthesize booksId;
@synthesize memberIds;
@synthesize billDateEnd;

//The order of the definitions is the order of the fields in the database
WCDB_IMPLEMENTATION(SSJChargePeriodConfigTable)

WCDB_SYNTHESIZE_COLUMN(SSJChargePeriodConfigTable, configId, "ICONFIGID")
WCDB_SYNTHESIZE_COLUMN(SSJChargePeriodConfigTable, userId, "CUSERID")
WCDB_SYNTHESIZE_COLUMN(SSJChargePeriodConfigTable, billId, "IBILLID")
WCDB_SYNTHESIZE_COLUMN(SSJChargePeriodConfigTable, fundId, "IFUNSID")
WCDB_SYNTHESIZE_COLUMN(SSJChargePeriodConfigTable, type, "ITYPE")
WCDB_SYNTHESIZE_COLUMN(SSJChargePeriodConfigTable, money, "IMONEY")
WCDB_SYNTHESIZE_COLUMN(SSJChargePeriodConfigTable, imgUrl, "CIMGURL")
WCDB_SYNTHESIZE_COLUMN(SSJChargePeriodConfigTable, memo, "CMEMO")
WCDB_SYNTHESIZE_COLUMN(SSJChargePeriodConfigTable, billDate, "IBALANCE")
WCDB_SYNTHESIZE_COLUMN(SSJChargePeriodConfigTable, state, "CBILLDATE")
WCDB_SYNTHESIZE_COLUMN(SSJChargePeriodConfigTable, version, "IVERSION")
WCDB_SYNTHESIZE_COLUMN(SSJChargePeriodConfigTable, writeDate, "CWRITEDATE")
WCDB_SYNTHESIZE_COLUMN(SSJChargePeriodConfigTable, operatorType, "OPERATORTYPE")
WCDB_SYNTHESIZE_COLUMN(SSJChargePeriodConfigTable, booksId, "CBOOKSID")
WCDB_SYNTHESIZE_COLUMN(SSJChargePeriodConfigTable, memberIds, "CLIENTADDDATE")
WCDB_SYNTHESIZE_COLUMN(SSJChargePeriodConfigTable, billDateEnd, "ICHARGETYPE")

WCDB_PRIMARY(SSJChargePeriodConfigTable, configId)

WCDB_NOT_NULL(SSJChargePeriodConfigTable, userId)
WCDB_NOT_NULL(SSJChargePeriodConfigTable, money)
WCDB_NOT_NULL(SSJChargePeriodConfigTable, billId)
WCDB_NOT_NULL(SSJChargePeriodConfigTable, userId)
WCDB_NOT_NULL(SSJChargePeriodConfigTable, fundId)

@end
