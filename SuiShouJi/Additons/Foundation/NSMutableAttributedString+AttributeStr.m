//
//  NSMutableAttributedString+AttributeStr.m
//  Tesssss
//
//  Created by yi cai on 2016/12/30.
//  Copyright © 2016年 gdgsg. All rights reserved.
//

#import "NSMutableAttributedString+AttributeStr.h"
#import <UIKit/UIKit.h>
@implementation NSMutableAttributedString (AttributeStr)
+ (NSMutableAttributedString *)attributeStrWithOldStr:(NSString *)oldStr targetStr:(NSString *)targetStr range:(NSRange)range color:(UIColor *)color
{
    if (oldStr.length < 1) return nil;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:oldStr];
    if (targetStr.length < 1 && range.length < 1) return attStr;
    if (!color) return attStr;
     if(range.length > 0){
        [attStr addAttribute:NSForegroundColorAttributeName value:color range:range];
     }else if (targetStr.length > 0) {
         NSRange targetRange = [oldStr rangeOfString:targetStr];
         if (targetRange.length < 1) return attStr;
         [attStr addAttribute:NSForegroundColorAttributeName value:color range:targetRange];
     }
    return attStr;
}
@end
