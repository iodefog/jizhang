//
//  SSJAlertViewAction.h
//  DebugDemo
//
//  Created by old lang on 15/8/12.
//  Copyright (c) 2015年 ___Lang___. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SSJAlertViewAction;

typedef void (^SSJAlertViewActionHandle)(SSJAlertViewAction *action);

@interface SSJAlertViewAction : NSObject

@property (nullable, nonatomic, copy, readonly) NSString *title;

@property (nullable, nonatomic, copy, readonly) SSJAlertViewActionHandle handler;

+ (instancetype)actionWithTitle:(NSString * _Nullable )title handler:(__nullable SSJAlertViewActionHandle)handler;

@end

NS_ASSUME_NONNULL_END