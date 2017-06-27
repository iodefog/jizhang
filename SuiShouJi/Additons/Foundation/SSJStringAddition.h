//
//  SSJStringAddition.h
//  MoneyMore
//
//  Created by old lang on 15-6-29.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SSJEncryption)

//  返回url路径
- (NSString *)ssj_urlPath;

/* md5加密 */
- (NSString *)ssj_md5HexDigest;

/* SHA-1加密 */
- (NSString *)ssj_sha1HexDigest;

- (NSString *)aes256_encrypt:(NSString *)key;

- (NSString *)aes256_decrypt:(NSString *)key;

- (NSString*)cd_AESencryptWithKey:(NSString*)key iv:(NSString *)Iv;

- (NSString*)cd_AESdecryptWithKey:(NSString *)key iv:(NSString *)Iv;

@end

@interface NSString (SSJDate)

//  将时间字符串转按照format格式换成date，若format为nil，则按照“YYYY-MM-dd HH:mm:ss”格式转换
- (NSDate *)ssj_dateWithFormat:(NSString *)format;

//  将时间字符串从formFormat格式换成toFormat格式
- (NSString *)ssj_dateStringFromFormat:(NSString *)fromFormat toFormat:(NSString *)toFormat;

@end

@interface NSString (SSJDecimal)

/**
 将数字字符串保留指定的整数位数和小数位数

 @param DecimalDigits 保留的小数位数，如果是0就舍去小数
 @param intDigits 保留的整数位数，如果是0，整数位就不做任何处理
 @return 处理后的字符串
 */
- (NSString *)ssj_reserveDecimalDigits:(int)decimalDigits intDigits:(int)intDigits;

@end

@interface NSString (SSJFilter)

- (NSString *)ssj_emojiFilter;

@end

@interface NSString (SSJRegex)

/**
 *  是否为有效的邮件格式
 */
- (BOOL)ssj_validEmial;
/**
 是否为有效的手机号码格式
 */
- (BOOL)ssj_validPhoneNum;


/**
 base64转图片

 @return <#return value description#>
 */
- (UIImage *)base64ToImage;

@end
