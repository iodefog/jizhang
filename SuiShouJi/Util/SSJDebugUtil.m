//
//  SSJDebugUtil.m
//  SuiShouJi
//
//  Created by old lang on 15/11/19.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJDebugUtil.h"
#import <objc/runtime.h>

void SSJSwizzleSelector(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

#ifdef DEBUG

@interface SSJDebugTimer ()

@property (nonatomic) CFAbsoluteTime startTime;

@end

@implementation SSJDebugTimer

+ (SSJDebugTimer *)shareInstance {
    static SSJDebugTimer *timer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timer = [[SSJDebugTimer alloc] init];
    });
    return timer;
}

+ (void)markStartTime {
    [SSJDebugTimer shareInstance].startTime = CFAbsoluteTimeGetCurrent();
}

+ (void)logTimeInterval {
    NSLog(@"耗时：%f", CFAbsoluteTimeGetCurrent() - [SSJDebugTimer shareInstance].startTime);
}

@end

#endif
