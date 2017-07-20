//
//  SSJWishChargeItem.h
//  SuiShouJi
//
//  Created by yi cai on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

@interface SSJWishChargeItem : SSJBaseCellItem
/**<#注释#>*/
@property (nonatomic, copy) NSString *amountStr;
/**<#注释#>*/
@property (nonatomic, strong) NSDate *remindDate;

// 月末是否开启提醒(0为关闭,1为开启)
@property(nonatomic) BOOL remindAtTheEndOfMonth;
@end
