//
//  SSJFundingParentSelectHeader.h
//  SuiShouJi
//
//  Created by ricky on 2017/8/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJFundingTypeManager.h"

@interface SSJFundingParentSelectHeader : UITableViewHeaderFooterView

@property (nonatomic, strong) SSJFundingParentmodel *model;

@property (nonatomic, copy) void(^didSelectFundParentHeader)(SSJFundingParentmodel *model);

@end
