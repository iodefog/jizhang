//
//  SSJFundInfoTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJFundInfoTable : NSObject <WCTTableCoding>

@property (nonatomic, retain) NSString* fundId;

@property (nonatomic, retain) NSString* fundName;

@property (nonatomic, retain) NSString* fundIcon;

@property (nonatomic, retain) NSString* fundParent;

@property (nonatomic, retain) NSString* fundColor;

@property (nonatomic, retain) NSString* writeDate;

@property (nonatomic, assign) int operatorType;

@property (nonatomic, assign) long long version;

@property (nonatomic, retain) NSString* memo;

@property (nonatomic, retain) NSString* userId;

@property (nonatomic, retain) NSString* addDate;

@property (nonatomic, assign) int fundOrder;

@property (nonatomic, assign) int display;

@property (nonatomic, retain) NSString* startColor;

@property (nonatomic, retain) NSString* endColor;

@property (nonatomic, assign) int fundType;

WCDB_PROPERTY(fundId)
WCDB_PROPERTY(fundName)
WCDB_PROPERTY(fundIcon)
WCDB_PROPERTY(fundParent)
WCDB_PROPERTY(fundColor)
WCDB_PROPERTY(writeDate)
WCDB_PROPERTY(operatorType)
WCDB_PROPERTY(version)
WCDB_PROPERTY(memo)
WCDB_PROPERTY(userId)
WCDB_PROPERTY(addDate)
WCDB_PROPERTY(fundOrder)
WCDB_PROPERTY(display)
WCDB_PROPERTY(startColor)
WCDB_PROPERTY(endColor)
WCDB_PROPERTY(fundType)


@end
