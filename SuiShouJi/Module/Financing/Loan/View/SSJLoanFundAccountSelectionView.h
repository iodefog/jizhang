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

/**
 选中的下标，默认是0，如果设置为负数，就没有选择任何item
 */
@property (nonatomic) NSInteger selectedIndex;

@property (nonatomic, strong) NSArray <SSJLoanFundAccountSelectionViewItem *>*items;

@property (nonatomic, copy) BOOL (^shouldSelectAccountAction)(SSJLoanFundAccountSelectionView *view, NSUInteger index);

@property (nonatomic, copy) void (^selectAccountAction)(SSJLoanFundAccountSelectionView *);

/**标题*/
@property (nonatomic, copy) NSString *title;

- (void)updateAppearance;

- (void)show;

- (void)dismiss;

@end
