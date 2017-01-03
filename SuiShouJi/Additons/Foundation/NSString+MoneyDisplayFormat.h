//
//  NSString+MoneyDisplayFormat.h
//  MoneyMore
//
//  Created by cdd on 15/10/12.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MoneyDisplayFormat)

/**
 *  金额数字超过三位，每隔3位加逗号格式化
 *
 *  @return (NSString *)格式化后的金额字符串
 */
-(NSString *)ssj_moneyDisplayFormat;

-(NSString *)ssj_moneyDecimalDisplayWithDigits:(int)digits;


/**
 * oldStr :需要转换的字符串
 * targetStr: 需要改变颜色的字符串
 * range: 需要改变文字的字符串的位置(targetStr和range传一个就可以)
 * color: 需要改变的文字颜色
 */
- (NSMutableAttributedString *)attributeStrWithTargetStr:(NSString *)targetStr range:(NSRange)range color:(UIColor *)color;

- (NSMutableAttributedString *)attributeStrWithTargetStr:(NSString *)targetStr range:(NSRange)range attributedDictionary:(NSDictionary *)attriDic;
@end
