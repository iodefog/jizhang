//
//  SSJChargeCircleModifyCell.h
//  SuiShouJi
//
//  Created by ricky on 16/6/2.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJChargeCircleModifyCell : SSJBaseTableViewCell
@property(nonatomic, strong) UITextField * cellInput;
@property(nonatomic, strong) UILabel *cellTitleLabel;
@property(nonatomic, strong) UILabel *cellSubTitleLabel;

@property(nonatomic, strong) NSString *cellTitle;
@property(nonatomic, strong) NSString *cellDetail;
@property(nonatomic, strong) NSString *cellSubTitle;
@property(nonatomic, strong) NSString *cellImage;
@end
