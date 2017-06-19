//
//  SSJCalenderDetailInfoCell.h
//  SuiShouJi
//
//  Created by old lang on 17/5/16.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@class SSJBillingChargeCellItem;

@interface SSJCalenderDetailInfoCell : SSJBaseTableViewCell

@end

@interface SSJCalenderDetailInfoCellItem : SSJBaseCellItem

@property (nonatomic, copy) NSString *leftText;

@property (nonatomic, copy) NSString *rightText;

@end

NS_ASSUME_NONNULL_END
