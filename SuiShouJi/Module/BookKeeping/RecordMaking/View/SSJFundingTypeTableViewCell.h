//
//  SSJFundingTypeTableViewCell.h
//  SuiShouJi
//
//  Created by ricky on 15/12/23.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"
#import "SSJFinancingHomeitem.h"

@interface SSJFundingTypeTableViewCell : SSJBaseTableViewCell

//是否选中
@property (nonatomic) BOOL selectedOrNot;

@property (nonatomic,strong) SSJFinancingHomeitem *item;

@property (nonatomic,strong) NSString *cellTitle;

@end
