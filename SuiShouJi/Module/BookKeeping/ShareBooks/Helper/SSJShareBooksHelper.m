
//
//  SSJShareBooksHelper.m
//  SuiShouJi
//
//  Created by ricky on 2017/5/12.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBooksHelper.h"

@implementation SSJShareBooksHelper

+ (NSString *)generateTheRandomCodeWithType:(SSJRandomCodeType)type length:(int)length{
    NSString *randomCode = @"";
    
    NSDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];

    NSDictionary *resultdic = [NSMutableDictionary dictionaryWithCapacity:0];

    
    NSString *wholeStr = @"";
    if ((type & SSJRandomCodeTypeUpperLetter) == SSJRandomCodeTypeUpperLetter) {
        wholeStr = [wholeStr stringByAppendingString:[self upperLetters]];
    }
    
    if ((type & SSJRandomCodeTypeLowerLetter) == SSJRandomCodeTypeLowerLetter) {
        wholeStr = [wholeStr stringByAppendingString:[self lowerLetters]];
    }
    
    if ((type & SSJRandomCodeTypeNumbers) == SSJRandomCodeTypeNumbers) {
        wholeStr = [wholeStr stringByAppendingString:[self numbers]];
    }
    
    for (int i = 0; i < length; i ++) {
        int ramdom = arc4random()%wholeStr.length;
        NSString *currentStr = [wholeStr substringWithRange:NSMakeRange(ramdom  , 1)];
        randomCode = [randomCode stringByAppendingString:currentStr];
        if (![dic objectForKey:currentStr]) {
            [dic setValue:@(1) forKey:currentStr];
        } else {
            NSInteger count = [[dic objectForKey:currentStr] integerValue] + 1;
            [dic setValue:@(count) forKey:currentStr];
        }
    }
    
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        float count = [obj floatValue] / 100000.f;
        [resultdic setValue:@(count) forKey:key];
    }];
    
    return randomCode;
}

+ (NSString *)upperLetters {
    return @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
}

+ (NSString *)lowerLetters {
    return @"abcdefghijklmnopqrstuvwxyz";
}

+ (NSString *)numbers {
    return @"0123456789";
}


@end
