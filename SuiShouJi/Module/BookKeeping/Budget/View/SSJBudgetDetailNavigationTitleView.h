//
//  SSJBudgetDetailNavigationTitleView.h
//  SuiShouJi
//
//  Created by old lang on 16/2/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SSJBudgetDetailNavigationTitleViewButtonAction)(void);

@interface SSJBudgetDetailNavigationTitleView : UIView

@property (nonatomic, strong, readonly) UILabel *titleLabel;

@property (nonatomic, strong, readonly) UIButton *preButton;

@property (nonatomic, strong, readonly) UIButton *nextButton;

@end
