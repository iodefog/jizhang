//
//  SSJMemberTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJMemberTable : NSObject <WCTTableCoding>

@property (nonatomic, retain) NSString* memberId;

@property (nonatomic, retain) NSString* memberName;

@property (nonatomic, retain) NSString* userId;

@property (nonatomic, assign) int operatorType;

@property (nonatomic, assign) long long version;

@property (nonatomic, retain) NSString* writeDate;

@property (nonatomic, retain) NSString* memberColor;

@property (nonatomic, retain) NSString* state;

@property (nonatomic, retain) NSString* adddate;

@property (nonatomic, retain) NSString* memberOrder;




WCDB_PROPERTY(memberId)
WCDB_PROPERTY(memberName)
WCDB_PROPERTY(userId)
WCDB_PROPERTY(operatorType)
WCDB_PROPERTY(version)
WCDB_PROPERTY(writeDate)
WCDB_PROPERTY(memberColor)
WCDB_PROPERTY(state)
WCDB_PROPERTY(adddate)
WCDB_PROPERTY(memberOrder)


@end
