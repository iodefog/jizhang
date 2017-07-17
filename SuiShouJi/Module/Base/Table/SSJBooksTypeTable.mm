//
//  SSJBooksTypeMergeTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/14.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBooksTypeTable.h"

@implementation SSJBooksTypeTable

@synthesize booksId;
@synthesize booksName;
@synthesize booksColor;
@synthesize booksIcon;
@synthesize userId;
@synthesize version;
@synthesize writeDate;
@synthesize operatorType;
@synthesize booksOrder;
@synthesize parentType;

WCDB_IMPLEMENTATION(SSJBooksTypeTable)

WCDB_SYNTHESIZE_COLUMN(SSJBooksTypeTable, booksId, "CBOOKSID")
WCDB_SYNTHESIZE_COLUMN(SSJBooksTypeTable, booksName, "CBOOKSNAME")
WCDB_SYNTHESIZE_COLUMN(SSJBooksTypeTable, booksColor, "CBOOKSCOLOR")
WCDB_SYNTHESIZE_COLUMN(SSJBooksTypeTable, booksIcon, "CICOIN")
WCDB_SYNTHESIZE_COLUMN(SSJBooksTypeTable, userId, "CUSERID")
WCDB_SYNTHESIZE_COLUMN(SSJBooksTypeTable, version, "IVERSION")
WCDB_SYNTHESIZE_COLUMN(SSJBooksTypeTable, writeDate, "CWRITEDATE")
WCDB_SYNTHESIZE_COLUMN(SSJBooksTypeTable, operatorType, "OPERATORTYPE")
WCDB_SYNTHESIZE_COLUMN(SSJBooksTypeTable, booksOrder, "IORDER")
WCDB_SYNTHESIZE_COLUMN(SSJBooksTypeTable, parentType, "IPARENTTYPE")

WCDB_MULTI_PRIMARY(SSJBooksTypeTable, "MultiPrimaryConstraint", booksId)
WCDB_MULTI_PRIMARY(SSJBooksTypeTable, "MultiPrimaryConstraint", userId)

WCDB_NOT_NULL(SSJBooksTypeTable, booksId)
WCDB_NOT_NULL(SSJBooksTypeTable, booksName)

@end
