//
//  SSJAlertViewDelegator.m
//  DebugDemo
//
//  Created by old lang on 15/9/13.
//  Copyright (c) 2015年 ___Lang___. All rights reserved.
//

#import "SSJAlertViewDelegator.h"
#import "SSJAlertViewAdapter.h"

@implementation SSJAlertViewDelegator

+ (instancetype)sharedDelegator {
    static SSJAlertViewDelegator *delegator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!delegator) {
            delegator = [[SSJAlertViewDelegator alloc] init];
        }
    });
    return delegator;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.alertViewAdapter.actions.count > 0) {
        SSJAlertViewAction *action = self.alertViewAdapter.actions[buttonIndex];
        if (action.handler) {
            action.handler(action);
        }
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.alertViewAdapter = nil;
}

@end
