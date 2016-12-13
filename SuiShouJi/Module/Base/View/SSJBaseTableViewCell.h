//
//  SSJBaseTableViewCell.h
//  MoneyMore
//
//  Created by old lang on 15-3-23.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJBaseItem.h"

@interface SSJBaseTableViewCell : UITableViewCell

@property (nonatomic, strong) __kindof SSJBaseItem *cellItem;

@property (nonatomic) UITableViewCellAccessoryType customAccessoryType;

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object;

/**
 *  切换主题后调用的方法，子类根据情况重写，必须调用父类方法
 */ 
- (void)updateCellAppearanceAfterThemeChanged;

@end
