//
//  SSJShareBooksMemberTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksMemberTable.h"

@implementation SSJShareBooksMemberTable

@synthesize memberId;
@synthesize booksId;
@synthesize joinDate;
@synthesize memberState;
@synthesize memberIcon;
@synthesize leaveDate;

//The order of the definitions is the order of the fields in the database
WCDB_IMPLEMENTATION(SSJShareBooksMemberTable)

WCDB_SYNTHESIZE_COLUMN(SSJShareBooksMemberTable, memberId, "CMEMBERID")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksMemberTable, booksId, "CBOOKSID")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksMemberTable, joinDate, "CJOINDATE")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksMemberTable, memberState, "ISTATE")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksMemberTable, memberIcon, "CICON")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksMemberTable, memberColor, "CCOLOR")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksMemberTable, leaveDate, "CLEAVEDATE")

//Primary Key
WCDB_MULTI_PRIMARY(SSJShareBooksMemberTable, "MultiPrimaryConstraint", memberId)
WCDB_MULTI_PRIMARY(SSJShareBooksMemberTable, "MultiPrimaryConstraint", booksId)

@end
