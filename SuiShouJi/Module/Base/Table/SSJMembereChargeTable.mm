//
//  SSJMembereChargeTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJMembereChargeTable.h"

@implementation SSJMembereChargeTable

@synthesize chargeId;
@synthesize memberId;
@synthesize money;
@synthesize version;
@synthesize writeDate;
@synthesize operatorType;

//The order of the definitions is the order of the fields in the database
WCDB_IMPLEMENTATION(SSJMembereChargeTable)

WCDB_SYNTHESIZE_COLUMN(SSJMembereChargeTable, chargeId, "ICHARGEID")
WCDB_SYNTHESIZE_COLUMN(SSJMembereChargeTable, memberId, "CMEMBERID")
WCDB_SYNTHESIZE_COLUMN(SSJMembereChargeTable, money, "IMONEY")
WCDB_SYNTHESIZE_COLUMN(SSJMembereChargeTable, version, "IVERSION")
WCDB_SYNTHESIZE_COLUMN(SSJMembereChargeTable, writeDate, "CWRITEDATE")
WCDB_SYNTHESIZE_COLUMN(SSJMembereChargeTable, operatorType, "OPERATORTYPE")


//Primary Key
WCDB_MULTI_PRIMARY(SSJMembereChargeTable, "MultiPrimaryConstraint", chargeId)
WCDB_MULTI_PRIMARY(SSJMembereChargeTable, "MultiPrimaryConstraint", memberId)

@end
