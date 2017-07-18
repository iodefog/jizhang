//
//  SSJSyncBaseTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJSyncBaseTable : NSObject <WCTTableCoding>

@property (nonatomic, assign) long long version;

@property (nonatomic, assign) int syncType;

@property (nonatomic, retain) NSString* userId;

WCDB_PROPERTY(version)
WCDB_PROPERTY(syncType)
WCDB_PROPERTY(userId)

@end
