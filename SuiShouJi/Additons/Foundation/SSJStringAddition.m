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

@implementation NSString (SSJCategory)

- (NSString *)ssj_urlPath {
    NSURL *url = [NSURL URLWithString:self];
    return url.path;
}

- (NSString *)ssj_md5HexDigest {
//    const char* str = [self UTF8String];
//    unsigned char result[CC_MD5_DIGEST_LENGTH];
//    CC_MD5(str, (CC_LONG)strlen(str), result);
//    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];//
//    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
//        [ret appendFormat:@"%02x",result[i]];
//    }
//    return [ret lowercaseString];
    
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

- (NSDate *)ssj_dateWithFormat:(NSString *)format {
    if (!format) {
        format = @"YYYY-MM-dd HH:mm:ss";
    }
    NSDateFormatter *tempFormat = [[NSDateFormatter alloc] init];
    [tempFormat setDateFormat:format];
    NSDate *date = [tempFormat dateFromString:self];
    return date;
}

- (NSString *)ssj_dateStringFromFormat:(NSString *)fromFormat toFormat:(NSString *)toFormat {
    NSDateFormatter *tempFormat = [[NSDateFormatter alloc] init];
    [tempFormat setDateFormat:fromFormat];
    NSDate *date = [tempFormat dateFromString:self];
    [tempFormat setDateFormat:toFormat];
    return [tempFormat stringFromDate:date];
}


- (int)ssj_countWord
{
    int length = 0;
    NSString *regex = @"[\u4E00-\u9FA5]";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    for (int i = 0; i < self.length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *tempstr = [self substringWithRange:range];
        if ([predicate evaluateWithObject:tempstr]) {
            length += 2;
        }else{
            length += 1;
        }
    }
    return length;
}

@end


@implementation NSString (SSJDecimal)

- (NSString *)ssj_reserveDecimalDigits:(int)digits {
    NSArray *arr = [self componentsSeparatedByString:@"."];
    
    if ([self isEqualToString:@"0."] || [self isEqualToString:@"."]) {
        return @"0.";
    }else if (self.length == 2) {
        if ([self floatValue] == 0) {
            return @"0";
        }else if(arr.count < 2){
            return [NSString stringWithFormat:@"%d",[self intValue]];
        }
    }
    
    if (arr.count > 2) {
        return [NSString stringWithFormat:@"%@.%@",arr[0],arr[1]];
    }
    
    if (arr.count == 2) {
        NSString * lastStr = arr.lastObject;
        if (lastStr.length > digits) {
            return [NSString stringWithFormat:@"%@.%@",arr[0],[lastStr substringToIndex:digits]];
        }
    }
    
    return self;
}

@end
