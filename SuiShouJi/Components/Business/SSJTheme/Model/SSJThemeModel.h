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

// 主题的etag值
@property (nonatomic, copy) NSString *etag;

// 主题的版本
@property (nonatomic, copy) NSString *version;

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

// 是否需要高斯模糊
@property (nonatomic) BOOL needBlurOrNot;

// 主要背景颜色
@property (nonatomic, copy) NSString *mainBackGroundColor;

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

// tabbar背景图片
@property (nonatomic, copy) NSString *tabBarBackgroundImage;

// cell分割线透明度
@property (nonatomic) CGFloat cellSeparatorAlpha;

// cell分割线颜色
@property (nonatomic, copy) NSString *cellSeparatorColor;

// 键盘分割线颜色
@property (nonatomic, copy) NSString *keyboardSeparatorColor;

// cell右侧箭头颜色
@property (nonatomic, copy) NSString *cellIndicatorColor;

// cell点击效果
@property (nonatomic) UITableViewCellSelectionStyle cellSelectionStyle;

// 状态栏
@property (nonatomic) UIStatusBarStyle statusBarStyle;

// 更多首页顶部主要标题颜色（用户名、云同步、签到）
@property (nonatomic, copy) NSString *moreHomeTitleColor;

// 更多首页顶部次要标题颜色（等级）
@property (nonatomic, copy) NSString *moreHomeSubtitleColor;

// 记一笔首页记一笔按钮边框色
@property (nonatomic, copy) NSString *recordHomeBorderColor;

// 记一笔首页记一笔按钮背景色
@property (nonatomic, copy) NSString *recordHomeButtonBackgroundColor;

// 记一笔首页日历颜色
@property (nonatomic, copy) NSString *recordHomeCalendarColor;

// 记一笔首页收支类别图标背景色
@property (nonatomic, copy) NSString *recordHomeCategoryBackgroundColor;

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

// 报表曲线图收入填充色（曲线、文字、报表结余）
@property (nonatomic, copy) NSString *reportFormsCurveIncomeColor;

// 报表曲线图支出填充色（曲线、文字、报表结余）
@property (nonatomic, copy) NSString *reportFormsCurvePaymentColor;

// 报表曲线图收入填充色
@property (nonatomic, copy) NSString *reportFormsCurveIncomeFillColor;

// 报表曲线图支出填充色
@property (nonatomic, copy) NSString *reportFormsCurvePaymentFillColor;

// 记一笔输入框透明度
@property (nonatomic) CGFloat recordMakingInputViewAlpha;

// 首页搜索按钮选中颜色
@property (nonatomic, copy) NSString *bookKeepingHomeMutiButtonSelectColor;

// 首页搜索按钮普通颜色
@property (nonatomic, copy) NSString *bookKeepingHomeMutiButtonNormalColor;

// 搜索页面结果头的背景色
@property (nonatomic, copy) NSString *searchResultHeaderBackgroundColor;

// 总账本的背景颜色
@property (nonatomic, copy) NSString *summaryBooksHeaderColor;

// 总账本的背景颜色透明度
@property (nonatomic) CGFloat summaryBooksHeaderAlpha;

// 资金详情背景颜色
@property (nonatomic, copy) NSString *financingDetailHeaderColor;

// 资金详情背景颜色透明度
@property (nonatomic) CGFloat financingDetailHeaderAlpha;

// 资金详情主要文字颜色
@property (nonatomic, copy) NSString *financingDetailMainColor;

// 资金详情主要文字透明度
@property (nonatomic) CGFloat financingDetailMainAlpha;

// 资金详情次要文字颜色
@property (nonatomic, copy) NSString *financingDetailSecondaryColor;

// 资金详情次要文字透明度
@property (nonatomic) CGFloat financingDetailSecondaryAlpha;

// 通屏按钮的背景色
@property (nonatomic, copy) NSString *throughScreenButtonBackGroudColor;

// 通屏按钮的透明度
@property (nonatomic) CGFloat throughScreenButtonAlpha;

// 验证码底色
@property (nonatomic, copy) NSString *authCodeGroundColor;

//-----和自定义主题有关的-----

// 自定义主题的背景图
@property (nonatomic, copy) NSString *customThemeBackImage;

//// 是否是自定义背景图
//@property (nonatomic) BOOL isCustomImage;

// 是暗色还是亮色
@property (nonatomic) BOOL darkOrLight;

@end
