//
//  SSJThemeModel.h
//  SuiShouJi
//
//  Created by old lang on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJThemeModel : NSObject <NSCoding>

// 主题ID
@property (nonatomic, copy) NSString *ID;

// 主题名称
@property (nonatomic, copy) NSString *name;

// 预览图片url
@property (nonatomic, copy) NSString *previewUrlStr;

// 主题包大小
@property (nonatomic) double size;

// 字体主色
@property (nonatomic, copy) NSString *mainTitleColor;

// tabbar非选中状态字体颜色
@property (nonatomic, copy) NSString *tabBarTitleColor;

// tabbar选中状态字体颜色
@property (nonatomic, copy) NSString *tabBarSelectedTitleColor;

// 导航栏标题透明度
@property (nonatomic) CGFloat naviBarTitleAlpha;

// 导航栏tint color
@property (nonatomic, copy) NSString *naviBarTintColor;

// 导航栏背景色
@property (nonatomic, copy) NSString *naviBarBackgroundColor;

// cell分割线颜色
@property (nonatomic, copy) NSString *cellSeparatorColor;

// cell右侧箭头颜色
@property (nonatomic, copy) NSString *cellIndicatorColor;

// 记账首页记一笔日历文字颜色
@property (nonatomic, copy) NSString *recordHomeCalendarTitleColor;

// 记账首页记一笔按钮圆形边框色
@property (nonatomic, copy) NSString *recordHomeCircleBorderColor;

// 记账首页预算label的文字透明度
@property (nonatomic) CGFloat recordHomeBudgetLabelTitleAlpha;

// 记账首页预算label的边框透明度
@property (nonatomic) CGFloat recordHomeBudgetLabelBorderAlpha;

// 记账首页收入、支出标题透明度
@property (nonatomic) CGFloat recordHomeIncomeAndPayTitleAlpha;

// 记账首页收入、支出金额透明度
@property (nonatomic) CGFloat recordHomeIncomeAndPayValueAlpha;

// 记账首页列表每日日期字体透明度
@property (nonatomic) CGFloat recordHomeListDateAlpha;

// 记账首页列表每日总金额字体透明度
@property (nonatomic) CGFloat recordHomeListDateAmountAlpha;

// 记账首页列表流水字体透明度
@property (nonatomic) CGFloat recordHomeListChargeTitleAlpha;

// 记账首页列表流水备注字体透明度
@property (nonatomic) CGFloat recordHomeListChargeMemoAlpha;

@end
