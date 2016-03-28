//
//  SSJColorAddition.h
//  SuiShouJi
//
//  Created by old lang on 15/10/26.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (SSJCategory)

/**
 *  十六进制颜色转换
 *
 *  @return (UIColor *)
 */
+ (UIColor *)ssj_colorWithHex:(NSString *)hexColor;

@end