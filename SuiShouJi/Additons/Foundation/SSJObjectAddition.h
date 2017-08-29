//
//  SSJObjectAddition.h
//  SuiShouJi
//
//  Created by old lang on 15/11/30.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SSJCategory)

- (id)ssj_performSelector:(SEL)aSelector withArg:(id)arg,...;

- (NSString *)ssj_debugDescription;

- (id)ssj_copyWithZone:(NSZone *)zone;

@end
