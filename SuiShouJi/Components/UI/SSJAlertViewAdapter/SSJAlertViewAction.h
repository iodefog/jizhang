//
//  SSJAlertViewAction.h
//  DebugDemo
//
//  Created by old lang on 15/8/12.
//  Copyright (c) 2015年 ___Lang___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSJAlertViewAction;

typedef void (^SSJAlertViewActionHandle)(SSJAlertViewAction *action);

@interface SSJAlertViewAction : NSObject

@property (nonatomic, copy, readonly) NSString *title;

@property (nonatomic, copy, readonly) SSJAlertViewActionHandle handler;

+ (instancetype)actionWithTitle:(NSString *)title handler:(SSJAlertViewActionHandle)handler;

@end
