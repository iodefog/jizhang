//
//  SSJWishChargeItem.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@interface SSJWishChargeItem : SSJBaseCellItem<NSCopying>

@property (nonatomic, copy) NSString *chargeId;

@property (nonatomic, copy) NSString *money;

@property (nonatomic, copy) NSString *wishId;

@property (nonatomic, copy) NSString *iversion;

@property (nonatomic, copy) NSString *memo;

@property (nonatomic, copy) NSString *cuserId;

//0 转入; 1 转出'
@property (nonatomic, assign) SSJWishChargeBillType itype;

@property (nonatomic, copy) NSString *cbillDate;

@property (nonatomic, strong) NSDate *remindDate;

@property (nonatomic, copy) NSString *remindDateStr;

/**心愿状态*/
@property (nonatomic, assign) SSJWishChargeType wishChargeType;

//// 月末是否开启提醒(0为关闭,1为开启)
//@property(nonatomic) BOOL remindAtTheEndOfMonth;
@end
