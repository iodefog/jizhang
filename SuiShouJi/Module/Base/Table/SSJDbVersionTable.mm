//
//  SSJDbVersionTable.mm
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJDbVersionTable.h"

@implementation SSJDbVersionTable

@synthesize version;

WCDB_IMPLEMENTATION(SSJDbVersionTable)

WCDB_SYNTHESIZE_COLUMN_DEFAULT(SSJDbVersionTable, version, "VERSION", 0)

WCDB_PRIMARY(SSJDbVersionTable, version)


/*
//Primary Key
WCDB_SYNTHESIZE(TestTemplate, primary)
//Property With Index
WCDB_SYNTHESIZE(TestTemplate, valueWithIndex)
//Propery With Specified Column Name
WCDB_SYNTHESIZE_COLUMN(TestTemplate, valueWithSpecifiedColumnName, "column_name_in_database")
//Propery With Default Value
WCDB_SYNTHESIZE_DEFAULT(TestTemplate, valueWithDefaultValue, @"default_string_for_database")
//Properies With Multi-Index
WCDB_SYNTHESIZE(TestTemplate, value1WithMultiIndex)
WCDB_SYNTHESIZE(TestTemplate, value2WithMultiIndex)

//Primary Key
WCDB_PRIMARY_ASC_AUTO_INCREMENT(TestTemplate, primary)
//Index
WCDB_INDEX_DESC(TestTemplate, "index_subfix_name", valueWithIndex)
//Multi-Indexes
WCDB_INDEX_DESC(TestTemplate, "mutil_indexes_shared_same_name", value1WithMultiIndex);
WCDB_INDEX_DESC(TestTemplate, "mutil_indexes_shared_same_name", value2WithMultiIndex);
*/

@end
