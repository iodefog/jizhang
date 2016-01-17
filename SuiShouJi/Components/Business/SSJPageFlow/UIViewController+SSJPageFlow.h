//
//  UIViewController+SSJPageFlow.h
//  YYDB
//
//  Created by old lang on 15/11/5.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

//  页面流程控制

#import <UIKit/UIKit.h>

typedef void(^SSJPageFlowHandle)(UIViewController *controller);

@interface UIViewController (SSJPageFlow)

//  完成的回调
@property (nonatomic, copy, setter=ssj_setFinishHandle:, getter=ssj_getFinishHandle) SSJPageFlowHandle finishHandle;

//  取消的回调
@property (nonatomic, copy, setter=ssj_setCancelHandle:, getter=ssj_getCancelHandle) SSJPageFlowHandle cancelHandle;

@end
