//
//  SSJUserChargeTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/14.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserChargeTable.h"

@implementation SSJUserChargeTable

@synthesize chargeId;
@synthesize userId;
@synthesize money;
@synthesize billId;
@synthesize fundId;
@synthesize addDate;
@synthesize oldMoney;
@synthesize balance;
@synthesize billDate;
@synthesize memo;
@synthesize imgUrl;
@synthesize thumbUrl;
@synthesize version;
@synthesize writeDate;
@synthesize operatorType;
@synthesize booksId;
@synthesize clintAddDate;
@synthesize chargeType;
@synthesize cid;
@synthesize detailDate;

//The order of the definitions is the order of the fields in the database
WCDB_IMPLEMENTATION(SSJUserChargeTable)

WCDB_SYNTHESIZE_COLUMN(SSJUserChargeTable, chargeId, "ICHARGEID")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeTable, userId, "CUSERID")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeTable, money, "IMONEY")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeTable, billId, "IBILLID")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeTable, fundId, "IFUNSID")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeTable, addDate, "CADDDATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeTable, oldMoney, "IOLDMONEY")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeTable, balance, "IBALANCE")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeTable, billDate, "CBILLDATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeTable, memo, "CMEMO")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeTable, imgUrl, "CIMGURL")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeTable, thumbUrl, "THUMBURL")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeTable, version, "IVERSION")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeTable, writeDate, "CWRITEDATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeTable, operatorType, "OPERATORTYPE")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeTable, booksId, "CBOOKSID")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeTable, clintAddDate, "CLIENTADDDATE")
WCDB_SYNTHESIZE_COLUMN_DEFAULT(SSJUserChargeTable, chargeType, "ICHARGETYPE", 0)
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeTable, cid, "CID")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeTable, detailDate, "CDETAILDATE")

WCDB_PRIMARY(SSJUserChargeTable, chargeId)

WCDB_INDEX(SSJUserChargeTable, "_index", userId)

WCDB_NOT_NULL(SSJUserChargeTable, userId)
WCDB_NOT_NULL(SSJUserChargeTable, money)
WCDB_NOT_NULL(SSJUserChargeTable, billId)
WCDB_NOT_NULL(SSJUserChargeTable, userId)
WCDB_NOT_NULL(SSJUserChargeTable, fundId)
WCDB_NOT_NULL(SSJUserChargeTable, version)
WCDB_NOT_NULL(SSJUserChargeTable, writeDate)
WCDB_NOT_NULL(SSJUserChargeTable, operatorType)



@end
