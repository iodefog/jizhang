//
//  SSJFundingDetailListItem.h
//  SuiShouJi
//
//  Created by ricky on 16/3/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJBaseCellItem.h"

@interface SSJFundingDetailListItem : SSJBaseCellItem

//年和月
@property(nonatomic, strong) NSString *date;

//当月支出
@property (nonatomic) double income;

//当月收入
@property(nonatomic) double expenture;

//当月流水
@property(nonatomic, strong) NSMutableArray *chargeArray;

//此行是否展开
@property(nonatomic) BOOL isExpand;

@end
