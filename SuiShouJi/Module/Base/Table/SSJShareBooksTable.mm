//
//  SSJShareBooksTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksTable.h"

@implementation SSJShareBooksTable

@synthesize booksId;
@synthesize creatorId;
@synthesize adminId;
@synthesize booksName;
@synthesize booksColor;
@synthesize booksParent;
@synthesize addDate;
@synthesize booksOrder;
@synthesize writeDate;
@synthesize version;
@synthesize operatorType;

//The order of the definitions is the order of the fields in the database
WCDB_IMPLEMENTATION(SSJShareBooksTable)

WCDB_SYNTHESIZE_COLUMN(SSJShareBooksTable, booksId, "CBOOKSID")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksTable, creatorId, "CCREATOR")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksTable, adminId, "CADMIN")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksTable, booksName, "CBOOKSNAME")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksTable, booksColor, "CBOOKSCOLOR")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksTable, booksParent, "IPARENTTYPE")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksTable, addDate, "CADDDATE")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksTable, booksOrder, "IORDER")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksTable, writeDate, "CWRITEDATE")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksTable, version, "IVERSION")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksTable, operatorType, "OPERATORTYPE")

WCDB_PRIMARY(SSJShareBooksTable, booksId)

@end
