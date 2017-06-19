//
//  SSJFundingListDayItem.h
//  SuiShouJi
//
//  Created by ricky on 16/3/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJBaseCellItem.h"

@interface SSJFundingListDayItem : SSJBaseCellItem

//当天的日期
@property(nonatomic, strong) NSString *date;

//当天的收入
@property(nonatomic) double income;

//当天的支出
@property(nonatomic) double expenture;

@end
