//
//  SSJCategoryEditableCollectionViewCellItem.m
//  SuiShouJi
//
//  Created by old lang on 16/8/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCategoryEditableCollectionViewCellItem.h"

@implementation SSJCategoryEditableCollectionViewCellItem

+ (instancetype)cellItemWithImage:(NSString *)imageName
                   imageTintColor:(UIColor *)imageTintColor
             imageBackgroundColor:(UIColor *)imageBackgroundColor
                            title:(NSString *)title
                       titleColor:(UIColor *)titleColor
                    additionImage:(NSString *)additionImageName {
    
    SSJCategoryEditableCollectionViewCellItem *item = [[SSJCategoryEditableCollectionViewCellItem alloc] init];
    item.imageName = imageName;
    item.imageTintColor = imageTintColor;
    item.imageBackgroundColor = imageBackgroundColor;
    item.title = title;
    item.titleColor = titleColor;
    item.additionImageName = additionImageName;
    return item;
}

@end
