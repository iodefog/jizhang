//
//  SSJThemeUtil.h
//  SuiShouJi
//
//  Created by old lang on 16/7/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SSJ_CURRENT_THEME [SSJThemeSetting currentThemeModel]

// 主要颜色
#define SSJ_MAIN_COLOR [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]

// 强调颜色
#define SSJ_MARCATO_COLOR [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]

// 次要颜色
#define SSJ_SECONDARY_COLOR [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]

//  切换主题通知
extern NSString *const SSJThemeDidChangeNotification;

extern NSString *const SSJDefaultThemeID;

void SSJSetCurrentThemeID(NSString *ID);

NSString *SSJCurrentThemeID(void);
