//
//  SSJShareBooksFriendMarkTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksFriendMarkTable.h"

@implementation SSJShareBooksFriendMarkTable

@synthesize userId;
@synthesize booksId;
@synthesize friendId;
@synthesize friendMark;
@synthesize version;
@synthesize writeDate;
@synthesize operatorType;

//The order of the definitions is the order of the fields in the database
WCDB_IMPLEMENTATION(SSJShareBooksFriendMarkTable)

WCDB_SYNTHESIZE_COLUMN(SSJShareBooksFriendMarkTable, userId, "CUSERID")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksFriendMarkTable, booksId, "CBOOKSID")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksFriendMarkTable, friendId, "CFRIENDID")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksFriendMarkTable, friendMark, "CMARK")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksFriendMarkTable, version, "IVERSION")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksFriendMarkTable, writeDate, "CWRITEDATE")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksFriendMarkTable, operatorType, "OPERATORTYPE")

//Primary Key
WCDB_MULTI_PRIMARY(SSJShareBooksFriendMarkTable, "MultiPrimaryConstraint", userId)
WCDB_MULTI_PRIMARY(SSJShareBooksFriendMarkTable, "MultiPrimaryConstraint", booksId)
WCDB_MULTI_PRIMARY(SSJShareBooksFriendMarkTable, "MultiPrimaryConstraint", friendId)

@end
