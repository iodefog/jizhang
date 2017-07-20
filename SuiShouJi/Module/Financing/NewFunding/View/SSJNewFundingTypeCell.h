//
//  SSJNewFundingTypeCell.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
#import "SSJFinancingGradientColorItem.h"

SSJ_DEPRECATED
@interface SSJNewFundingTypeCell : SSJBaseTableViewCell

@property(nonatomic, strong) NSString *cellText;

@property (nonatomic,strong) UILabel *typeLabel;

@property (nonatomic,strong) UIView *colorView;

@property (nonatomic,strong) UIImageView *typeImage;

@property(nonatomic, strong) SSJFinancingGradientColorItem *colorItem;

@property(nonatomic, strong) NSString *cellImage;

@end
