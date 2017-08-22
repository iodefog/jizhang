//
//  SSJFixedFinanceProductItem.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

NS_ASSUME_NONNULL_BEGIN
@class FMResultSet;
/**
 利率或期限类型：固定收益理财
 SSJMethodOfRateOrTimeDay:    日
 SSJMethodOfRateOrTimeMonth:    月
 SSJMethodOfRateOrTimeYear:  年
 */
typedef NS_ENUM(NSInteger, SSJMethodOfRateOrTime) {
    SSJMethodOfRateOrTimeDay = 0,
    SSJMethodOfRateOrTimeMonth,
    SSJMethodOfRateOrTimeYear
};

@interface SSJFixedFinanceProductItem : SSJBaseCellItem<NSCopying>

/**理财产品id*/
@property (nonatomic, copy) NSString *productid;

/**理财产品名称*/
@property (nonatomic, copy) NSString *productName;

/**用户id*/
@property (nonatomic, copy) NSString *userid;

/**提醒id*/
@property (nonatomic, copy, nullable) NSString *remindid;

/**理财账户id*/
@property (nonatomic, copy) NSString *thisfundid;

/**转出账户id*/
@property (nonatomic, copy) NSString *targetfundid;

/**结算账户id*/
@property (nonatomic, copy, nullable) NSString *etargetfundid;

/**投资金额*/
@property (nonatomic, copy) NSString *money;

/**备注*/
@property (nonatomic, copy, nullable) NSString *memo;

/**利率*/
@property (nonatomic, assign) float rate;

/**利率类型（年:2、月:1、日:0)*/
@property (nonatomic, assign) SSJMethodOfRateOrTime ratetype;

/**期限*/
@property (nonatomic, assign) float time;

/**期限类型（年:2、月:1、日:0）*/
@property (nonatomic, assign) SSJMethodOfRateOrTime timetype;

/**计息方式（一次性付清:0，每日付息到期还本:1，每月付息到期还本:2）*/
@property (nonatomic, assign) SSJMethodOfInterest interesttype;

/**起息日期*/
@property (nonatomic, copy) NSString *startdate;

/**结算日期*/
@property (nonatomic, copy, nullable) NSString *enddate;

/**是否结算*/
@property (nonatomic, assign) NSInteger isend;

+ (instancetype)modelWithResultSet:(FMResultSet *)resultSet;

+ (NSArray *)keyArr;
///**更新时间*/
//@property (nonatomic, copy) NSString *writedate;
//
///**版本号*/
//@property (nonatomic, assign) NSInteger version;

///**操作类型*/
//@property (nonatomic, assign) SSJOperatorType operatortype;
@end

NS_ASSUME_NONNULL_END
