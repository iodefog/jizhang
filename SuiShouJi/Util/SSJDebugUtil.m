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


@implementation SSJDebugUtil

@end

@interface UITableView (debug)

@end

@implementation UITableView (debug)

//+ (void)load {
//    SSJSwizzleSelector([self class], @selector(setContentInset:), @selector(ssj_setContentInset:));
//}
//
//- (void)ssj_setContentInset:(UIEdgeInsets)inset {
//    [self ssj_setContentInset:inset];
//    NSLog(@"<<< inset: %f >>>",inset.top);
//    NSLog(@"<<< current inset top: %f >>>",self.contentInset.top);
//}

@end
