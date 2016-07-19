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

@end

@interface NSString (SSJDate)

//  将时间字符串转按照format格式换成date，若format为nil，则按照“YYYY-MM-dd HH:mm:ss”格式转换
- (NSDate *)ssj_dateWithFormat:(NSString *)format;

//  将时间字符串从formFormat格式换成toFormat格式
- (NSString *)ssj_dateStringFromFormat:(NSString *)fromFormat toFormat:(NSString *)toFormat;

@end

@interface NSString (SSJDecimal)

- (NSString *)ssj_reserveDecimalDigits:(int)DecimalDigits intDigits:(int)intDigits;

@end

@interface NSString (SSJFilter)

- (NSString *)ssj_emojiFilter;

@end

@interface NSString (SSJRegex)

/**
 *  是否为有效的邮件格式
 */
- (BOOL)ssj_validEmial;

@end