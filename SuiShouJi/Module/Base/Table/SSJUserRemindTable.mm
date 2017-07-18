//
//  SSJUserRemindTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserRemindTable.h"

@implementation SSJUserRemindTable

@synthesize remindId;
@synthesize userId;
@synthesize remindName;
@synthesize memo;
@synthesize startDate;
@synthesize state;
@synthesize version;
@synthesize writeDate;
@synthesize operatorType;
@synthesize type;
@synthesize cycle;
@synthesize isEnd;

//The order of the definitions is the order of the fields in the database
WCDB_IMPLEMENTATION(SSJUserRemindTable)

WCDB_SYNTHESIZE_COLUMN(SSJUserRemindTable, remindId, "CREMINDID")
WCDB_SYNTHESIZE_COLUMN(SSJUserRemindTable, userId, "CUSERID")
WCDB_SYNTHESIZE_COLUMN(SSJUserRemindTable, remindName, "CREMINDNAME")
WCDB_SYNTHESIZE_COLUMN(SSJUserRemindTable, memo, "CMEMO")
WCDB_SYNTHESIZE_COLUMN(SSJUserRemindTable, startDate, "CSTARTDATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserRemindTable, state, "ISTATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserRemindTable, version, "IVERSION")
WCDB_SYNTHESIZE_COLUMN(SSJUserRemindTable, writeDate, "CWRITEDATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserRemindTable, operatorType, "OPERATORTYPE")
WCDB_SYNTHESIZE_COLUMN(SSJUserRemindTable, type, "ITYPE")
WCDB_SYNTHESIZE_COLUMN(SSJUserRemindTable, cycle, "ICYCLE")
WCDB_SYNTHESIZE_COLUMN(SSJUserRemindTable, isEnd, "IISEND")

//Primary Key
WCDB_PRIMARY(SSJUserRemindTable, remindId)

@end
