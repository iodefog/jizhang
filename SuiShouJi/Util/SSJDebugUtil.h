//
//  SSJDebugUtil.h
//  SuiShouJi
//
//  Created by old lang on 15/11/19.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  交换两个方法的实现，主要用来调试
 *
 *  @param class                交换哪个类中的方法
 *  @param originalSelector     原始方法
 *  @param swizzledSelector     替换的方法
 */
void SSJSwizzleSelector(Class class, SEL originalSelector, SEL swizzledSelector);

@interface SSJDebugUtil : NSObject

@end
