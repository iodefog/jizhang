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

@end
