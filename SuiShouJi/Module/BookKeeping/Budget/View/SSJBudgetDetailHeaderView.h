//
//  SSJBudgetDetailHeaderView.h
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJBudgetDetailHeaderViewItem.h"
#import "SSJPercentCircleViewItem.h"

@interface SSJBudgetDetailHeaderView : UIView

@property (nonatomic, strong) SSJBudgetDetailHeaderViewItem *item;

@property (nonatomic, strong) NSArray <SSJPercentCircleViewItem *>*circleItems;

- (void)updateAppearance;

@end
