//
//  SSJListMenuItem.m
//  SuiShouJi
//
//  Created by old lang on 16/7/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJListMenuItem.h"

@implementation SSJListMenuItem

+ (instancetype)itemWithImageName:(NSString *)imageName
                            title:(NSString *)title
                 normalTitleColor:(UIColor *)normalTitleColor
               selectedTitleColor:(UIColor *)selectedTitleColor
                 normalImageColor:(UIColor *)normalImageColor
               selectedImageColor:(UIColor *)selectedImageColor
                  backgroundColor:(UIColor *)backgroundColor {
    
    SSJListMenuItem *item = [[SSJListMenuItem alloc] init];
    item.imageName = imageName;
    item.title = title;
    item.normalTitleColor = normalTitleColor;
    item.selectedTitleColor = selectedTitleColor;
    item.normalImageColor = normalImageColor;
    item.selectedImageColor = selectedImageColor;
    item.backgroundColor = backgroundColor;
    return item;
}

@end
