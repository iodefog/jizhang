//
//  SSJSearchHistoryTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJSearchHistoryTable.h"

@implementation SSJSearchHistoryTable

@synthesize userId;
@synthesize searchContent;
@synthesize historyId;
@synthesize searchDate;


//The order of the definitions is the order of the fields in the database
WCDB_IMPLEMENTATION(SSJSearchHistoryTable)

WCDB_SYNTHESIZE_COLUMN(SSJSearchHistoryTable, userId, "CUSERID")
WCDB_SYNTHESIZE_COLUMN(SSJSearchHistoryTable, searchContent, "CSEARCHCONTENT")
WCDB_SYNTHESIZE_COLUMN(SSJSearchHistoryTable, historyId, "CHISTORYID")
WCDB_SYNTHESIZE_COLUMN(SSJSearchHistoryTable, searchDate, "CSEARCHDATE")

//Primary Key
WCDB_MULTI_PRIMARY(SSJSearchHistoryTable, "MultiPrimaryConstraint", userId)
WCDB_MULTI_PRIMARY(SSJSearchHistoryTable, "MultiPrimaryConstraint", historyId)

WCDB_NOT_NULL(SSJSearchHistoryTable, searchContent)


@end
