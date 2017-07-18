//
//  SSJImageSyncTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJImageSyncTable : NSObject <WCTTableCoding>

@property (nonatomic, retain) NSString* Id;

@property (nonatomic, retain) NSString* imageName;

@property (nonatomic, retain) NSString* writeDate;

@property (nonatomic, assign) int operatorType;

@property (nonatomic, assign) int syncType;

@property (nonatomic, assign) int syncState;


WCDB_PROPERTY(Id)
WCDB_PROPERTY(imageName)
WCDB_PROPERTY(writeDate)
WCDB_PROPERTY(operatorType)
WCDB_PROPERTY(syncType)
WCDB_PROPERTY(syncState)

@end
