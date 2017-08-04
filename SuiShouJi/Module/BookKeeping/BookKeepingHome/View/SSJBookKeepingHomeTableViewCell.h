//
//  SSJBookKeepingHomeTableViewCell.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/15.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
#import "SSJBillingChargeCellItem.h"

NS_ASSUME_NONNULL_BEGIN

@class SSJBookKeepingHomeTableViewCell;

@interface SSJBookKeepingHomeTableViewCell : SSJBaseTableViewCell

@property (nonatomic, strong) SSJBillingChargeCellItem *item;

@property (nonatomic, copy) void(^enterChargeDetailBlock)(SSJBookKeepingHomeTableViewCell *cell);

@property (nonatomic, copy) void(^imageClickBlock)(SSJBillingChargeCellItem *item);

@property (nonatomic, copy) void(^editBlock)(SSJBookKeepingHomeTableViewCell *cell);

@property (nonatomic, copy) void(^deleteBlock)(SSJBookKeepingHomeTableViewCell *cell);

@property (nonatomic) BOOL isLastRow;

@property (nonatomic) BOOL isAnimating;

@property (nonatomic, readonly) BOOL editAndDeleteBtnShowed;

- (void)animatedShowCellWithDistance:(float)distance delay:(float)delay completion:(void (^ __nullable)())completion;

// 执行新增或者编辑流水的动画
- (void)performAddOrEditAnimation;

@end


@interface SSJBillingChargeCellItem (SSJBookKeepingHomeTableViewCell)

/**
 展开状态
 */
@property (nonatomic) BOOL expanded;

@end

NS_ASSUME_NONNULL_END
