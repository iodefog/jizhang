//
//  SSJRecycleListCell.h
//  SuiShouJi
//
//  Created by old lang on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

typedef NS_ENUM(NSInteger, SSJRecycleListCellState) {
    SSJRecycleListCellStateNormal,
    SSJRecycleListCellStateExpanded,
    SSJRecycleListCellStateSelected,
    SSJRecycleListCellStateUnselected
};

@interface SSJRecycleListCell : SSJBaseTableViewCell

@property (nonatomic, copy) void(^expandBtnDidClick)(SSJRecycleListCell *cell);

@property (nonatomic, copy) void(^recoverBtnDidClick)(SSJRecycleListCell *cell);

@property (nonatomic, copy) void(^deleteBtnDidClick)(SSJRecycleListCell *cell);

@end

@interface SSJRecycleListCellItem : SSJBaseCellItem

@property (nonatomic, strong) UIImage *icon;

@property (nonatomic, strong) UIColor *iconTintColor;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSArray<NSString *> *subtitles;

@property (nonatomic) SSJRecycleListCellState state;

@property (nonatomic, copy) NSString *recycleID;

+ (instancetype)itemWithRecycleID:(NSString *)recycleID
                             icon:(UIImage *)icon
                    iconTintColor:(UIColor *)iconTintColor
                            title:(NSString *)title
                        subtitles:(NSArray<NSString *> *)subtitles
                            state:(SSJRecycleListCellState)state;

@end
