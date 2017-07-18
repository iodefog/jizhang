//
//  SSJUserTreeTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJUserTreeTable.h"

@implementation SSJUserTreeTable

@synthesize userId;
@synthesize signIn;
@synthesize signInDate;
@synthesize hasShaked;
@synthesize treeImgUrl;
@synthesize treeGifUrl;

//The order of the definitions is the order of the fields in the database
WCDB_IMPLEMENTATION(SSJUserTreeTable)

WCDB_SYNTHESIZE_COLUMN(SSJUserTreeTable, userId, "CUSERID")
WCDB_SYNTHESIZE_COLUMN(SSJUserTreeTable, signIn, "ISIGNIN")
WCDB_SYNTHESIZE_COLUMN(SSJUserTreeTable, signInDate, "ISIGNINDATE")
WCDB_SYNTHESIZE_COLUMN_DEFAULT(SSJUserTreeTable, hasShaked, "HASSHAKED", 0)
WCDB_SYNTHESIZE_COLUMN(SSJUserTreeTable, treeImgUrl, "TREEIMGURL")
WCDB_SYNTHESIZE_COLUMN(SSJUserTreeTable, treeGifUrl, "TREEGIFURL")

WCDB_NOT_NULL(SSJUserTreeTable, userId)
WCDB_NOT_NULL(SSJUserTreeTable, signIn)
WCDB_NOT_NULL(SSJUserTreeTable, signInDate)

@end
