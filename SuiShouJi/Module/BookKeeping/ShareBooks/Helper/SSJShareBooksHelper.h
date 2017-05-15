//
//  SSJShareBooksHelper.h
//  SuiShouJi
//
//  Created by ricky on 2017/5/12.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJShareBooksHelper : NSObject

typedef NS_ENUM(NSInteger, SSJRandomCodeType) {
    SSJRandomCodeTypeUpperLetter     = 1 << 0, //  大写字母
    SSJRandomCodeTypeLowerLetter     = 1 << 1, //  小写字母
    SSJRandomCodeTypeNumbers         = 1 << 2, //  数字
    SSJRandomCodeTypeAll  = SSJRandomCodeTypeUpperLetter | SSJRandomCodeTypeLowerLetter | SSJRandomCodeTypeNumbers, // 收入
};

+ (NSString *)generateTheRandomCodeWithType:(SSJRandomCodeType)type length:(int)length;

@end
