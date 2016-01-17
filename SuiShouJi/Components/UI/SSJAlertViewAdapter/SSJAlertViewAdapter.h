//
//  SSJAlertViewAdapter.h
//  DebugDemo
//
//  Created by old lang on 15/8/12.
//  Copyright (c) 2015年 ___Lang___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJAlertViewAction.h"

@interface SSJAlertViewAdapter : NSObject

@property (readonly, nonatomic, strong) NSArray *actions;

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message action:(SSJAlertViewAction *)action,...;

@end
