//
//  NSString+MoneyDisplayFormat.m
//  MoneyMore
//
//  Created by cdd on 15/10/12.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "NSString+MoneyDisplayFormat.h"

@implementation NSString (MoneyDisplayFormat)

-(NSString *)ssj_moneyDisplayFormat{
    if (self!=nil && self.length>0) {
        if ([self doubleValue]>=1000) {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
//            numberFormatter.locale = [NSLocale currentLocale];
            numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
            numberFormatter.usesGroupingSeparator = YES;
            NSNumber *number = [numberFormatter numberFromString:self];
            return [numberFormatter stringFromNumber:number];
        }
    }
    return self;
}

-(NSString *)ssj_moneyDecimalDisplayWithDigits:(int)digits{
    NSMutableString *result;
    if (self!=nil && self.length>0) {
        NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler
                                           decimalNumberHandlerWithRoundingMode:NSRoundBankers
                                           scale:2
                                           raiseOnExactness:NO
                                           raiseOnOverflow:NO
                                           raiseOnUnderflow:NO
                                           raiseOnDivideByZero:YES];
        NSDecimalNumber *decimalNum = [NSDecimalNumber decimalNumberWithString:self];
        decimalNum = [decimalNum decimalNumberByRoundingAccordingToBehavior:roundUp];
        result = [NSMutableString stringWithFormat:@"%@",decimalNum];
        NSInteger decimalDigits;
        if ([[result componentsSeparatedByString:@"."] count] == 1) {
            decimalDigits = 0;
        }else{
            decimalDigits = [[result componentsSeparatedByString:@"."] lastObject].length;
        }
        if (!decimalDigits && digits) {
            [result appendString:@"."];
        }
        if (decimalDigits < digits) {
            for (int i = 0; i < digits - decimalDigits; i ++) {
                [result appendString:@"0"];
            }
        }
    }
    return result;
}


- (NSMutableAttributedString *)attributeStrWithTargetStr:(NSString *)targetStr range:(NSRange)range color:(UIColor *)color
{
    if (self.length < 1) return nil;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:self];
    if (targetStr.length < 1 && range.length < 1) return attStr;
    if (!color) return attStr;
    if(range.length > 0){
        [attStr addAttribute:NSForegroundColorAttributeName value:color range:range];
    }else if (targetStr.length > 0) {
        NSRange targetRange = [self rangeOfString:targetStr];
        if (targetRange.length < 1) return attStr;
        [attStr addAttribute:NSForegroundColorAttributeName value:color range:targetRange];
    }
    return attStr;
}

- (NSMutableAttributedString *)attributeStrWithTargetStr:(NSString *)targetStr range:(NSRange)range attributedDictionary:(NSDictionary *)attriDic
{
    if (self.length < 1) return nil;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:self];
    if (targetStr.length < 1 && range.length < 1) return attStr;
    if(range.length > 0){
        [attStr addAttributes:attriDic range:range];
    }else if (targetStr.length > 0) {
        NSRange targetRange = [self rangeOfString:targetStr];
        if (targetRange.length < 1) return attStr;
         [attStr addAttributes:attriDic range:targetRange];
    }
    return attStr;
}
@end
