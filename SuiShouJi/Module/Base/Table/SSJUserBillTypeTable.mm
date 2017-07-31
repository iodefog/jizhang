//
//  SSJUserBillTypeTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserBillTypeTable.h"

@implementation SSJUserBillTypeTable

@synthesize billId;
@synthesize userId;
@synthesize booksId;
@synthesize billType;
@synthesize billName;
@synthesize billColor;
@synthesize billIcon;
@synthesize billOrder;
@synthesize writeDate;
@synthesize operatorType;
@synthesize version;



//The order of the definitions is the order of the fields in the database
WCDB_IMPLEMENTATION(SSJUserBillTypeTable)

WCDB_SYNTHESIZE_COLUMN(SSJUserBillTypeTable, billId, "CBILLID")
WCDB_SYNTHESIZE_COLUMN(SSJUserBillTypeTable, userId, "CUSERID")
WCDB_SYNTHESIZE_COLUMN(SSJUserBillTypeTable, booksId, "CBOOKSID")
WCDB_SYNTHESIZE_COLUMN(SSJUserBillTypeTable, billType, "ITYPE")
WCDB_SYNTHESIZE_COLUMN(SSJUserBillTypeTable, billName, "CNAME")
WCDB_SYNTHESIZE_COLUMN(SSJUserBillTypeTable, billColor, "CCOLOR")
WCDB_SYNTHESIZE_COLUMN(SSJUserBillTypeTable, billIcon, "CICOIN")
WCDB_SYNTHESIZE_COLUMN(SSJUserBillTypeTable, billOrder, "IORDER")
WCDB_SYNTHESIZE_COLUMN(SSJUserBillTypeTable, writeDate, "CWRITEDATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserBillTypeTable, operatorType, "OPERATORTYPE")
WCDB_SYNTHESIZE_COLUMN(SSJUserBillTypeTable, version, "IVERSION")

//Primary Key
WCDB_MULTI_PRIMARY(SSJUserBillTypeTable, "MultiPrimaryConstraint", billId)
WCDB_MULTI_PRIMARY(SSJUserBillTypeTable, "MultiPrimaryConstraint", userId)
WCDB_MULTI_PRIMARY(SSJUserBillTypeTable, "MultiPrimaryConstraint", booksId)

@end
