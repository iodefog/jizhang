//
//  SSJSyncSettingMultiLineCell.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJSyncSettingMultiLineCell : SSJBaseTableViewCell

@end

@interface SSJSyncSettingMultiLineCellItem : SSJBaseCellItem

@property (nonatomic, copy) NSString *topTitle;

@property (nonatomic, copy) NSString *bottomTitle;

+ (instancetype)itemWithTopTitle:(NSString *)topTitle bottomTitle:(NSString *)bottomTitle;

@end
