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
 
 * 固收理财变更转入（对固收理财账户而言，是追加投资）
public static final String FIXED_FIN_PRODUCT_CHANGE_IN_ID = "15";

 * 固收理财变更转出（对固收理财账户而言，是部分赎回）
public static final String FIXED_FIN_PRODUCT_CHANGE_OUT_ID = "16";
 * 固收理财余额转入

public static final String FIXED_FIN_PRODUCT_MONEY_IN_ID = "17";

 * 固收理财余额转出

public static final String FIXED_FIN_PRODUCT_MONEY_OUT_ID = "18";

 * 固收理财结算利息转入

public static final String FIXED_FIN_PRODUCT_INTEREST_IN_ID = "19";

 * 固收理财结算利息转出

public static final String FIXED_FIN_PRODUCT_INTEREST_OUT_ID = "20";

 * 固收理财派发利息流水

public static final String FIXED_FIN_PRODUCT_INTEREST_ID = "21";

 * 固收理财手续费率（部分赎回，结算）

public static final String FIXED_FIN_PRODUCT_COMMISSION_ID = "22";

 */
typedef NS_ENUM(NSUInteger, SSJFixedFinCompoundChargeType) {
    SSJFixedFinCompoundChargeTypeCreate,//新建
    SSJFixedFinCompoundChargeTypeAdd,//追加
    SSJFixedFinCompoundChargeTypeRedemption,//赎回
    SSJFixedFinCompoundChargeTypeBalanceIncrease,//余额转入
    SSJFixedFinCompoundChargeTypeBalanceDecrease,//余额转出
    SSJFixedFinCompoundChargeTypeBalanceInterestIncrease,//利息转入
    SSJFixedFinCompoundChargeTypeBalanceInterestDecrease,//利息转出
    SSJFixedFinCompoundChargeTypeInterest,//固收理财派发利息流水
    SSJFixedFinCompoundChargeTypeCloseOutInterest,//结算利息
    SSJFixedFinCompoundChargeTypeCloseOut//结清
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

/**cid*/
@property (nonatomic, copy) NSString *cid;

@property (nonatomic) SSJFixedFinCompoundChargeType chargeType;

+ (instancetype)modelWithResultSet:(FMResultSet *)resultSet;


@end

NS_ASSUME_NONNULL_END
