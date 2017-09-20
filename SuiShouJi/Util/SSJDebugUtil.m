
//
//  SSJDebugUtil.m
//  SuiShouJi
//
//  Created by old lang on 15/11/19.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJDebugUtil.h"

#ifdef DEBUG

@interface SSJDebugTimer ()

@property (nonatomic) CFAbsoluteTime startTime;

@end

@implementation SSJDebugTimer

+ (SSJDebugTimer *)shareInstance {
    static SSJDebugTimer *timer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timer = [[SSJDebugTimer alloc] init];
    });
    return timer;
}

+ (void)markStartTime {
    [SSJDebugTimer shareInstance].startTime = CFAbsoluteTimeGetCurrent();
}

+ (void)logTimeInterval {
    NSLog(@"耗时：%f", CFAbsoluteTimeGetCurrent() - [SSJDebugTimer shareInstance].startTime);
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
@interface UITableView (SSJDebug)

@end

@implementation UITableView (SSJDebug)

+ (void)load {
    SSJSwizzleSelector([self class], @selector(reloadData), @selector(ssj_reloadData));
}

- (void)ssj_reloadData {
    [self ssj_reloadData];
    if (![NSThread currentThread].isMainThread) {
        SSJDispatchMainAsync(^{
            [SSJAlertViewAdapter showError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"警告：在子线程中调用reloadData"}]];
        });
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
@interface UICollectionView (SSJDebug)

@end

@implementation UICollectionView (SSJDebug)

+ (void)load {
    SSJSwizzleSelector([self class], @selector(reloadData), @selector(ssj_reloadData));
}

- (void)ssj_reloadData {
    [self ssj_reloadData];
    if (![NSThread currentThread].isMainThread) {
        SSJDispatchMainAsync(^{
            [SSJAlertViewAdapter showError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"警告：在子线程中调用reloadData"}]];
        });
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
@interface UIView (SSJDebug)

@end

@implementation UIView (SSJDebug)

+ (void)load {
    SSJSwizzleSelector([self class], @selector(layoutSubviews), @selector(ssj_layoutSubviews));
    SSJSwizzleSelector([self class], @selector(setNeedsLayout), @selector(ssj_setNeedsLayout));
    SSJSwizzleSelector([self class], @selector(layoutIfNeeded), @selector(ssj_layoutIfNeeded));
    SSJSwizzleSelector([self class], @selector(updateConstraints), @selector(ssj_updateConstraints));
    SSJSwizzleSelector([self class], @selector(setNeedsUpdateConstraints), @selector(ssj_setNeedsUpdateConstraints));
    SSJSwizzleSelector([self class], @selector(updateConstraintsIfNeeded), @selector(ssj_updateConstraintsIfNeeded));
}

- (void)ssj_setNeedsLayout {
    [self ssj_setNeedsLayout];
    if (![NSThread currentThread].isMainThread) {
        SSJDispatchMainAsync(^{
            [SSJAlertViewAdapter showError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"警告：在子线程中调用setNeedsLayout"}]];
        });
    }
}

- (void)ssj_layoutIfNeeded {
    [self ssj_layoutIfNeeded];
    if (![NSThread currentThread].isMainThread) {
        SSJDispatchMainAsync(^{
            [SSJAlertViewAdapter showError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"警告：在子线程中调用layoutIfNeeded"}]];
        });
    }
}

- (void)ssj_layoutSubviews {
    [self ssj_layoutSubviews];
    if (![NSThread currentThread].isMainThread) {
        //        SSJDispatchMainAsync(^{
        //            [SSJAlertViewAdapter showError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"警告：在子线程中调用layoutSubviews"}]];
        //        });
    }
}

- (void)ssj_updateConstraints {
    [self ssj_updateConstraints];
    if (![NSThread currentThread].isMainThread) {
        //        SSJDispatchMainAsync(^{
        //            [SSJAlertViewAdapter showError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"警告：在子线程中调用updateConstraints"}]];
        //        });
    }
}

- (void)ssj_setNeedsUpdateConstraints {
    [self ssj_setNeedsUpdateConstraints];
    if (![NSThread currentThread].isMainThread) {
        SSJDispatchMainAsync(^{
            [SSJAlertViewAdapter showError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"警告：在子线程中更调用setNeedsUpdateConstraints"}]];
        });
    }
}

- (void)ssj_updateConstraintsIfNeeded {
    [self ssj_updateConstraintsIfNeeded];
    if (![NSThread currentThread].isMainThread) {
        SSJDispatchMainAsync(^{
            [SSJAlertViewAdapter showError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"警告：在子线程中调用updateConstraintsIfNeeded"}]];
        });
    }
}

@end

#endif
