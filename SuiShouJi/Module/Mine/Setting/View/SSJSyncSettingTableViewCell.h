//
//  SSJSyncSettingTableViewCell.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJBaseTableViewCell.h"

@interface SSJSyncSettingTableViewCell : SSJBaseTableViewCell

@end

@interface SSJSyncSettingTableViewCellItem : SSJBaseCellItem

@property (nonatomic, copy) NSString *title;

@property (nonatomic) UITableViewCellAccessoryType accessoryType;

+ (instancetype)itemWithTitle:(NSString *)title accessoryType:(UITableViewCellAccessoryType)accessoryType;

@end
