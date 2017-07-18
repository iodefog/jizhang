//
//  SSJFundInfoTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFundInfoTable.h"

@implementation SSJFundInfoTable

@synthesize fundId;
@synthesize fudName;
@synthesize fundIcon;
@synthesize fundParent;
@synthesize fundColor;
@synthesize writeDate;
@synthesize operatorType;
@synthesize version;
@synthesize memo;
@synthesize userId;
@synthesize addDate;
@synthesize fundOrder;
@synthesize display;
@synthesize startColor;
@synthesize endColor;
@synthesize fundType;


//The order of the definitions is the order of the fields in the database
WCDB_IMPLEMENTATION(SSJFundInfoTable)


WCDB_SYNTHESIZE_COLUMN(SSJFundInfoTable, fundId, "CFUNDID")
WCDB_SYNTHESIZE_COLUMN(SSJFundInfoTable, fudName, "CACCTNAME")
WCDB_SYNTHESIZE_COLUMN(SSJFundInfoTable, fundIcon, "CICOIN")
WCDB_SYNTHESIZE_COLUMN(SSJFundInfoTable, fundParent, "CPARENT")
WCDB_SYNTHESIZE_COLUMN(SSJFundInfoTable, fundColor, "CCOLOR")
WCDB_SYNTHESIZE_COLUMN(SSJFundInfoTable, writeDate, "CWRITEDATE")
WCDB_SYNTHESIZE_COLUMN(SSJFundInfoTable, operatorType, "OPERATORTYPE")
WCDB_SYNTHESIZE_COLUMN(SSJFundInfoTable, version, "IVERSION")
WCDB_SYNTHESIZE_COLUMN(SSJFundInfoTable, memo, "CMEMO")
WCDB_SYNTHESIZE_COLUMN(SSJFundInfoTable, userId, "CUSERID")
WCDB_SYNTHESIZE_COLUMN(SSJFundInfoTable, addDate, "CADDDATE")
WCDB_SYNTHESIZE_COLUMN(SSJFundInfoTable, fundOrder, "IORDER")
WCDB_SYNTHESIZE_COLUMN_DEFAULT(SSJFundInfoTable, display, "IDISPLAY", 1)
WCDB_SYNTHESIZE_COLUMN(SSJFundInfoTable, startColor, "CSTARTCOLOR")
WCDB_SYNTHESIZE_COLUMN(SSJFundInfoTable, endColor, "CENDCOLOR")
WCDB_SYNTHESIZE_COLUMN(SSJFundInfoTable, fundType, "ITYPE")

WCDB_PRIMARY(SSJFundInfoTable, fundId)

@end
