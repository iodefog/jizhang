//
//  SSJUserCreditTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJUserCreditTable : NSObject <WCTTableCoding>

@property (nonatomic, retain) NSString* cardId;

@property (nonatomic, assign) double cardQuota;

@property (nonatomic, assign) NSInteger billingDate;

@property (nonatomic, assign) NSInteger repaymentDate;

@property (nonatomic, retain) NSString* userId;

@property (nonatomic, retain) NSString* writeDate;

@property (nonatomic, assign) long long version;

@property (nonatomic, assign) int operatorType;

@property (nonatomic, retain) NSString* remindId;

@property (nonatomic, assign) BOOL billDateSettlement;

@property (nonatomic, assign) SSJAccountType type;


WCDB_PROPERTY(cardId)
WCDB_PROPERTY(cardQuota)
WCDB_PROPERTY(billingDate)
WCDB_PROPERTY(repaymentDate)
WCDB_PROPERTY(userId)
WCDB_PROPERTY(writeDate)
WCDB_PROPERTY(version)
WCDB_PROPERTY(operatorType)
WCDB_PROPERTY(remindId)
WCDB_PROPERTY(billDateSettlement)
WCDB_PROPERTY(type)

@end
