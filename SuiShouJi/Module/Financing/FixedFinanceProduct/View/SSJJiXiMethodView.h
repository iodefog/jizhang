//
//  SSJJiXiMethodView.h
//  SuiShouJi
//
//  Created by yi cai on 2017/8/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJLoanFundAccountSelectionViewItem.h"

@interface SSJJiXiMethodView : UIView
/**
 选中的下标，默认是0，如果设置为负数，就没有选择任何item
 */
@property (nonatomic) NSInteger selectedIndex;

@property (nonatomic, strong) NSArray <SSJLoanFundAccountSelectionViewItem *>*items;

@property (nonatomic, copy) BOOL (^shouldSelectJiXiMethodAction)(SSJJiXiMethodView *view, NSUInteger index);

@property (nonatomic, copy) void (^selectJiXiMethodAction)(SSJJiXiMethodView *);

- (void)updateAppearance;

- (void)show;

- (void)dismiss;

@end
