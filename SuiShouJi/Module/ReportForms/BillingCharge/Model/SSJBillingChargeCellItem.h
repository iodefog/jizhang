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

@end
