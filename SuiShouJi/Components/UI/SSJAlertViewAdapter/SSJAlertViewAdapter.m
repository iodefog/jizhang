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

@property (nonatomic, strong) id alert;

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
    
    [adapter configureAlertWithTitle:title message:message];
    [adapter show];
}

+ (instancetype)adapterWithTitle:(nullable NSString *)title message:(nullable NSString *)message action:(nullable SSJAlertViewAction *)action,... {
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
    
    [adapter configureAlertWithTitle:title message:message];
    return adapter;
}

+ (instancetype)adapterWithTitle:(nullable NSString *)title message:(nullable NSString *)message {
    return [SSJAlertViewAdapter adapterWithTitle:title message:message action:nil];
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

- (void)addAction:(SSJAlertViewAction *)action {
    [_p_Actions addObject:action];
    if (SSJSystemVersion() >= 8.0) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:action.title style:UIAlertActionStyleDefault handler:^(UIAlertAction *bAction) {
            if (action.handler) {
                action.handler(action);
            }
        }];
        [_alert addAction:alertAction];
    } else {
        [_alert addButtonWithTitle:action.title];
    }
}

- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *textField))configurationHandler {
    if (SSJSystemVersion() >= 8.0) {
        [_alert addTextFieldWithConfigurationHandler:configurationHandler];
    } else {
        if (configurationHandler) {
            UITextField *textField = [_alert textFieldAtIndex:0];
            configurationHandler(textField);
        }
    }
}

- (void)show {
    if (SSJSystemVersion() >= 8.0) {
        [SSJVisibalController() presentViewController:_alert animated:YES completion:nil];
    } else {
        [_alert show];
    }
}

- (NSArray *)actions {
    return [NSArray arrayWithArray:_p_Actions];
}

- (UITextField *)textField {
    if (SSJSystemVersion() >= 8.0) {
        return [[_alert textFields] firstObject];
    } else {
        return [_alert textFieldAtIndex:0];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (_p_Actions.count > 0) {
        SSJAlertViewAction *action = [_p_Actions ssj_safeObjectAtIndex:buttonIndex];
        if (action.handler) {
            action.handler(action);
        }
    }
}

- (void)configureAlertWithTitle:(NSString *)title message:(NSString *)message {
    if (SSJSystemVersion() >= 8.0) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        for (SSJAlertViewAction *tempAction in self.actions) {
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:tempAction.title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if (tempAction.handler) {
                    tempAction.handler(tempAction);
                }
            }];
            [alertVC addAction:alertAction];
        }
        self.alert = alertVC;
    } else {
        SSJAlertViewDelegator *delegator = [SSJAlertViewDelegator sharedDelegator];
        delegator.alertViewAdapter = self;
        UIAlertView *aler = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegator cancelButtonTitle:nil otherButtonTitles:nil, nil];
        for (SSJAlertViewAction *action in self.actions) {
            [aler addButtonWithTitle:action.title];
        }
        self.alert = aler;
    }
}

@end

@implementation SSJAlertViewAdapter (SSJError)

+ (void)showError:(NSError *)error {
    [self showError:error completion:NULL];
}

+ (void)showError:(NSError *)error completion:(nullable void(^)())completion {
    NSString *message = nil;
    if ([[self errorCodesShowingDetail] containsObject:@(error.code)]) {
        message = [error localizedDescription];
    } else {
#ifdef DEBUG
        message = [error localizedDescription];
#else
        message = SSJ_ERROR_MESSAGE;
#endif
    }

    [self showAlertViewWithTitle:@"出错了" message:message action:[SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction * _Nonnull action) {
        if (completion) {
            completion();
        }
    }], nil];
}

/**
 不论是Debug还是Release都显示具体错误信息的code
 */
+ (NSSet *)errorCodesShowingDetail {
    return [NSSet setWithObjects:@(SSJErrorCodeLoginPasswordIllegal), nil];
}

@end
