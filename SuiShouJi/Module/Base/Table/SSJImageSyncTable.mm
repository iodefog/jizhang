//
//  SSJImageSyncTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJImageSyncTable.h"

@implementation SSJImageSyncTable

@synthesize imageSourceId;
@synthesize imageName;
@synthesize writeDate;
@synthesize operatorType;
@synthesize syncType;
@synthesize syncState;


//The order of the definitions is the order of the fields in the database
WCDB_IMPLEMENTATION(SSJImageSyncTable)

WCDB_SYNTHESIZE_COLUMN(SSJImageSyncTable, imageSourceId, "RID")
WCDB_SYNTHESIZE_COLUMN(SSJImageSyncTable, imageName, "CIMGNAME")
WCDB_SYNTHESIZE_COLUMN(SSJImageSyncTable, writeDate, "CWRITEDATE")
WCDB_SYNTHESIZE_COLUMN(SSJImageSyncTable, operatorType, "OPERATORTYPE")
WCDB_SYNTHESIZE_COLUMN(SSJImageSyncTable, syncType, "ISYNCTYPE")
WCDB_SYNTHESIZE_COLUMN(SSJImageSyncTable, syncState, "ISYNCSTATE")

WCDB_PRIMARY(SSJImageSyncTable, imageName)

WCDB_NOT_NULL(SSJImageSyncTable, imageSourceId)
WCDB_NOT_NULL(SSJImageSyncTable, imageName)
WCDB_NOT_NULL(SSJImageSyncTable, writeDate)
WCDB_NOT_NULL(SSJImageSyncTable, operatorType)
WCDB_NOT_NULL(SSJImageSyncTable, syncType)
WCDB_NOT_NULL(SSJImageSyncTable, syncState)

@end
