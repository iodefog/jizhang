//
//  SSJViewAddition.h
//  MoneyMore
//
//  Created by old lang on 15-3-22.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

/*
 简化frame写法
 */

@interface UIView (SSJGeometry)

//  左边间距
@property (nonatomic) CGFloat left;

//  顶部间距
@property (nonatomic) CGFloat top;

//  右边间距
@property (nonatomic) CGFloat right;

//  底部间距
@property (nonatomic) CGFloat bottom;

//  左上角
@property (nonatomic) CGPoint leftTop;

//  左下角
@property (nonatomic) CGPoint leftBottom;

//  右上角
@property (nonatomic) CGPoint rightTop;

//  右下角
@property (nonatomic) CGPoint rightBottom;

//  宽度
@property (nonatomic) CGFloat width;

//  高度
@property (nonatomic) CGFloat height;

//  X轴中心点
@property (nonatomic) CGFloat centerX;

//  Y轴中心点
@property (nonatomic) CGFloat centerY;

//  原点
@property (nonatomic) CGPoint origin;

//  大小
@property (nonatomic) CGSize size;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIView (SSJBorder)

@property (nonatomic, getter=ssj_cornerStyle, setter=ssj_setCornerStyle:) UIRectCorner cornerStyle;

@property (nonatomic, getter=ssj_cornerRadius, setter=ssj_setCornerRadius:) CGFloat cornerRadius;

//  设置边框线类型
- (void)ssj_setBorderStyle:(SSJBorderStyle)customBorderStyle;

//  边框线类型
- (SSJBorderStyle)ssj_borderStyle;

//  设置边框线颜色
- (void)ssj_setBorderColor:(UIColor *)color;

//  边框线颜色
- (UIColor *)ssj_borderColor;

//  设置边框线宽度
- (void)ssj_setBorderWidth:(CGFloat)with;

//  边框线宽度
- (CGFloat)ssj_borderWidth;

//  设置边框线内凹
- (void)ssj_setBorderInsets:(UIEdgeInsets)insets;

//  边框线内凹
- (UIEdgeInsets)ssj_borderInsets;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIView (SSJWatermark)

- (void)ssj_showWatermarkWithImageName:(NSString *)imageName animated:(BOOL)animated target:(id)target action:(SEL)action;

- (void)ssj_showWatermarkWithCustomView:(UIView *)view animated:(BOOL)animated target:(id)target action:(SEL)action;

- (void)ssj_hideWatermark:(BOOL)animated;

- (void)ssj_relayoutWatermark;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIView (SSJLoadingIndicator)

- (void)ssj_showLoadingIndicator;

- (void)ssj_hideLoadingIndicator;

- (void)ssj_relayoutLoadingIndicator;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIView (SSJBackView)

- (void)ssj_showViewWithBackView:(UIView *)view
                       backColor:(UIColor *)backColor
                           alpha:(CGFloat)a
                          target:(id)target
                     touchAction:(SEL)selector;

- (void)ssj_showViewWithBackView:(UIView *)view
                       backColor:(UIColor *)backColor
                           alpha:(CGFloat)a
                          target:(id)target
                     touchAction:(SEL)selector
                       animation:(void(^)(void))animation
                    timeInterval:(NSTimeInterval)interval
                       fininshed:(void(^)(BOOL finished))fininshed;

- (void)ssj_hideBackViewForView:(UIView *)view
                      animation:(void(^)(void))animation
                   timeInterval:(NSTimeInterval)interval
                      fininshed:(void(^)(BOOL complation))fininshed;

- (void)ssj_hideBackViewForView:(UIView *)view;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIView (SSJResponder)

//  获取当前视图层级上的第一响应者
- (UIResponder *)ssj_getFirstResponder;

//  获取当前视图层级上获取焦点的TextField
- (UITextField *)ssj_getFirstResponderTextField;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIView (SSJViewController)

//  获取当前视图层级的控制器
- (UIViewController *)ssj_viewController;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIView (SSJScreenshot)

/**
 *  返回当前视图的截图
 *
 *  @return (UIImage *)
 */
- (UIImage *)ssj_takeScreenShot;

/**
 *  返回当前视图的截图
 *
 *  @param size 图片大小
 *  @param opaque  是否完全不透明
 *  @param scale  图片比率因素，值越大图片越清晰，如果为0，自动设置成主屏幕的比率
 *
 *  @return (UIImage *)
 */
- (UIImage *)ssj_takeScreenShotWithSize:(CGSize)size opaque:(BOOL)opaque scale:(CGFloat)scale;

@end
