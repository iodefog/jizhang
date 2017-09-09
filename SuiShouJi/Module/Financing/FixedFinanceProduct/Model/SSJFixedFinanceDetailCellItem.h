//
//  SSJFixedFinanceDetailCellId.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"
@class SSJFixedFinanceProductChargeItem;
@class SSJFixedFinanceProductItem;

@interface SSJFixedFinanceDetailCellItem : SSJBaseCellItem
@property (nonatomic, copy) NSString *titmeStr;

@property (nonatomic, copy) NSString *iconStr;

@property (nonatomic, copy) NSString *nameStr;

@property (nonatomic, copy) NSString *subStr;

@property (nonatomic, copy) NSString *amountStr;

@property (nonatomic, copy) NSAttributedString *bottomTitle;

/**是否显示时间*/
@property (nonatomic, assign) BOOL isShowTime;

+ (instancetype)cellItemWithChargeModel:(SSJFixedFinanceProductChargeItem *)model productItem:(SSJFixedFinanceProductItem *)productItem;

@end
