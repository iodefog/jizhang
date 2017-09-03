//
//  SSJUserRemindTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJUserRemindTable : NSObject <WCTTableCoding>

@property (nonatomic, retain) NSString* remindId;

@property (nonatomic, retain) NSString* userId;

@property (nonatomic, retain) NSString* remindName;

@property (nonatomic, retain) NSString* memo;

@property (nonatomic, retain) NSString* startDate;

@property (nonatomic, assign) BOOL state;

@property (nonatomic, assign) long long version;

@property (nonatomic, assign) int operatorType;

@property (nonatomic, retain) NSString* writeDate;

@property (nonatomic, assign) int type;

@property (nonatomic, assign) SSJCyclePeriodType cycle;

@property (nonatomic, assign) int isEnd;


WCDB_PROPERTY(remindId)
WCDB_PROPERTY(userId)
WCDB_PROPERTY(remindName)
WCDB_PROPERTY(memo)
WCDB_PROPERTY(startDate)
WCDB_PROPERTY(state)
WCDB_PROPERTY(version)
WCDB_PROPERTY(writeDate)
WCDB_PROPERTY(operatorType)
WCDB_PROPERTY(type)
WCDB_PROPERTY(cycle)
WCDB_PROPERTY(isEnd)

@end
