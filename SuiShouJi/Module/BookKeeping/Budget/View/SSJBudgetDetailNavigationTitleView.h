//
//  SSJBudgetDetailNavigationTitleView.h
//  SuiShouJi
//
//  Created by old lang on 16/2/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SSJBudgetDetailNavigationTitleViewButtonAction)(void);

@interface SSJBudgetDetailNavigationTitleView : UIControl

@property (nonatomic) NSUInteger currentIndex;

- (void)setTitles:(NSArray *)titles;

- (void)setButtonShowed:(BOOL)showed;

@end
