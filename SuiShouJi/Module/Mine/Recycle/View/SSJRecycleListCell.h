//
//  SSJRecycleListCell.h
//  SuiShouJi
//
//  Created by old lang on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJRecycleListCell : SSJBaseTableViewCell

@end

@interface SSJRecycleListCellItem : SSJBaseCellItem

@property (nonatomic, strong) UIColor *iconTintColor;

@property (nonatomic, strong) UIImage *icon;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSArray<NSString *> *subtitles;

@property (nonatomic) BOOL expanded;

@end
