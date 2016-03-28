//
//  NSString+MoneyDisplayFormat.h
//  MoneyMore
//
//  Created by cdd on 15/10/12.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MoneyDisplayFormat)

/**
 *  金额数字超过三位，每隔3位加逗号格式化
 *
 *  @return (NSString *)格式化后的金额字符串
 */
-(NSString *)ssj_moneyDisplayFormat;

@end
