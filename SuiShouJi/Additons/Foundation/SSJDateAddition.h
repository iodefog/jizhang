//
//  SSJDateAddition.h
//  SuiShouJi
//
//  Created by old lang on 15/10/28.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (SSJCategory)

//  将date对象转换成时间字符串
- (NSString *)ssj_dateStringWithFormat:(NSString *)format;

/**
 *  获取当前系统时间(当前系统时区)
 *
 *  @param format 日期格式(默认yyyy-MM-dd HH:mm:ss)
 *
 *  @return nsstring
 */
- (NSString *)ssj_systemCurrentDateWithFormat:(NSString *)format;

@end