//
//  SSJListMenuItem.h
//  SuiShouJi
//
//  Created by old lang on 16/7/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJListMenuItem : NSObject

/**
 图片名称
 */
@property (nonatomic, copy) NSString *imageName;

/**
 标题
 */
@property (nonatomic, copy) NSString *title;

/**
 标题未选中状态颜色
 */
@property (nonatomic, copy) UIColor *normalTitleColor;

/**
 标题选中状态颜色
 */
@property (nonatomic, copy) UIColor *selectedTitleColor;

/**
 图片未选中状态颜色
 */
@property (nonatomic, copy) UIColor *normalImageColor;

/**
 图片选中状态颜色
 */
@property (nonatomic, copy) UIColor *selectedImageColor;

+ (instancetype)itemWithImageName:(NSString *)imageName
                            title:(NSString *)title
                 normalTitleColor:(UIColor *)normalTitleColor
               selectedTitleColor:(UIColor *)selectedTitleColor
                 normalImageColor:(UIColor *)normalImageColor
               selectedImageColor:(UIColor *)selectedImageColor;

@end
