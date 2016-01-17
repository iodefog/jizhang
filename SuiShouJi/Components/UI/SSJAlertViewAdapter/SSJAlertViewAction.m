//
//  SSJAlertViewAction.m
//  DebugDemo
//
//  Created by old lang on 15/8/12.
//  Copyright (c) 2015年 ___Lang___. All rights reserved.
//

#import "SSJAlertViewAction.h"

@interface SSJAlertViewAction ()

@property (nonatomic, copy, readwrite) NSString *title;

@property (nonatomic, copy, readwrite) SSJAlertViewActionHandle handler;

@end

@implementation SSJAlertViewAction

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(SSJAlertViewAction *action))handler {
    SSJAlertViewAction *action = [[SSJAlertViewAction alloc] init];
    action.title = title;
    action.handler = handler;
    return action;
}

@end
