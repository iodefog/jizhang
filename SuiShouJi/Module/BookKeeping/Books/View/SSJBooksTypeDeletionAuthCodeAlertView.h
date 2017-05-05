//
//  SSJBooksTypeDeletionAuthCodeAlertView.h
//  SuiShouJi
//
//  Created by old lang on 17/4/24.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSJBooksTypeDeletionAuthCodeAlertView : UIView

@property (nonatomic, copy) void (^finishVerification)();

- (void)show;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
