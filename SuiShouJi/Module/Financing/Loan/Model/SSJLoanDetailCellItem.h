//
//  SSJLoanDetailCellItem.h
//  SuiShouJi
//
//  Created by old lang on 16/8/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

NS_ASSUME_NONNULL_BEGIN

@class SSJLoanChargeModel;

@interface SSJLoanDetailCellItem : SSJBaseItem

@property (nonatomic, copy) NSString *image;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, copy, nullable) NSAttributedString *bottomTitle;

@property (nonatomic, readonly) CGFloat cellHeight;

+ (instancetype)itemWithImage:(NSString *)image
                        title:(NSString *)title
                     subtitle:(NSString *)subtitle
                  bottomTitle:(nullable NSAttributedString *)bottomTitle;

+ (SSJLoanDetailCellItem *)cellItemWithChargeModel:(SSJLoanChargeModel *)model;

@end

NS_ASSUME_NONNULL_END
