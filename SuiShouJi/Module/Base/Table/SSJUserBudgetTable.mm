//
//  SSJUserBudgetTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserBudgetTable.h"

@implementation SSJUserBudgetTable

@synthesize budgetId; 
@synthesize userId; 
@synthesize budgetType; 
@synthesize money; 
@synthesize remindMoney; 
@synthesize startDate; 
@synthesize endDate; 
@synthesize budgetState; 
@synthesize addDate; 
@synthesize billType; 
@synthesize needRemind; 
@synthesize hasRemind; 
@synthesize writeDate; 
@synthesize version; 
@synthesize operatorType; 
@synthesize booksId; 
@synthesize isLastDay;

//The order of the definitions is the order of the fields in the database
WCDB_IMPLEMENTATION(SSJUserBudgetTable)

WCDB_SYNTHESIZE_COLUMN(SSJUserBudgetTable, budgetId, "IBID")
WCDB_SYNTHESIZE_COLUMN(SSJUserBudgetTable, userId, "CUSERID")
WCDB_SYNTHESIZE_COLUMN(SSJUserBudgetTable, budgetType, "ITYPE")
WCDB_SYNTHESIZE_COLUMN(SSJUserBudgetTable, money, "IMONEY")
WCDB_SYNTHESIZE_COLUMN(SSJUserBudgetTable, remindMoney, "IREMINDMONEY")
WCDB_SYNTHESIZE_COLUMN(SSJUserBudgetTable, startDate, "CSDATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserBudgetTable, endDate, "CEDATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserBudgetTable, budgetState, "ISTATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserBudgetTable, addDate, "CCADDDATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserBudgetTable, billType, "CBILLTYPE")
WCDB_SYNTHESIZE_COLUMN(SSJUserBudgetTable, needRemind, "IREMIND")
WCDB_SYNTHESIZE_COLUMN(SSJUserBudgetTable, hasRemind, "IHASREMIND")
WCDB_SYNTHESIZE_COLUMN(SSJUserBudgetTable, writeDate, "CWRITEDATE")
WCDB_SYNTHESIZE_COLUMN(SSJUserBudgetTable, version, "IVERSION")
WCDB_SYNTHESIZE_COLUMN(SSJUserBudgetTable, operatorType, "OPERATORTYPE")
WCDB_SYNTHESIZE_COLUMN(SSJUserBudgetTable, booksId, "CBOOKSID")
WCDB_SYNTHESIZE_COLUMN_DEFAULT(SSJUserBudgetTable, isLastDay, "ISLASTDAY", 0)

//Primary Key
WCDB_PRIMARY(SSJUserBudgetTable, budgetId)

WCDB_NOT_NULL(SSJUserBudgetTable, budgetId)
WCDB_NOT_NULL(SSJUserBudgetTable, userId)
WCDB_NOT_NULL(SSJUserBudgetTable, budgetType)
WCDB_NOT_NULL(SSJUserBudgetTable, money)
WCDB_NOT_NULL(SSJUserBudgetTable, remindMoney)
WCDB_NOT_NULL(SSJUserBudgetTable, startDate)
WCDB_NOT_NULL(SSJUserBudgetTable, endDate)
WCDB_NOT_NULL(SSJUserBudgetTable, budgetState)
WCDB_NOT_NULL(SSJUserBudgetTable, addDate)
WCDB_NOT_NULL(SSJUserBudgetTable, billType)
WCDB_NOT_NULL(SSJUserBudgetTable, needRemind)
WCDB_NOT_NULL(SSJUserBudgetTable, hasRemind)
WCDB_NOT_NULL(SSJUserBudgetTable, writeDate)
WCDB_NOT_NULL(SSJUserBudgetTable, version)
WCDB_NOT_NULL(SSJUserBudgetTable, operatorType)

@end
