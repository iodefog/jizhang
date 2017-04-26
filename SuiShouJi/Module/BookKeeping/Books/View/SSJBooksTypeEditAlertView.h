//
//  SSJBooksTypeEditAlertView.h
//  SuiShouJi
//
//  Created by old lang on 17/4/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSJBooksTypeEditAlertView : UIView

@property (nonatomic, copy) void(^editHandler)();

@property (nonatomic, copy) void(^deleteHandler)();

- (void)show;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
