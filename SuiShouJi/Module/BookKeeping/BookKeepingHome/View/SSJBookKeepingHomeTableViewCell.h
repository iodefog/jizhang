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

@property (nonatomic,strong) SSJBillingChargeCellItem *item;

@property (nonatomic, copy) void(^enterChargeDetailBlock)();

@property (nonatomic, copy) void(^imageClickBlock)(SSJBillingChargeCellItem *item);

@property (nonatomic) BOOL isLastRowOrNot;

@property(nonatomic) BOOL isAnimating;

//抖动动画
-(void)shake;

-(void)animatedShowCellWithDistance:(float)distance delay:(float)delay completion:(void (^ __nullable)())completion;

// 执行新增或者编辑流水的动画
- (void)performAddOrEditAnimation;

@end

NS_ASSUME_NONNULL_END
