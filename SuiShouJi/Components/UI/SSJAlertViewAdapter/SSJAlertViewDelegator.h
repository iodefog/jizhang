//
//  SSJAlertViewDelegator.h
//  DebugDemo
//
//  Created by old lang on 15/9/13.
//  Copyright (c) 2015年 ___Lang___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJAlertViewAdapter;

@interface SSJAlertViewDelegator : NSObject

@property (nonatomic, strong) SSJAlertViewAdapter *alertViewAdapter;

+ (instancetype)sharedDelegator;

@end
