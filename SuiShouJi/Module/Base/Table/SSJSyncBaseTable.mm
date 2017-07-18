//
//  SSJSyncBaseTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJSyncBaseTable.h"

@implementation SSJSyncBaseTable

@synthesize version;
@synthesize syncType;
@synthesize userId;


//The order of the definitions is the order of the fields in the database
WCDB_IMPLEMENTATION(SSJSyncBaseTable)

WCDB_SYNTHESIZE(SSJSyncBaseTable, version)
WCDB_SYNTHESIZE(SSJSyncBaseTable, syncType)
WCDB_SYNTHESIZE(SSJSyncBaseTable, userId)

@end
