//
//  SSJUserBillTypeTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJUserBillTypeTable : NSObject <WCTTableCoding>

@property (nonatomic, retain) NSString* billId;

@property (nonatomic, retain) NSString* userId;

@property (nonatomic, retain) NSString* booksId;

@property (nonatomic, retain) NSString* billType;

@property (nonatomic, retain) NSString* billName;

@property (nonatomic, retain) NSString* billColor;

@property (nonatomic, retain) NSString* billIcon;

@property (nonatomic, assign) int billOrder;

@property (nonatomic, retain) NSString* addDate;

@property (nonatomic, retain) NSString* writeDate;

@property (nonatomic, assign) int operatorType;

@property (nonatomic, assign) long long version;

WCDB_PROPERTY(billId)
WCDB_PROPERTY(userId)
WCDB_PROPERTY(booksId)
WCDB_PROPERTY(billType)
WCDB_PROPERTY(billName)
WCDB_PROPERTY(billColor)
WCDB_PROPERTY(billIcon)
WCDB_PROPERTY(billOrder)
WCDB_PROPERTY(addDate)
WCDB_PROPERTY(writeDate)
WCDB_PROPERTY(operatorType)
WCDB_PROPERTY(version)

@end
