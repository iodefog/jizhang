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

// 选中的cell下标，默认－1（即什么都不选）
@property (nonatomic) NSInteger selectedIndex;

// 标题未选中状态颜色
@property (nonatomic, strong) UIColor *normalTitleColor;

// 标题选中状态颜色
@property (nonatomic, strong) UIColor *selectedTitleColor;

// 背景填充色
@property (nonatomic, strong) UIColor *fillColor;

// cell分割线颜色
@property (nonatomic, strong) UIColor *separatorColor;

// 图片颜色
@property (nonatomic, strong) UIColor *imageColor;

// 标题大小，默认16号字
@property (nonatomic) CGFloat titleFontSize;

// default 2;必须大于0
@property (nonatomic) CGFloat displayRowCount;

- (instancetype)initWithItems:(NSArray <SSJListMenuItem *>*)items;

- (void)showInView:(UIView *)view atPoint:(CGPoint)point;

- (void)showInView:(UIView *)view atPoint:(CGPoint)point dismissHandle:(void (^)(SSJListMenu *listMenu))dismissHandle;

- (void)showInView:(UIView *)view atPoint:(CGPoint)point finishHandle:(void(^)(SSJListMenu *listMenu))finishHandle dismissHandle:(void (^)(SSJListMenu *listMenu))dismissHandle;

- (void)dismiss;

@end
