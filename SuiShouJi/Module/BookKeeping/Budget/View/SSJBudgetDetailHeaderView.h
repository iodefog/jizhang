//
//  SSJBudgetDetailHeaderView.h
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJBudgetDetailHeaderViewItem.h"

@interface SSJBudgetDetailHeaderView : UIView

@property (nonatomic, strong) SSJBudgetDetailHeaderViewItem *item;

- (void)updateAppearance;

@end
