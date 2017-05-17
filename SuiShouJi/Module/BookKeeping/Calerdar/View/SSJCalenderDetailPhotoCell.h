//
//  SSJCalenderDetailPhotoCell.h
//  SuiShouJi
//
//  Created by old lang on 17/5/16.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@class SSJBillingChargeCellItem;

@interface SSJCalenderDetailPhotoCell : SSJBaseTableViewCell

@end

@interface SSJCalenderDetailPhotoCellItem : SSJBaseCellItem

@property (nonatomic, copy) NSURL *photoPath;

@end

NS_ASSUME_NONNULL_END
