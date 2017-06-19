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

@property (nonatomic, copy) NSAttributedString *message;

/**
 确认按钮标题，如果不设置默认标题是“删除”
 */
@property (nonatomic, copy, nullable) NSString *sureButtonTitle;

/**
 取消按钮标题，如果不设置默认标题是“取消”
 */
@property (nonatomic, copy, nullable) NSString *cancelButtonTitle;

- (void)show;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
