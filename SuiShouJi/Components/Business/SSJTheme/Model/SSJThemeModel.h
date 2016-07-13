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

// 主题包大小
@property (nonatomic, copy) NSString *size;

// 预览图片url
@property (nonatomic, copy) NSString *previewUrlStr;

// 缩略图url
@property(nonatomic, copy) NSString *thumbUrlStr;

// 预览图片数组
@property(nonatomic, copy) NSArray *previewUrlArr;

// 主题描述
@property(nonatomic, copy) NSString *desc;

// 所有背景透明度
@property (nonatomic) CGFloat backgroundAlpha;

// 主要颜色
@property (nonatomic, copy) NSString *mainColor;

// 次要颜色
@property (nonatomic, copy) NSString *secondaryColor;

// 强调颜色
@property (nonatomic, copy) NSString *marcatoColor;

// 主要填充颜色
@property (nonatomic, copy) NSString *mainFillColor;

// 次要填充颜色
@property (nonatomic, copy) NSString *secondaryFillColor;

// 边框线颜色
@property (nonatomic, copy) NSString *borderColor;

// 按钮颜色
@property (nonatomic, copy) NSString *buttonColor;

// 导航栏标题透明度
@property (nonatomic, copy) NSString *naviBarTitleColor;

// 导航栏tint color
@property (nonatomic, copy) NSString *naviBarTintColor;

// 导航栏背景色
@property (nonatomic, copy) NSString *naviBarBackgroundColor;

// tabbar非选中状态字体颜色
@property (nonatomic, copy) NSString *tabBarTitleColor;

// tabbar选中状态字体颜色
@property (nonatomic, copy) NSString *tabBarSelectedTitleColor;

// tabbar背景色
@property (nonatomic, copy) NSString *tabBarBackgroundColor;

// tabbar边框线透明度
@property (nonatomic) CGFloat tabBarShadowImageAlpha;

// cell分割线透明度
@property (nonatomic) CGFloat cellSeparatorAlpha;

// cell分割线颜色
@property (nonatomic, copy) NSString *cellSeparatorColor;

// cell右侧箭头颜色
@property (nonatomic, copy) NSString *cellIndicatorColor;

// cell点击效果
@property (nonatomic) UITableViewCellSelectionStyle cellSelectionStyle;

// 更多首页顶部主要标题颜色（用户名、云同步、签到）
@property (nonatomic, copy) NSString *moreHomeTitleColor;

// 更多首页顶部次要标题颜色（等级）
@property (nonatomic, copy) NSString *moreHomeSubtitleColor;

// 记一笔首页记一笔按钮边框色
@property (nonatomic, copy) NSString *recordHomeBorderColor;

// 记一笔首页日历颜色
@property (nonatomic, copy) NSString *recordHomeCalendarColor;

// 登录页主要色
@property (nonatomic, copy) NSString *loginMainColor;

// 登录页次要色
@property (nonatomic, copy) NSString *loginSecondaryColor;

// 登录按钮标题颜色
@property (nonatomic, copy) NSString *loginButtonTitleColor;

// 手势密码普通状态颜色
@property (nonatomic, copy) NSString *motionPasswordNormalColor;

// 手势密码高亮状态颜色
@property (nonatomic, copy) NSString *motionPasswordHighlightedColor;

// 手势密码错误状态颜色
@property (nonatomic, copy) NSString *motionPasswordErrorColor;

// 报表曲线图收入填充色
@property (nonatomic, copy) NSString *reportFormsCurveIncomeFillColor;

// 报表曲线图支出填充色
@property (nonatomic, copy) NSString *reportFormsCurvePaymentFillColor;

// 记一笔输入框透明度
@property (nonatomic) CGFloat recordMakingInputViewAlpha;

@end
