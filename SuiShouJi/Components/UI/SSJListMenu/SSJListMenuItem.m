//
//  SSJListMenuItem.m
//  SuiShouJi
//
//  Created by old lang on 16/7/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJListMenuItem.h"

@implementation SSJListMenuItem

+ (instancetype)itemWithImageName:(NSString *)imageName title:(NSString *)title {
    SSJListMenuItem *item = [[SSJListMenuItem alloc] init];
    item.imageName = imageName;
    item.title = title;
    return item;
}

@end
