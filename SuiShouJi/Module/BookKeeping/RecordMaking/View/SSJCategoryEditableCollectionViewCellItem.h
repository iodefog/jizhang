//
//  SSJCategoryEditableCollectionViewCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/8/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJCategoryEditableCollectionViewCellItem : NSObject

@property (nonatomic, strong) NSString *imageName;

@property (nonatomic, strong) UIColor *imageTintColor;

@property (nonatomic, strong) UIColor *imageBackgroundColor;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, strong) NSString *additionImageName;

+ (instancetype)cellItemWithImage:(NSString *)imageName
                   imageTintColor:(UIColor *)imageTintColor
             imageBackgroundColor:(UIColor *)imageBackgroundColor
                            title:(NSString *)title
                       titleColor:(UIColor *)titleColor
                    additionImage:(NSString *)additionImageName;

@end
