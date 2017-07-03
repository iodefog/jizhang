//
//  SSJSyncSettingMultiLineCell.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSJSyncSettingMultiLineCell : SSJBaseTableViewCell

@end

@interface SSJSyncSettingMultiLineCellItem : SSJBaseCellItem

@property (nonatomic, copy, nullable) NSString *topTitle;

@property (nonatomic, copy, nullable) NSString *bottomTitle;

+ (instancetype)itemWithTopTitle:(nullable NSString *)topTitle bottomTitle:(nullable NSString *)bottomTitle;

@end

NS_ASSUME_NONNULL_END
