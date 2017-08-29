//
//  SSJUserChargeMergeTable.h
//  SuiShouJi
//
//  Created by ricky on 2017/7/14.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <WCDB/WCDB.h>

@interface SSJUserChargeTable : NSObject <WCTTableCoding>


/**
 流水id
 */
@property (nonatomic, retain) NSString* chargeId;


/**
 用户id
 */
@property (nonatomic, retain) NSString* userId;


/**
 流水金额
 */
@property (nonatomic, retain) NSString* money;


/**
 记账类型id
 */
@property (nonatomic, retain) NSString* billId;


/**
 记账账户id
 */
@property (nonatomic, retain) NSString* fundId;


/**
 流水添加时间
 */
@property (nonatomic, retain) NSString* addDate;

@property (nonatomic, retain) NSString* oldMoney;

@property (nonatomic, retain) NSString* balance;


/**
 记账日期
 */
@property (nonatomic, retain) NSString* billDate;


/**
 记账备注
 */
@property (nonatomic, retain) NSString* memo;


/**
 记账图片
 */
@property (nonatomic, retain) NSString* imgUrl;


/**
 记账缩略图
 */
@property (nonatomic, retain) NSString* thumbUrl;


/**
 版本号
 */
@property (nonatomic, assign) long long version;


/**
 修改时间
 */
@property (nonatomic, retain) NSString* writeDate;


/**
 操作类型
 */
@property (nonatomic, assign) int operatorType;


/**
 账本id
 */
@property (nonatomic, retain) NSString* booksId;


/**
 客户端添加时间
 */
@property (nonatomic, retain) NSString* clintAddDate;


/**
 记账类型
 */
@property (nonatomic, assign) SSJChargeIdType chargeType;


/**
 记账类型对应的id
 */
@property (nonatomic, retain) NSString* cid;


/**
 记账具体时分
 */
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
