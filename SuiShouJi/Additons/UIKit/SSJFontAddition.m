//
//  SSJFontAddition.m
//  MoneyMore
//
//  Created by old lang on 15-5-21.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJFontAddition.h"

CGFloat SSJCompatibleFontSize(CGFloat fontSize) {
    CGFloat compatibleFontSize = fontSize;
    CGFloat newFontSize = ([UIScreen mainScreen].bounds.size.width / 320) * fontSize;
    compatibleFontSize = newFontSize;
    return compatibleFontSize;
}

@implementation UIFont (SSJCategory)

+ (UIFont *)ssj_compatibleSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont systemFontOfSize:SSJCompatibleFontSize(fontSize)];
}

+ (UIFont *)ssj_compatibleBoldSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont boldSystemFontOfSize:SSJCompatibleFontSize(fontSize)];
}

+ (UIFont *)ssj_pingFangRegularFontOfSize:(CGFloat)fontSize {
    if (SSJSystemVersion() >= 9) {
        return [UIFont fontWithName:@"PingFangSC-Regular" size:(fontSize)];
    } else {
        return [UIFont systemFontOfSize:(fontSize)];
    }
}

+ (UIFont *)ssj_pingFangMediumFontOfSize:(CGFloat)fontSize {
    if (SSJSystemVersion() >= 9) {
        return [UIFont fontWithName:@"PingFangSC-Medium" size:(fontSize)];
    } else {
        return [UIFont systemFontOfSize:(fontSize)];
    }
}

+ (UIFont *)ssj_helveticaRegularFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"Helvetica" size:(fontSize)];
}

@end
