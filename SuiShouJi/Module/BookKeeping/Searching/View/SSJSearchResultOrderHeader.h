//
//  SSJSearchResultOrderHeader.h
//  SuiShouJi
//
//  Created by ricky on 16/9/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJSearchResultItem.h"
#import "SSJSearchResultSummaryItem.h"

@interface SSJSearchResultOrderHeader : UIView

@property(nonatomic) SSJChargeListOrder order;

@property(nonatomic,strong) SSJSearchResultSummaryItem *sumItem;

@property (nonatomic, copy) void(^orderSelectBlock)(SSJChargeListOrder order);

@end
