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
#import "GTMBase64.h"

@implementation NSString (SSJEncryption)

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
//    return [ret copy];
    
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

- (NSString *)aes256_encrypt:(NSString *)key {
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    //对数据进行加密
    NSData *result = [data aes256_encrypt:key];
    
    //转换为2进制字符串
    if (result && result.length > 0) {
        
        Byte *datas = (Byte*)[result bytes];
        NSMutableString *output = [NSMutableString stringWithCapacity:result.length * 2];
        for(int i = 0; i < result.length; i++){
            [output appendFormat:@"%02x", datas[i]];
        }
        return output;
    }
    return nil;
}

- (NSString *)aes256_decrypt:(NSString *)key {
    //转换为2进制Data
    NSMutableData *data = [NSMutableData dataWithCapacity:self.length / 2];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [self length] / 2; i++) {
        byte_chars[0] = [self characterAtIndex:i*2];
        byte_chars[1] = [self characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    
    //对数据进行解密
    NSData* result = [data aes256_decrypt:key];
    if (result && result.length > 0) {
        return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSString*)cd_AESencryptWithKey:(NSString*)key iv:(NSString *)Iv{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [data cd_encryptionWithKey:key iv:Iv];
    return [GTMBase64 encodeBase64Data:encryptedData];
}

- (NSString*)cd_AESdecryptWithKey:(NSString *)key iv:(NSString *)Iv{
    NSData *decodeBase64Data=[GTMBase64 decodeString:self];
    NSData *decryData = [decodeBase64Data cd_decryptionWithKey:key iv:Iv];
    NSString *str = [[NSString alloc] initWithData:decryData encoding:NSUTF8StringEncoding];
    return str;
}

@end

@implementation NSString (SSJDate)

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

- (NSString *)ssj_reserveDecimalDigits:(int)decimalDigits intDigits:(int)intDigits {
    NSArray *arr = [self componentsSeparatedByString:@"."];
    if (arr.count == 1) {
        NSString *intPart = [arr firstObject];
        if (intPart.length > 0) {
            intPart = [NSString stringWithFormat:@"%lld", [intPart longLongValue]];
        }
        if (intDigits > 0 && intPart.length > intDigits) {
            intPart = [intPart substringToIndex:intDigits];
        }
        return intPart;
    } else if (arr.count > 1) {
        NSString *intPart = [arr firstObject];
        intPart = [NSString stringWithFormat:@"%lld", [intPart longLongValue]];
        if (intDigits > 0 && intPart.length > intDigits) {
            intPart = [intPart substringToIndex:intDigits];
        }
        
        NSString *decimalPart = [arr objectAtIndex:1];
        if (decimalPart.length > decimalDigits) {
            decimalPart = [decimalPart substringToIndex:decimalDigits];
        }
        
        return [NSString stringWithFormat:@"%@.%@", intPart, decimalPart];
    } else {
        return self;
    }
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


/**
 手机号码验证
 */
- (BOOL)ssj_validPhoneNum
{
    //第1位必须为1，第2位不能是1/2/6/9，
    NSString *phoneRegex = @"^1[3,4,5,7,8]\\d{9}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:self];
}


- (UIImage *)base64ToImage {
    NSData *decodedImageData = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:decodedImageData];
}


@end
