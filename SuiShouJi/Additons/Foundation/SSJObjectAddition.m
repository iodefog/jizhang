//
//  SSJObjectAddition.m
//  SuiShouJi
//
//  Created by old lang on 15/11/30.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJObjectAddition.h"

@implementation NSObject (SSJCategory)

- (id)ssj_performSelector:(SEL)aSelector withArg:(id)arg,... {
    NSMethodSignature *sig = [self methodSignatureForSelector:aSelector];
    if (sig) {
        NSInvocation *invo = [NSInvocation invocationWithMethodSignature:sig];
        invo.target = self;
        invo.selector = aSelector;
        
        [invo setArgument:&arg atIndex:2];
        
        va_list valist;
        va_start(valist, arg);
        id var = nil;
        NSUInteger idx = 3;
        while ((var = va_arg(valist, id))) {
            [invo setArgument:&var atIndex:idx];
            idx ++;
        }
        va_end(valist);
        
        [invo invoke];
        
        if (sig.methodReturnLength) {
            id returnValue = nil;
            [invo getReturnValue:&returnValue];
            return returnValue;
        }
    }
    
    return nil;
}

- (NSString *)ssj_debugDescription {
    return [NSString stringWithFormat:@"%@:%@", self, [self mj_keyValues].description];
}

- (id)ssj_copyWithZone:(nullable NSZone *)zone {
    id obj = [[[self class] alloc] init];
    [[self class] mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
        id value = [self valueForKey:property.name];
        [obj setValue:value forKey:property.name];
    }];
    return obj;
}

@end
