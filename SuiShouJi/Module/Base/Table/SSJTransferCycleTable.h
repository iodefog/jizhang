//
//  SSJTransferCycleTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJTransferCycleTable : NSObject <WCTTableCoding>

@property (nonatomic, retain) NSString* cycleId;

@property (nonatomic, retain) NSString* userId;

@property (nonatomic, retain) NSString* transferInId;

@property (nonatomic, retain) NSString* transferOutId;

@property (nonatomic, assign) double money;

@property (nonatomic, retain) NSString* memo;

@property (nonatomic, assign) int cycleType;

@property (nonatomic, retain) NSString* beginDate;

@property (nonatomic, retain) NSString* endDate;

@property (nonatomic, assign) int cycleState;

@property (nonatomic, retain) NSString* clintAddDate;

@property (nonatomic, retain) NSString* writeDate;

@property (nonatomic, assign) long long version;

@property (nonatomic, assign) int operatorType;


WCDB_PROPERTY(cycleId)
WCDB_PROPERTY(userId)
WCDB_PROPERTY(transferInId)
WCDB_PROPERTY(transferOutId)
WCDB_PROPERTY(money)
WCDB_PROPERTY(memo)
WCDB_PROPERTY(cycleType)
WCDB_PROPERTY(beginDate)
WCDB_PROPERTY(endDate)
WCDB_PROPERTY(cycleState)
WCDB_PROPERTY(clintAddDate)
WCDB_PROPERTY(writeDate)
WCDB_PROPERTY(version)
WCDB_PROPERTY(operatorType)

@end
