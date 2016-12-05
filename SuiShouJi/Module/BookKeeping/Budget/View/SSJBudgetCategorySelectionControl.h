//
//  SSJBudgetCategorySelectionControl.h
//  SuiShouJi
//
//  Created by old lang on 16/12/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJListMenu.h"

typedef NS_ENUM(NSUInteger, SSJBudgetCategorySelectionControlOption) {
    SSJBudgetCategorySelectionControlOptionMajor,
    SSJBudgetCategorySelectionControlOptionSecondary
};

@interface SSJBudgetCategorySelectionControl : UIControl

@property (nonatomic) SSJBudgetCategorySelectionControlOption option;

@property (nonatomic, strong, readonly) SSJListMenu *listMenu;

- (void)updateAppearance;

@end
