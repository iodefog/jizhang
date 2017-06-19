//
//  SSJCalenderTableViewCell.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@class SSJBillingChargeCellItem;

@interface SSJCalenderTableViewCell : SSJBaseTableViewCell

@end

@interface SSJCalenderTableViewCellItem : SSJBaseCellItem

@property (nonatomic, copy) UIImage *billImage;

@property (nonatomic, strong) UIColor *billColor;

@property (nonatomic, copy) NSString *billName;

@property (nonatomic, copy) NSString *money;

@end

NS_ASSUME_NONNULL_END
