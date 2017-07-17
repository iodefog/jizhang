//
//  SSJUserChargeMergeTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/14.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJUserChargeMergeTable : NSObject <WCTTableCoding>

@property (nonatomic, retain) NSString* chargeId;

@property (nonatomic, retain) NSString* userId;

@property (nonatomic, retain) NSString* money;

@property (nonatomic, retain) NSString* billId;

@property (nonatomic, retain) NSString* fundId;

@property (nonatomic, retain) NSString* addDate;

@property (nonatomic, retain) NSString* oldMoney;

@property (nonatomic, retain) NSString* balance;

@property (nonatomic, retain) NSString* billDate;

@property (nonatomic, retain) NSString* memo;

@property (nonatomic, retain) NSString* imgUrl;

@property (nonatomic, retain) NSString* thumbUrl;

@property (nonatomic, assign) long long version;

@property (nonatomic, retain) NSString* writeDate;

@property (nonatomic, assign) int operatorType;

@property (nonatomic, retain) NSString* booksId;

@property (nonatomic, retain) NSString* clintAddDate;

@property (nonatomic, assign) int chargeType;

@property (nonatomic, retain) NSString* cid;

@property (nonatomic, retain) NSString* detailDate;


WCDB_PROPERTY(chargeId)
WCDB_PROPERTY(userId)
WCDB_PROPERTY(money)
WCDB_PROPERTY(billId)
WCDB_PROPERTY(fundId)
WCDB_PROPERTY(addDate)
WCDB_PROPERTY(oldMoney)
WCDB_PROPERTY(balance)
WCDB_PROPERTY(billDate)
WCDB_PROPERTY(memo)
WCDB_PROPERTY(imgUrl)
WCDB_PROPERTY(thumbUrl)
WCDB_PROPERTY(version)
WCDB_PROPERTY(writeDate)
WCDB_PROPERTY(operatorType)
WCDB_PROPERTY(booksId)
WCDB_PROPERTY(clintAddDate)
WCDB_PROPERTY(chargeType)
WCDB_PROPERTY(cid)
WCDB_PROPERTY(detailDate)

@end
