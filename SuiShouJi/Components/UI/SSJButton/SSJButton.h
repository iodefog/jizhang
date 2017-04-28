//
//  SSJButton.h
//  SuiShouJi
//
//  Created by old lang on 17/3/17.
//  Copyright © 2017年 MZL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJButtonConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSJButton : UIControl

@property (nonatomic) CGFloat borderWidth;

@property (nonatomic) CGFloat cornerRadius;

@property (nonatomic) UIEdgeInsets contentInset;

@property (nonatomic) UIEdgeInsets titleInset;

@property (nonatomic) UIEdgeInsets imageInset;

@property (nonatomic) CGFloat spaceBetweenImageAndTitle;

/**
 default SSJButtonLayoutStyleImageAndTitleCenter
 */
@property (nonatomic) SSJButtonLayoutStyle layoutStyle;

@property (nonatomic, strong, readonly) UILabel *titleLabel;

@property (nonatomic, strong, readonly) UIImageView *imageView;

@property (nonatomic, strong, readonly) UIImageView *backgroundImageView;

@property (nonatomic, readonly) SSJButtonState currentState;

- (void)setTitle:(nullable NSString *)title forState:(SSJButtonState)state;

- (void)setTitleColor:(nullable UIColor *)color forState:(SSJButtonState)state;

- (void)setImage:(nullable UIImage *)image forState:(SSJButtonState)state;

- (void)setBackgroundImage:(nullable UIImage *)image forState:(SSJButtonState)state;

- (void)setBackgroundColor:(nullable UIColor *)backgroundColor forState:(SSJButtonState)state;

- (void)setBorderColor:(nullable UIColor *)borderColor forState:(SSJButtonState)state;

- (nullable NSString *)titleForState:(SSJButtonState)state;

- (nullable UIColor *)titleColorForState:(SSJButtonState)state;

- (nullable UIImage *)imageForState:(SSJButtonState)state;

- (nullable UIImage *)backgroundImageForState:(SSJButtonState)state;

- (nullable UIColor *)backgroundColorForState:(SSJButtonState)state;

- (nullable UIColor *)borderColorForState:(SSJButtonState)state;

@end

NS_ASSUME_NONNULL_END
