//
//  SSJLoanListSectionHeaderAmountView.h
//  SuiShouJi
//
//  Created by old lang on 16/8/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJLoanListSectionHeaderAmountView : UIView

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *amount;

- (void)updateAppearance;

@end
