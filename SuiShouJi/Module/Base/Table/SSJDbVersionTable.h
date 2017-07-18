//
//  SSJDbVersionTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJDbVersionTable : NSObject <WCTTableCoding>

@property (nonatomic, assign) int version;

WCDB_PROPERTY(version)

@end
