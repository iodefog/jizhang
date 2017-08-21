//
//  SSJFixedFinanceProDetailTableViewCell.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJFixedFinanceProDetailTableViewCell : SSJBaseTableViewCell
@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UISegmentedControl *segmentControl;

/**是否有百分号*/
@property (nonatomic, assign) BOOL hasPercentageL;

@end
