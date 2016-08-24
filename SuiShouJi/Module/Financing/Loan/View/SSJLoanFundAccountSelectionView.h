//
//  SSJLoanFundAccountSelectionView.h
//  SuiShouJi
//
//  Created by old lang on 16/8/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJLoanFundAccountSelectionViewItem.h"

@interface SSJLoanFundAccountSelectionView : UIView

@property (nonatomic) NSUInteger selectedIndex;

@property (nonatomic, strong) NSArray <SSJLoanFundAccountSelectionViewItem *>*items;

@property (nonatomic, copy) BOOL (^shouldSelectAccountAction)(SSJLoanFundAccountSelectionView *view, NSUInteger index);

@property (nonatomic, copy) void (^selectAccountAction)(SSJLoanFundAccountSelectionView *);

- (void)updateAppearance;

- (void)show;

- (void)dismiss;

@end
