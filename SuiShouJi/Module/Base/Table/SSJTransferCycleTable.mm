//
//  SSJTransferCycleTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJTransferCycleTable.h"

@implementation SSJTransferCycleTable

@synthesize cycleId;
@synthesize userId;
@synthesize transferInId;
@synthesize transferOutId;
@synthesize money;
@synthesize memo;
@synthesize cycleType;
@synthesize beginDate;
@synthesize endDate;
@synthesize cycleState;
@synthesize clintAddDate;
@synthesize writeDate;
@synthesize version;
@synthesize operatorType;


//The order of the definitions is the order of the fields in the database
WCDB_IMPLEMENTATION(SSJTransferCycleTable)

WCDB_SYNTHESIZE_COLUMN(SSJTransferCycleTable, cycleId, "ICYCLEID")
WCDB_SYNTHESIZE_COLUMN(SSJTransferCycleTable, userId, "CUSERID")
WCDB_SYNTHESIZE_COLUMN(SSJTransferCycleTable, transferInId, "CTRANSFERINACCOUNTID")
WCDB_SYNTHESIZE_COLUMN(SSJTransferCycleTable, transferOutId, "CTRANSFEROUTACCOUNTID")
WCDB_SYNTHESIZE_COLUMN(SSJTransferCycleTable, money, "IMONEY")
WCDB_SYNTHESIZE_COLUMN(SSJTransferCycleTable, memo, "CMEMO")
WCDB_SYNTHESIZE_COLUMN(SSJTransferCycleTable, cycleType, "ICYCLETYPE")
WCDB_SYNTHESIZE_COLUMN(SSJTransferCycleTable, beginDate, "CBEGINDATE")
WCDB_SYNTHESIZE_COLUMN(SSJTransferCycleTable, endDate, "CENDDATE")
WCDB_SYNTHESIZE_COLUMN(SSJTransferCycleTable, cycleState, "ISTATE")
WCDB_SYNTHESIZE_COLUMN(SSJTransferCycleTable, clintAddDate, "CLIENTADDDATE")
WCDB_SYNTHESIZE_COLUMN(SSJTransferCycleTable, writeDate, "CWRITEDATE")
WCDB_SYNTHESIZE_COLUMN(SSJTransferCycleTable, version, "IVERSION")
WCDB_SYNTHESIZE_COLUMN(SSJTransferCycleTable, operatorType, "OPERATORTYPE")

//Primary Key
WCDB_PRIMARY(SSJTransferCycleTable, cycleId)

@end
