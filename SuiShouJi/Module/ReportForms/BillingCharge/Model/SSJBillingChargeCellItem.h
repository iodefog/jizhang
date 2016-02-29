//
//  SSJBillingChargeCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@interface SSJBillingChargeCellItem : SSJBaseItem

// 图片名称
@property (nonatomic, copy) NSString *imageName;

// 收支类型名称
@property (nonatomic, copy) NSString *typeName;

// 收支金额
@property (nonatomic, copy) NSString *money;

// 颜色值
@property (nonatomic, copy) NSString *colorValue;

// 流水id
@property (nonatomic, copy) NSString *ID;

// 流水类型(1是支出,0是收入)
@property (nonatomic) BOOL incomeOrExpence;

// 流水时间
@property (nonatomic,strong) NSString *billDate;

// 资金帐户编号
@property (nonatomic,strong) NSString *fundId;

//记账编辑时间
@property (nonatomic,strong) NSString *editeDate;

//记账类型
@property (nonatomic,strong) NSString *billId;

//流水备注
@property (nonatomic,strong) NSString *chargeMemo;


//记账图片(大图)
@property (nonatomic,strong) NSString *chargeImage;

//记账图片(缩略图)
@property (nonatomic,strong) NSString *chargeThumbImage;

//循环记账配置ID
@property (nonatomic,strong) NSString *configId;

//循环记账类型
@property (nonatomic) NSInteger chargeCircleType;

@end
