//
//  SSJFontAddition.h
//  MoneyMore
//
//  Created by old lang on 15-5-21.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

//  根据屏幕宽度比例返回响应字体大小
CGFloat SSJCompatibleFontSize(CGFloat fontSize);

@interface UIFont (SSJCategory)

//  根据屏幕宽度比例返回响应的字体
+ (UIFont *)ssj_compatibleSystemFontOfSize:(CGFloat)fontSize;

//  根据屏幕宽度比例返回响应的粗体
+ (UIFont *)ssj_compatibleBoldSystemFontOfSize:(CGFloat)fontSize;

@end
