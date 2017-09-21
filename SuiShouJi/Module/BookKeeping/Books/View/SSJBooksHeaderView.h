//
//  SSJBooksHeaderView.h
//  SuiShouJi
//
//  Created by ricky on 16/11/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJBooksHeaderView : UIView

@property (nonatomic, copy) void(^buttonClickBlock)();

// 收入
@property(nonatomic) double income;

// 支出
@property(nonatomic) double expenture;

- (void)updateAfterThemeChange;

@end
