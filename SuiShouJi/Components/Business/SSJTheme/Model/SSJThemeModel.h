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
@property (nonatomic) double size;

// 预览图片url
@property (nonatomic, copy) NSString *previewUrlStr;

// 所有背景透明度
@property (nonatomic) CGFloat backgroundAlpha;

// 主要颜色
@property (nonatomic, copy) NSString *mainColor;

// 次要颜色
@property (nonatomic, copy) NSString *secondaryColor;

// 强调颜色
@property (nonatomic, copy) NSString *marcatoColor;

// 边框线颜色
@property (nonatomic, copy) NSString *borderColor;

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

// cell分割线透明度
@property (nonatomic) CGFloat cellSeparatorAlpha;

// cell分割线颜色
@property (nonatomic, copy) NSString *cellSeparatorColor;

// cell右侧箭头颜色
@property (nonatomic, copy) NSString *cellIndicatorColor;

// 更多首页顶部主要标题颜色（用户名、云同步、签到）
@property (nonatomic, copy) NSString *moreHomeTitleColor;

// 更多首页顶部次要标题颜色（等级）
@property (nonatomic, copy) NSString *moreHomeSubtitleColor;

@end
