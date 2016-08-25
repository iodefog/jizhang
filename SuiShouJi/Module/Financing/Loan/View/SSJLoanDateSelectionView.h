//
//  SSJLoanDateSelectionView.h
//  SuiShouJi
//
//  Created by old lang on 16/8/24.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJLoanDateSelectionView : UIView

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, copy) BOOL (^shouldSelectDateAction)(SSJLoanDateSelectionView *view, NSDate *date);

@property (nonatomic, copy) void (^selectDateAction)(SSJLoanDateSelectionView *view);

- (void)show;

- (void)dismiss;

@end
