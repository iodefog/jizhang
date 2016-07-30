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

@property (nonatomic, strong, readonly) NSArray <SSJListMenuItem *>*items;

@property (nonatomic) NSUInteger selectedIndex;

@property (nonatomic, strong) UIColor *normalTitleColor;

@property (nonatomic, strong) UIColor *selectedTitleColor;

@property (nonatomic, strong) UIColor *fillColor;

- (instancetype)initWithItems:(NSArray <SSJListMenuItem *>*)items;

- (void)showInView:(UIView *)view atPoint:(CGPoint)point;

- (void)showInView:(UIView *)view atPoint:(CGPoint)point dismissHandle:(void (^)(SSJListMenu *listMenu))dismissHandle;

- (void)dismiss;

@end
