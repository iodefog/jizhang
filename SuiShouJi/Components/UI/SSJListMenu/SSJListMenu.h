//
//  SSJListMenu.h
//  SuiShouJi
//
//  Created by old lang on 16/7/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJListMenuItem.h"

@interface SSJListMenu : UIControl

@property (nonatomic, strong) NSArray <SSJListMenuItem *>*items;

/**
 选中的cell下标，默认－1（即什么都不选）
 */
@property (nonatomic) NSInteger selectedIndex;

/**
 边框颜色，默认lightGrayColor
 */
@property (nonatomic, strong) UIColor *borderColor;

/**
 背景填充色，默认whiteColor
 */
@property (nonatomic, strong) UIColor *fillColor;

/**
 cell分割线颜色，默认lightGrayColor
 */
@property (nonatomic, strong) UIColor *separatorColor;

/**
 cell分割线内凹，只有left、right两个值有效，默认｛0，10，0，10｝
 */
@property (nonatomic) UIEdgeInsets separatorInset;

/**
 标题大小，默认16号字
 */
@property (nonatomic, strong) UIFont *titleFont;

/**
 每行高度，默认44
 */
@property (nonatomic) CGFloat rowHeight;

/**
 最小展示的行数，默认0
 */
@property (nonatomic) CGFloat minDisplayRowCount;

/**
 最大展示的行数，默认0（即没有限制）
 */
@property (nonatomic) CGFloat maxDisplayRowCount;

/**
 图标大小，默认CGSizeZero，即自动调整大小
 */
@property (nonatomic) CGSize imageSize;

/**
 图标和标题之间的距离，默认10，此属性会影响布局
 */
@property (nonatomic) CGFloat gapBetweenImageAndTitle;

/**
 每行内容的布局范围，默认｛0， 10， 0， 10｝
 */
@property (nonatomic) UIEdgeInsets contentInsets;

/**
 内容对其方式，默认UIControlContentHorizontalAlignmentCenter，此属性会影响布局
 注意：目前只实现了UIControlContentHorizontalAlignmentCenter、UIControlContentHorizontalAlignmentLeft、UIControlContentHorizontalAlignmentRight三种方式
 */
@property (nonatomic) UIControlContentHorizontalAlignment contentAlignment;

- (void)showInView:(UIView *)view atPoint:(CGPoint)point;

- (void)showInView:(UIView *)view atPoint:(CGPoint)point dismissHandle:(void (^)(SSJListMenu *listMenu))dismissHandle;

- (void)showInView:(UIView *)view atPoint:(CGPoint)point finishHandle:(void(^)(SSJListMenu *listMenu))finishHandle dismissHandle:(void (^)(SSJListMenu *listMenu))dismissHandle;

- (void)dismiss;

@end

@interface SSJListMenu (SSJTheme)

- (void)updateAppearance;

@end
