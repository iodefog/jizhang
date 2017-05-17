//
//  SSJLoanDetailCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/8/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseCellItem.h"
#import "SSJLoanChargeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSJLoanDetailCellItem : SSJBaseCellItem

@property (nonatomic, copy) NSString *image;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, copy, nullable) NSAttributedString *bottomTitle;

/**
 在借贷详情的流水列表中，一个流水列表可能对应2个SSJLoanDetailCellItem，需要用过ID查找对应的流水模型
 */
@property (nonatomic, copy) NSString *chargeId;

@property (nonatomic) SSJLoanCompoundChargeType chargeType;

+ (instancetype)itemWithImage:(NSString *)image
                        title:(NSString *)title
                     subtitle:(NSString *)subtitle
                  bottomTitle:(nullable NSAttributedString *)bottomTitle;

+ (SSJLoanDetailCellItem *)cellItemWithChargeModel:(SSJLoanChargeModel *)model;

@end

NS_ASSUME_NONNULL_END
