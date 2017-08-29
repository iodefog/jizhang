//
//  SSJRecycleListCellItem.h
//  SuiShouJi
//
//  Created by old lang on 2017/8/28.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"
#import "SSJRecycleCellItem.h"

typedef NS_ENUM(NSInteger, SSJRecycleListCellState) {
    SSJRecycleListCellStateNormal,
    SSJRecycleListCellStateExpanded,
    SSJRecycleListCellStateSelected,
    SSJRecycleListCellStateUnselected
};

@interface SSJRecycleListCellItem : SSJBaseCellItem <SSJRecycleCellItem, NSCopying>

@property (nonatomic, strong) UIImage *icon;

@property (nonatomic, strong) UIColor *iconTintColor;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSArray<NSString *> *subtitles;

@property (nonatomic) SSJRecycleListCellState state;

+ (instancetype)itemWithRecycleID:(NSString *)recycleID
                             icon:(UIImage *)icon
                    iconTintColor:(UIColor *)iconTintColor
                            title:(NSString *)title
                        subtitles:(NSArray<NSString *> *)subtitles
                            state:(SSJRecycleListCellState)state;

@end
