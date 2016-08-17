//
//  SSJNewFundingTableViewCell.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
#import "SSJFundingDetailItem.h"

@interface SSJModifyFundingTableViewCell : SSJBaseTableViewCell<UITextFieldDelegate>
@property (nonatomic,strong) UILabel *cellTitle;
@property (nonatomic,strong) UITextField *cellDetail;
@property (nonatomic,strong) UIView *colorView;
@property (nonatomic,strong) UILabel *typeTitle;
@property (nonatomic,strong) UIImageView *typeImage;

@end
