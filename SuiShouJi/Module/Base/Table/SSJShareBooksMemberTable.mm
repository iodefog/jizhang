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

WCDB_SYNTHESIZE_COLUMN(SSJShareBooksMemberTable, memberId, "CFRIENDID")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksMemberTable, booksId, "CFRIENDID")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksMemberTable, joinDate, "CFRIENDID")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksMemberTable, memberState, "CFRIENDID")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksMemberTable, memberIcon, "CFRIENDID")
WCDB_SYNTHESIZE_COLUMN(SSJShareBooksMemberTable, leaveDate, "CFRIENDID")

//Primary Key
WCDB_MULTI_PRIMARY(SSJShareBooksMemberTable, "MultiPrimaryConstraint", memberId)
WCDB_MULTI_PRIMARY(SSJShareBooksMemberTable, "MultiPrimaryConstraint", booksId)

@end
