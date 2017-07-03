//
//  SSJClearDataCell.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSJClearDataCell : SSJBaseTableViewCell

@end

@interface SSJClearDataCellItem : SSJBaseCellItem

@property (nonatomic, copy, nullable) NSString *leftTitle;

@property (nonatomic, copy, nullable) NSString *rightTitle;

+ (instancetype)itemWithLeftTitle:(nullable NSString *)leftTitle rightTitle:(nullable NSString *)rightTitle;

@end

NS_ASSUME_NONNULL_END
