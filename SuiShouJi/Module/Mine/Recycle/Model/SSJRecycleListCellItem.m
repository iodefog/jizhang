//
//  SSJRecycleListCellItem.m
//  SuiShouJi
//
//  Created by old lang on 2017/8/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRecycleListCellItem.h"

@implementation SSJRecycleListCellItem

@synthesize recycleID;

+ (instancetype)itemWithRecycleID:(NSString *)recycleID
                             icon:(UIImage *)icon
                    iconTintColor:(UIColor *)iconTintColor
                            title:(NSString *)title
                        subtitles:(NSArray<NSString *> *)subtitles
                            state:(SSJRecycleListCellState)state {
    SSJRecycleListCellItem *item = [[SSJRecycleListCellItem alloc] init];
    item.recycleID = recycleID;
    item.icon = icon;
    item.iconTintColor = iconTintColor;
    item.title = title;
    item.subtitles = subtitles;
    item.state = state;
    return item;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return [self ssj_copyWithZone:zone];
}

@end
