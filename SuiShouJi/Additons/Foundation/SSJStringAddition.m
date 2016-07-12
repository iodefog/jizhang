//
//  SSJStringAddition.m
//  MoneyMore
//
//  Created by old lang on 15-6-29.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJStringAddition.h"
#import "SSJDataAddition.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (SSJEncryption)

- (NSString *)ssj_urlPath {
    NSURL *url = [NSURL URLWithString:self];
    return url.path;
}

- (NSString *)ssj_md5HexDigest {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md5Hash];
}

/* SHA-1加密 */
- (NSString *)ssj_sha1HexDigest {
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++){
        //        [output appendFormat:@"%02x", digest[i]];
        
        //理财帝定制加密方法
        NSString *strtemp=[NSString stringWithFormat:@"%02x",((digest[i] & 0xff) + 0x918)];
        strtemp = [strtemp substringFromIndex:1];
        [output appendString:strtemp];
    }
    //理财帝定制加密方法，舍弃第一位
    return output;
}

+ (NSDateFormatter *)ssj_dateFormat {
    static NSDateFormatter *format = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        format = [[NSDateFormatter alloc] init];
    });
    
    format.dateStyle = NSDateFormatterNoStyle;
    format.timeStyle = NSDateFormatterNoStyle;
    format.timeZone = [NSTimeZone localTimeZone];
    return format;
}

@end

@implementation NSString (SSJDate)

- (NSDate *)ssj_dateWithFormat:(NSString *)format {
    if (!format) {
        format = @"YYYY-MM-dd HH:mm:ss";
    }
    
    NSDateFormatter *dateFormat = [[self class] ssj_dateFormat];
    [dateFormat setDateFormat:format];
    NSDate *date = [dateFormat dateFromString:self];
    return date;
}

- (NSString *)ssj_dateStringFromFormat:(NSString *)fromFormat toFormat:(NSString *)toFormat {
    NSDateFormatter *format = [[self class] ssj_dateFormat];
    [format setDateFormat:fromFormat];
    NSDate *date = [format dateFromString:self];
    [format setDateFormat:toFormat];
    return [format stringFromDate:date];
}

@end


@implementation NSString (SSJDecimal)

- (NSString *)ssj_reserveDecimalDigits:(int)DecimalDigits intDigits:(int)intDigits{
    NSArray *arr = [self componentsSeparatedByString:@"."];
    NSString *intPart = [arr objectAtIndex:0];
    if (intDigits > 0) {
        if (intPart.length > intDigits) {
            intPart = [intPart substringToIndex:intDigits];
        }
    }
    if ([self isEqualToString:@"0."] || [self isEqualToString:@"."]) {
        return @"0.";
    }else if (self.length == 2) {
        if ([self floatValue] == 0) {
            return @"0";
        }else if(arr.count < 2){
            return [NSString stringWithFormat:@"%@",intPart];
        }
    }
    
    if (arr.count > 2) {
        return [NSString stringWithFormat:@"%@.%@",intPart,arr[1]];
    }
    
    if (arr.count == 2) {
        NSString * lastStr = arr.lastObject;
        if (lastStr.length > DecimalDigits) {
            return [NSString stringWithFormat:@"%@.%@",intPart,[lastStr substringToIndex:DecimalDigits]];
        }
    }
    
    if(arr.count < 2){
        return [NSString stringWithFormat:@"%@",intPart];
    }
    
    return self;
}

@end

@implementation NSString (SSJFilter)

- (NSString *)ssj_emojiFilter{
    NSMutableString *tempStr = [NSMutableString string];
    NSString *regEx = @"^[A-Za-z\\d\\u4E00-\\u9FA5\\p{P}‘’“”]+";
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    for (int i = 0; i < self.length; i ++) {
        if ([pred evaluateWithObject:[self substringWithRange:NSMakeRange(i, 1)]]) {
            [tempStr appendString:[self substringWithRange:NSMakeRange(i, 1)]];
        }
    }
    return [NSString stringWithFormat:@"%@",tempStr];
}

@end

@implementation NSString (SSJRegex)

- (BOOL)ssj_validEmial {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

@end
