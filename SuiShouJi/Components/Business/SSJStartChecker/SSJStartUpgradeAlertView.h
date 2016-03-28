//
//  SSJStartUpgradeAlertView.h
//  SuiShouJi
//
//  Created by old lang on 16/2/2.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

//  升级弹窗

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSJStartUpgradeAlertView : UIView

/**
 *  标准初始化方法，注意：如果sureButtonTitle、cancelButtonTitle为nil或长度为0，就不显示改按钮，并且相应的回调也不会执行
 *
 *  @param title 弹窗标题
 *  @param message 弹窗内容
 *  @param cancelButtonTitle 取消按钮标题
 *  @param sureButtonTitle 确认按钮标题
 *  @param cancelHandler 取消按钮点击回调
 *  @param sureHandler 确认按钮点击回调
 *  @return (instancetype) 返回实例对象
 */
- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(nullable NSString *)cancelButtonTitle
              sureButtonTitle:(nullable NSString *)sureButtonTitle
     cancelButtonClickHandler:(nullable void(^)(SSJStartUpgradeAlertView *alert))cancelHandler
       sureButtonClickHandler:(nullable void(^)(SSJStartUpgradeAlertView *alert))sureHandler;

/**
 *  显示弹窗
 */
- (void)show;

/**
 *  隐藏弹窗
 */
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
