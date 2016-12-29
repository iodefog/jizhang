//
//  SSJAddOrEditLoanMultiLabelCell.h
//  SuiShouJi
//
//  Created by old lang on 16/8/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJAddOrEditLoanMultiLabelCell : SSJBaseTableViewCell

@property (nonatomic, strong) UILabel *subtitleLabel;

@property (nonatomic, strong) UITextField *textField;
/**
 没有%
 */
@property (nonatomic, assign) BOOL haspercentLab;
@end
