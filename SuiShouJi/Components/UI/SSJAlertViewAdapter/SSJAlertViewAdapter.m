//
//  SSJAlertViewAdapter.m
//  DebugDemo
//
//  Created by old lang on 15/8/12.
//  Copyright (c) 2015年 ___Lang___. All rights reserved.
//

#import "SSJAlertViewAdapter.h"
#import "SSJAlertViewDelegator.h"

@interface SSJAlertViewAdapter ()

@property (readwrite, nonatomic, strong) NSMutableArray *p_Actions;

@end

@implementation SSJAlertViewAdapter

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message action:(SSJAlertViewAction *)action,... {
    SSJAlertViewAdapter *adapter = [SSJAlertViewAdapter adapter];
    if (action) {
        [adapter.p_Actions addObject:action];
    }
    va_list actionList;
    va_start(actionList, action);
    SSJAlertViewAction *tempAction = nil;
    while ((tempAction = va_arg(actionList, SSJAlertViewAction *))) {
        [adapter.p_Actions addObject:tempAction];
    }
    va_end(actionList);
    
    if (SSJSystemVersion() >= 8.0) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        for (SSJAlertViewAction *tempAction in adapter.actions) {
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:tempAction.title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if (tempAction.handler) {
                    tempAction.handler(tempAction);
                }
            }];
            [alertVC addAction:alertAction];
        }
        [SSJVisibalController() presentViewController:alertVC animated:YES completion:nil];
    } else {
        SSJAlertViewDelegator *delegator = [SSJAlertViewDelegator sharedDelegator];
        delegator.alertViewAdapter = adapter;
        UIAlertView *aler = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegator cancelButtonTitle:nil otherButtonTitles:nil, nil];
        for (SSJAlertViewAction *action in adapter.actions) {
            [aler addButtonWithTitle:action.title];
        }
        [aler show];
    }
}

+ (instancetype)adapter {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        _p_Actions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.actions.count > 0) {
        SSJAlertViewAction *action = self.actions[buttonIndex];
        if (action.handler) {
            action.handler(action);
        }
    }
}

- (NSArray *)actions {
    return [NSArray arrayWithArray:_p_Actions];
}

@end
