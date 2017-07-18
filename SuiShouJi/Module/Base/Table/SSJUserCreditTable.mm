//
//  SSJUserCreditTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserCreditTable.h"

@implementation SSJUserCreditTable

@synthesize cardId;
@synthesize cardQuota;
@synthesize billingDate;
@synthesize repaymentDate;
@synthesize userId;
@synthesize writeDate;
@synthesize version;
@synthesize operatorType;
@synthesize remindId;
@synthesize billDateSettlement;
@synthesize type;

//The order of the definitions is the order of the fields in the database
WCDB_IMPLEMENTATION(SSJUserCreditTable)

WCDB_SYNTHESIZE_COLUMN(SSJUserCreditTable, cardId, "CFUNDID")
WCDB_SYNTHESIZE_COLUMN(SSJUserCreditTable, cardQuota, "IQUOTA")
WCDB_SYNTHESIZE_COLUMN(SSJUserCreditTable, billingDate, "CBILLDATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserCreditTable, repaymentDate, "CREPAYMENTDATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserCreditTable, userId, "CUSERID")
WCDB_SYNTHESIZE_COLUMN(SSJUserCreditTable, writeDate, "CWRITEDATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserCreditTable, version, "IVERSION")
WCDB_SYNTHESIZE_COLUMN(SSJUserCreditTable, operatorType, "CWRITEDATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserCreditTable, remindId, "CREMINDID")
WCDB_SYNTHESIZE_COLUMN(SSJUserCreditTable, billDateSettlement, "IBILLDATESETTLEMENT")
WCDB_SYNTHESIZE_COLUMN(SSJUserCreditTable, type, "ITYPE")

//Primary Key
WCDB_PRIMARY(SSJUserCreditTable, cardId)

@end
