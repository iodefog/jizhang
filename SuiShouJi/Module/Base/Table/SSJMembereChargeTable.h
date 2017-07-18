//
//  SSJMembereChargeTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJMembereChargeTable : NSObject <WCTTableCoding>

@property (nonatomic, retain) NSString* chargeId;

@property (nonatomic, retain) NSString* memberId;

@property (nonatomic, retain) NSString* money;

@property (nonatomic, assign) long long version;

@property (nonatomic, retain) NSString* writeDate;

@property (nonatomic, assign) int operatorType;

WCDB_PROPERTY(chargeId)
WCDB_PROPERTY(memberId)
WCDB_PROPERTY(money)
WCDB_PROPERTY(version)
WCDB_PROPERTY(writeDate)
WCDB_PROPERTY(operatorType)

@end
