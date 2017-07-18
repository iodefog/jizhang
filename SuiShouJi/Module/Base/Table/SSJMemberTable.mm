//
//  SSJMemberTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJMemberTable.h"

@implementation SSJMemberTable

@synthesize memberId;
@synthesize memberName;
@synthesize userId;
@synthesize operatorType;
@synthesize version;
@synthesize writeDate;
@synthesize memberColor;
@synthesize state;
@synthesize adddate;
@synthesize memberOrder;


//The order of the definitions is the order of the fields in the database
WCDB_IMPLEMENTATION(SSJMemberTable)

WCDB_SYNTHESIZE_COLUMN(SSJMemberTable, memberId, "CMEMBERID")
WCDB_SYNTHESIZE_COLUMN(SSJMemberTable, memberName, "CNAME")
WCDB_SYNTHESIZE_COLUMN(SSJMemberTable, userId, "CUSERID")
WCDB_SYNTHESIZE_COLUMN(SSJMemberTable, operatorType, "OPERATORTYPE")
WCDB_SYNTHESIZE_COLUMN(SSJMemberTable, version, "IVERSION")
WCDB_SYNTHESIZE_COLUMN(SSJMemberTable, writeDate, "CWRITEDATE")
WCDB_SYNTHESIZE_COLUMN(SSJMemberTable, memberColor, "CCOLOR")
WCDB_SYNTHESIZE_COLUMN(SSJMemberTable, state, "ISTATE")
WCDB_SYNTHESIZE_COLUMN(SSJMemberTable, adddate, "CADDDATE")
WCDB_SYNTHESIZE_COLUMN(SSJMemberTable, memberOrder, "IORDER")

//Primary Key
WCDB_MULTI_PRIMARY(SSJMemberTable, "MultiPrimaryConstraint", memberId)
WCDB_MULTI_PRIMARY(SSJMemberTable, "MultiPrimaryConstraint", userId)

WCDB_NOT_NULL(SSJMemberTable, memberName)

@end
