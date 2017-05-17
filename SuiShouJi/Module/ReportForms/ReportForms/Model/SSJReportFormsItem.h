//
//  SSJReportFormsItem.h
//  SuiShouJi
//
//  Created by old lang on 15/12/29.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"

typedef NS_ENUM(NSInteger, SSJReportFormsType) {
    SSJReportFormsTypeIncome  = 0, // 收入
    SSJReportFormsTypePayment = 1, // 支出
};

@interface SSJReportFormsItem : SSJBaseCellItem

// 比例
@property (nonatomic) double scale;

// 金额
@property (nonatomic) double money;

// 收支类型
@property (nonatomic) SSJReportFormsType type;

// 图片名称
@property (nonatomic, copy) NSString *imageName;

// 收支类型\成员名称
@property (nonatomic, copy) NSString *name;

// 颜色值
@property (nonatomic, copy) NSString *colorValue;

// 收支类型ID或者成员id
@property (nonatomic, copy) NSString *ID;

// 文本颜色
//@property (nonatomic, copy) NSString *titleColor;

// 是否成员（不是成员就是分类）
@property (nonatomic) BOOL isMember;

// 是否隐藏比例
@property (nonatomic) BOOL percentHiden;

@end
