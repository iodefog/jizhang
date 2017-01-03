//
//  SSJMultiFunctionButton.h
//  SuiShouJi
//
//  Created by ricky on 16/9/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SSJMultiFunctionButtonDelegate;

@interface SSJMultiFunctionButtonView : UIView

@property (nonatomic, copy) void(^dismissBlock)();

@property (nonatomic, copy) void(^showBlock)();

//0为收起,1为展开
@property(nonatomic) BOOL buttonStatus;

@property(nonatomic, strong) NSArray *images;

//  代理协议；注意：只能设置customDelegate，设置delegate无效
@property (nonatomic, assign) id <SSJMultiFunctionButtonDelegate> customDelegate;

//主要按钮的下标,默认为0
@property(nonatomic) NSInteger mainButtonIndex;

//主要按钮的普通颜色
@property(nonatomic, strong) UIColor *mainButtonNormalColor;

//次要按钮的普通颜色
@property(nonatomic, strong) UIColor *secondaryButtonNormalColor;

//主要按钮的选中颜色
@property(nonatomic, strong) UIColor *mainButtonSelectedColor;


- (void)showOnView:(UIView *)view;

- (void)dismiss;

- (void)setButtonBackColor:(UIColor *)color forControlState:(UIControlState)state atIndex:(NSInteger)index;

@end

@protocol SSJMultiFunctionButtonDelegate<NSObject>

//  将要选中某个按钮后触发的回调，index：选中按钮的下标
- (void)multiFunctionButtonView:(SSJMultiFunctionButtonView *)buttonView willSelectButtonAtIndex:(NSUInteger)index;

@end
