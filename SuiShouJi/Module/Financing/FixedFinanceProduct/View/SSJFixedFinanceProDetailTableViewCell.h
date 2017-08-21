//
//  SSJFixedFinanceProDetailTableViewCell.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
#import "SSJSegmentedControl.h"

@interface SSJFixedFinanceProDetailTableViewCell : SSJBaseTableViewCell

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) SSJSegmentedControl *segmentControl;

@property (nonatomic, strong) UIImageView *leftImageView;

@property (nonatomic, strong) UILabel *nameL;

@property (nonatomic, strong) UILabel *subNameL;

@property (nonatomic, strong) UILabel *percentageL;


/**是否有百分号*/
@property (nonatomic, assign) BOOL hasPercentageL;

/**<#注释#>*/
@property (nonatomic, assign) NSInteger segmentSelectedIndex;

@end
