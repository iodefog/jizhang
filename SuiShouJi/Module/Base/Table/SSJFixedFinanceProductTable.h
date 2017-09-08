//
//  SSJUserTreeTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/17.
//  retainright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJFixedFinanceProductTable : NSObject <WCTTableCoding>

/**理财产品id*/
@property (nonatomic, retain) NSString *productId;

/**理财产品名称*/
@property (nonatomic, retain) NSString *productName;

/**用户id*/
@property (nonatomic, retain) NSString *userId;

/**提醒id*/
@property (nonatomic, retain) NSString *remindId;

/**资金账户id*/
@property (nonatomic, retain) NSString *thisFundid;

/**转出账户id*/
@property (nonatomic, retain) NSString *targetFundid;

/**结算账户id*/
@property (nonatomic, retain) NSString *etargetFundid;

/**投资金额*/
@property (nonatomic, retain) NSString *money;

/**备注*/
@property (nonatomic, retain) NSString *memo;

/**利率*/
@property (nonatomic, assign) double rate;

/**利率类型（年:2、月:1、日:0)*/
@property (nonatomic, assign) SSJMethodOfRateOrTime rateType;

/**期限*/
@property (nonatomic, assign) double time;

/**期限类型（年:2、月:1、日:0）*/
@property (nonatomic, assign) SSJMethodOfRateOrTime timeType;

/**计息方式（一次性付清:0，每日付息到期还本:1，每月付息到期还本:2）*/
@property (nonatomic, assign) SSJMethodOfInterest interestType;

/**起息日期*/
@property (nonatomic, retain) NSString *startDate;

/**结算日期*/
@property (nonatomic, retain) NSString *endDate;

/**是否结算0 未结算，1，结算*/
@property (nonatomic, assign) NSInteger isEnd;

@property (nonatomic, strong) NSString *writeDate;

@property (nonatomic, assign) long long version;

@property (nonatomic, assign) NSInteger operatorType;

WCDB_PROPERTY(productId)
WCDB_PROPERTY(productName)
WCDB_PROPERTY(userId)
WCDB_PROPERTY(remindId)
WCDB_PROPERTY(thisFundid)
WCDB_PROPERTY(targetFundid)
WCDB_PROPERTY(etargetFundid)
WCDB_PROPERTY(money)
WCDB_PROPERTY(memo)
WCDB_PROPERTY(rate)
WCDB_PROPERTY(rateType)
WCDB_PROPERTY(time)
WCDB_PROPERTY(timeType)
WCDB_PROPERTY(interestType)
WCDB_PROPERTY(startDate)
WCDB_PROPERTY(endDate)
WCDB_PROPERTY(isEnd)
WCDB_PROPERTY(writeDate)
WCDB_PROPERTY(version)
WCDB_PROPERTY(operatorType)

@end
