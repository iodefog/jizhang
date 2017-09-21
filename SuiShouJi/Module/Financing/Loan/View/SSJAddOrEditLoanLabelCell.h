//
//  SSJAddOrEditLoanCell.h
//  SuiShouJi
//
//  Created by old lang on 16/8/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJAddOrEditLoanLabelCell : SSJBaseTableViewCell

@property (nonatomic, strong) UIImageView *additionalIcon;

@property (nonatomic, strong) UILabel *subtitleLabel;

@property (nonatomic, strong) UISwitch *switchControl;

@property (nonatomic, strong) UILabel *descLabel;

/**是否是固收理财*/
@property (nonatomic, assign) BOOL isProduct;
@end
