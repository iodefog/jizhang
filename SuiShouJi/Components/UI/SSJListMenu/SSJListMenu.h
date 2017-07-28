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
 每个label中的行数,默认是1,如果0自动计算行数
 */
@property (nonatomic) NSInteger numberOfLines;

/**
 内容对其方式，默认UIControlContentHorizontalAlignmentCenter，此属性会影响布局
 注意：目前只实现了UIControlContentHorizontalAlignmentCenter、UIControlContentHorizontalAlignmentLeft、UIControlContentHorizontalAlignmentRight三种方式
 */
@property (nonatomic) UIControlContentHorizontalAlignment contentAlignment;

/**
 default 0.5
 */
@property (nonatomic) CGFloat shadowOpacity;

/**
 default CGSizeMake(0, 3)
 */
@property (nonatomic) CGSize shadowOffset;

/**
 圆角半径，默认2
 */
@property (nonatomic) CGFloat cornerRadius;

/**
 在view中的顶点显示；只是简便方法，内部还是调用showInView:atPoint:superViewInsets:finishHandle:dismissHandle:

 @param view <#view description#>
 @param point <#point description#>
 */
- (void)showInView:(UIView *)view
           atPoint:(CGPoint)point;

/**
 <#Description#>

 @param view <#view description#>
 @param point <#point description#>
 @param insets 只有left和right有效
 @param finishHandle <#finishHandle description#>
 @param dismissHandle <#dismissHandle description#>
 */
- (void)showInView:(UIView *)view
           atPoint:(CGPoint)point
   superViewInsets:(UIEdgeInsets)insets
      finishHandle:(void(^)(SSJListMenu *listMenu))finishHandle
     dismissHandle:(void (^)(SSJListMenu *listMenu))dismissHandle;

- (void)dismiss;

@end

@interface SSJListMenu (SSJTheme)

- (void)updateAppearance;

@end
