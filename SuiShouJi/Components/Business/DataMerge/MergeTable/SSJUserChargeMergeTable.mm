//
//  SSJUserChargeMergeTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/14.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserChargeMergeTable.h"

@implementation SSJUserChargeMergeTable

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
WCDB_IMPLEMENTATION(SSJUserChargeMergeTable)

WCDB_SYNTHESIZE_COLUMN(SSJUserChargeMergeTable, chargeId, "ICHARGEID")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeMergeTable, userId, "CUSERID")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeMergeTable, money, "IMONEY")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeMergeTable, billId, "IBILLID")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeMergeTable, fundId, "IFUNSID")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeMergeTable, addDate, "CADDDATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeMergeTable, oldMoney, "IOLDMONEY")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeMergeTable, balance, "IBALANCE")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeMergeTable, billDate, "CBILLDATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeMergeTable, memo, "CMEMO")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeMergeTable, imgUrl, "CIMGURL")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeMergeTable, thumbUrl, "THUMBURL")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeMergeTable, version, "IVERSION")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeMergeTable, writeDate, "CWRITEDATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeMergeTable, operatorType, "OPERATORTYPE")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeMergeTable, booksId, "CBOOKSID")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeMergeTable, clintAddDate, "CLIENTADDDATE")
WCDB_SYNTHESIZE_COLUMN_DEFAULT(SSJUserChargeMergeTable, chargeType, "ICHARGETYPE", 0)
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeMergeTable, cid, "CID")
WCDB_SYNTHESIZE_COLUMN(SSJUserChargeMergeTable, detailDate, "CDETAILDATE")

WCDB_PRIMARY(SSJUserChargeMergeTable, chargeId)

WCDB_INDEX(SSJUserChargeMergeTable, "_index", userId)

WCDB_NOT_NULL(SSJUserChargeMergeTable, userId)
WCDB_NOT_NULL(SSJUserChargeMergeTable, money)
WCDB_NOT_NULL(SSJUserChargeMergeTable, billId)
WCDB_NOT_NULL(SSJUserChargeMergeTable, userId)
WCDB_NOT_NULL(SSJUserChargeMergeTable, fundId)
WCDB_NOT_NULL(SSJUserChargeMergeTable, version)
WCDB_NOT_NULL(SSJUserChargeMergeTable, writeDate)
WCDB_NOT_NULL(SSJUserChargeMergeTable, operatorType)



@end
