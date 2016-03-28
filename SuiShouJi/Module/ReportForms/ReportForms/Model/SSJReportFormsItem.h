//
//  SSJReportFormsItem.h
//  SuiShouJi
//
//  Created by old lang on 15/12/29.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

typedef NS_ENUM(NSInteger, SSJReportFormsType) {
    SSJReportFormsTypeIncome  = 0, // 收入
    SSJReportFormsTypePayment = 1, // 支出
};

@interface SSJReportFormsItem : SSJBaseItem

// 比例
@property (nonatomic) double scale;

// 金额
@property (nonatomic) double money;

// 收支类型
@property (nonatomic) SSJReportFormsType type;

// 图片名称
@property (nonatomic, copy) NSString *imageName;

// 收支类型名称
@property (nonatomic, copy) NSString *incomeOrPayName;

// 颜色值
@property (nonatomic, copy) NSString *colorValue;

// 收支类型ID
@property (nonatomic, copy) NSString *ID;

@end
