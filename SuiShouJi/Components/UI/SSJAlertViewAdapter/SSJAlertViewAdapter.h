//
//  SSJAlertViewAdapter.h
//  DebugDemo
//
//  Created by old lang on 15/8/12.
//  Copyright (c) 2015年 ___Lang___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSJAlertViewAction.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSJAlertViewAdapter : NSObject

@property (readonly, nonatomic, strong) NSArray *actions;

@property (nullable, readonly, nonatomic) UITextField *textField;

+ (void)showAlertViewWithTitle:(nullable NSString *)title message:(nullable NSString *)message action:(nullable SSJAlertViewAction *)action,...;

+ (instancetype)adapterWithTitle:(nullable NSString *)title message:(nullable NSString *)message action:(nullable SSJAlertViewAction *)action,...;

+ (instancetype)adapterWithTitle:(nullable NSString *)title message:(nullable NSString *)message;

- (void)addAction:(SSJAlertViewAction *)action;

- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *textField))configurationHandler;

- (void)show;

@end

@interface SSJAlertViewAdapter (SSJError)

+ (void)showError:(NSError *)error;

+ (void)showError:(NSError *)error completion:(nullable void(^)())completion;

@end

NS_ASSUME_NONNULL_END
