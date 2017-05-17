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

typedef void(^beginEditeBtnClickBlock)(SSJBookKeepingHomeTableViewCell *cell);

typedef void(^editeBtnClickBlock)(SSJBookKeepingHomeTableViewCell *cell);

typedef void(^deleteButtonClickBlock)();

typedef void(^imageClickBlock)(SSJBillingChargeCellItem *item);



@interface SSJBookKeepingHomeTableViewCell : SSJBaseTableViewCell

@property (nonatomic,strong) SSJBillingChargeCellItem *item;

@property (nonatomic, copy) beginEditeBtnClickBlock beginEditeBtnClickBlock;

@property (nonatomic, copy) editeBtnClickBlock editeBtnClickBlock;

@property (nonatomic, copy) deleteButtonClickBlock deleteButtonClickBlock;

@property (nonatomic, copy) imageClickBlock imageClickBlock;

@property (nonatomic) BOOL isEdite;

@property (nonatomic) BOOL isLastRowOrNot;

@property (nonatomic,strong) UILabel *incomeLabel;

@property (nonatomic,strong) UILabel *expenditureLabel;

@property (nonatomic,strong) UILabel *incomeMemoLabel;

@property (nonatomic,strong) UILabel *expentureMemoLabel;

@property (nonatomic,strong) UIImageView *IncomeImage;

@property (nonatomic,strong) UIImageView *expentureImage;

@property (nonatomic,strong) UIButton *categoryImageButton;

@property(nonatomic, strong) UIView *dotView;

@property(nonatomic) BOOL isAnimating;

//抖动动画
-(void)shake;

-(void)animatedShowCellWithDistance:(float)distance delay:(float)delay completion:(void (^ __nullable)())completion;

@end

NS_ASSUME_NONNULL_END
