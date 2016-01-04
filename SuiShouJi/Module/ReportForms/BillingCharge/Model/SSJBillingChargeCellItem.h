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

@end
