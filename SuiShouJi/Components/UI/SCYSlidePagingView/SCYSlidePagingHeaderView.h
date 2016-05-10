//
//  SCYSlidePagingHeaderView.h
//  SCYSlidePagingControl
//
//  Created by old lang on 15-4-30.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SCYSlidePagingHeaderViewDelegate;

@interface SCYSlidePagingHeaderView : UIScrollView

//  最多能显示按钮个数，若为0或大于titles元素个数，就显示全部按钮；默认为0
@property (nonatomic) CGFloat displayedButtonCount;

//  字体大小 默认15号字
@property (nonatomic) CGFloat titleFont;

//  点击按钮后 是否带有滚动效果，默认为NO
@property (nonatomic) BOOL buttonClickAnimated;

//  按钮标题
@property (nonatomic, strong) NSArray *titles;

//  按钮标题颜色，默认lightGrayColor
@property (nonatomic, strong) UIColor *titleColor;

//  选中后的按钮标题颜色，默认blueColor
@property (nonatomic, strong) UIColor *selectedTitleColor;

//  选中的按钮下标，默认0
@property (readonly, nonatomic) NSUInteger selectedIndex;

//  选中状态下按钮底部的横线，背景颜色默认为selectedTitleColor
//  默认大小：宽度和按钮宽度一样，高度是2
@property (readonly, nonatomic, strong) UIView *tabView;

//  代理协议；注意：只能设置customDelegate，设置delegate无效
@property (nonatomic, assign) id <SCYSlidePagingHeaderViewDelegate> customDelegate;

//  获取按钮数组
- (NSArray *)getButtons;

//  设置tabView的大小
- (void)setTabSize:(CGSize)tabSize;

//  设置选中的按钮下标
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated;

@end

//  代理协议
@protocol SCYSlidePagingHeaderViewDelegate <UIScrollViewDelegate>

@optional
//  将要选中某个按钮后触发的回调，index：选中按钮的下标
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView willSelectButtonAtIndex:(NSUInteger)index;

//  已经选中某个按钮后触发的回调，如果buttonClickAnimated为YES，此方法会在动画结束后调用 index：选中按钮的下标
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index;

@end
