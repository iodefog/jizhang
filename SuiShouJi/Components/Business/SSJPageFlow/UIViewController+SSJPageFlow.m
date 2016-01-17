//
//  UIViewController+SSJPageFlow.m
//  YYDB
//
//  Created by old lang on 15/11/5.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "UIViewController+SSJPageFlow.h"
#import <objc/runtime.h>

static const void *kFinishHandleKey = @"kFinishHandleKey";
static const void *kCancelHandleKey = @"kCancelHandleKey";

@implementation UIViewController (SSJPageFlow)

- (void)ssj_setFinishHandle:(SSJPageFlowHandle)handle {
    objc_setAssociatedObject(self, kFinishHandleKey, handle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (SSJPageFlowHandle)ssj_getFinishHandle {
    return objc_getAssociatedObject(self, kFinishHandleKey);
}

- (void)ssj_setCancelHandle:(SSJPageFlowHandle)handle {
    objc_setAssociatedObject(self, kCancelHandleKey, handle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (SSJPageFlowHandle)ssj_getCancelHandle {
    return objc_getAssociatedObject(self, kCancelHandleKey);
}

@end
