//
//  NSMutableAttributedString+AttributeStr.h
//  Tesssss
//
//  Created by yi cai on 2016/12/30.
//  Copyright © 2016年 gdgsg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (AttributeStr)
/**
 * oldStr :需要转换的字符串
 * targetStr: 需要改变颜色的字符串
 * range: 需要改变文字的字符串的位置(targetStr和range传一个就可以)
 * color: 需要改变的文字颜色
 */
+ (NSMutableAttributedString *)attributeStrWithOldStr:(NSString *)oldStr targetStr:(NSString *)targetStr range:(NSRange)range color:(UIColor *)color;
@end
