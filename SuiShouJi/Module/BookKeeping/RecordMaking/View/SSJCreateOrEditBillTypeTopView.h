//
//  SSJCreateOrEditBillTypeTopView.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSJCreateOrEditBillTypeTopView : UIView

/**
 用户是否自己输入过类别名称
 */
@property (nonatomic, readonly) BOOL userTypeInBillName;

/**
 箭头是否向下
 */
@property (nonatomic) BOOL arrowDown;

/**
 类别颜色
 */
@property (nonatomic, strong) UIColor *billTypeColor;

/**
 类别图标
 */
@property (nonatomic, strong) UIImage *billTypeIcon;

/**
 类别名称
 */
@property (nonatomic, copy) NSString *billTypeName;

/**
 点击色块触发的回调
 */
@property (nonatomic, copy) void (^tapColorAction)(SSJCreateOrEditBillTypeTopView *view);

/**
 设置箭头是否向下

 @param arrowDown 箭头是否向下
 @param animated 是否带有动画
 */
- (void)setArrowDown:(BOOL)arrowDown animated:(BOOL)animated;

/**
 设置类别颜色

 @param billTypeColor 类别颜色
 @param animated 是否带有动画
 */
- (void)setBillTypeColor:(UIColor *)billTypeColor animated:(BOOL)animated;

/**
 设置类别图标

 @param billTypeIcon 类别图标
 @param animated 是否带有动画
 */
- (void)setBillTypeIcon:(UIImage *)billTypeIcon animated:(BOOL)animated;

/**
 设置类别名称
 
 @param billTypeName 类别名称
 @param animated 是否带有动画
 */
- (void)setBillTypeName:(NSString *)billTypeName animated:(BOOL)animated;

/**
 根据主题适配外观
 */
- (void)updateAppearanceAccordingToTheme;

@end

NS_ASSUME_NONNULL_END
