//
//  SSJFixedFinanceProductChargeItem.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/17.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"
@class FMResultSet;
NS_ASSUME_NONNULL_BEGIN



@interface SSJFixedFinanceProductChargeItem : SSJBaseCellItem<NSCopying>
/**流水id*/
@property (nonatomic, copy) NSString *chargeId;

/**资金账户id*/
@property (nonatomic, copy, nullable) NSString *fundId;

/**金额*/
@property (nonatomic) double money;

/**变化前的余额*/
@property (nonatomic) double oldMoney;

/**类别id*/
@property (nonatomic, copy) NSString *billId;

@property (nonatomic, copy) NSString *userId;

/**账单备注*/
@property (nonatomic, copy, nullable) NSString *memo;

/**账单图片地址*/
@property (nonatomic, copy, nullable) NSString *icon;

/**账单缩略图片地址*/
@property (nonatomic, copy, nullable) NSString *thumIcon;

/**账单日期*/
@property (nonatomic, copy) NSDate *billDate;

@property (nonatomic, copy) NSDate *writeDate;

/**cid*/
@property (nonatomic, copy) NSString *cid;

@property (nonatomic) SSJFixedFinCompoundChargeType chargeType;

/**是否显示时间*/
@property (nonatomic, assign) BOOL isHiddenTime;

+ (instancetype)modelWithResultSet:(FMResultSet *)resultSet;


@end

NS_ASSUME_NONNULL_END
