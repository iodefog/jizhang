//
//  SSJChargePeriodConfigTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJChargePeriodConfigTable : NSObject <WCTTableCoding>


@property (nonatomic, retain) NSString* configId;

@property (nonatomic, retain) NSString* userId;

@property (nonatomic, retain) NSString* billId;

@property (nonatomic, retain) NSString* fundId;

@property (nonatomic, assign) int type;

@property (nonatomic, retain) NSString* money;

@property (nonatomic, retain) NSString* imgUrl;

@property (nonatomic, retain) NSString* memo;

@property (nonatomic, retain) NSString* billDate;

@property (nonatomic, assign) int state;

@property (nonatomic, assign) long long version;

@property (nonatomic, retain) NSString* writeDate;

@property (nonatomic, assign) int operatorType;

@property (nonatomic, retain) NSString* booksId;

@property (nonatomic, retain) NSString* memberIds;

@property (nonatomic, retain) NSString* billDateEnd;


WCDB_PROPERTY(configId)
WCDB_PROPERTY(userId)
WCDB_PROPERTY(billId)
WCDB_PROPERTY(fundId)
WCDB_PROPERTY(type)
WCDB_PROPERTY(money)
WCDB_PROPERTY(imgUrl)
WCDB_PROPERTY(memo)
WCDB_PROPERTY(billDate)
WCDB_PROPERTY(state)
WCDB_PROPERTY(version)
WCDB_PROPERTY(writeDate)
WCDB_PROPERTY(operatorType)
WCDB_PROPERTY(booksId)
WCDB_PROPERTY(memberIds)
WCDB_PROPERTY(billDateEnd)

@end
