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

/**
 借贷变更流水类型
 
 - SSJFixedFinCompoundChargeTypeCreate: 创建产生的流水
 - SSJFixedFinCompoundChargeTypeBalanceChange: 余额变更产生的流水
 - SSJFixedFinCompoundChargeTypeRedemption: 赎回产生的流水
 - SSJFixedFinCompoundChargeTypeAdd: 追加产生的流水
 - SSJFixedFinCompoundChargeTypeCloseOut: 结清产生的流水
 - SSJFixedFinCompoundChargeTypeInterest: 还款/收款、结清产生的利息流水
 
 */
typedef NS_ENUM(NSUInteger, SSJFixedFinCompoundChargeType) {
    SSJFixedFinCompoundChargeTypeCreate,//新建
    SSJFixedFinCompoundChargeTypeBalanceIncrease,//转入
    SSJFixedFinCompoundChargeTypeBalanceDecrease,//转出
    SSJFixedFinCompoundChargeTypeRedemption,//赎回
    SSJFixedFinCompoundChargeTypeAdd,//追加
    SSJFixedFinCompoundChargeTypeCloseOut,//结清
    SSJFixedFinCompoundChargeTypeInterest//利息
};

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

@property (nonatomic) SSJFixedFinCompoundChargeType chargeType;

+ (instancetype)modelWithResultSet:(FMResultSet *)resultSet;


@end

NS_ASSUME_NONNULL_END
