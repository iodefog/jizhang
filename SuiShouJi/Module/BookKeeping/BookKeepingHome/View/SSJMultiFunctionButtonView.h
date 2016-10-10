//
//  SSJMultiFunctionButton.h
//  SuiShouJi
//
//  Created by ricky on 16/9/28.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJMultiFunctionButtonView : UIView

@property (nonatomic, copy) void(^dismissBlock)();

@property (nonatomic, copy) void(^showBlock)();

//0为收起,1为展开
@property(nonatomic) BOOL buttonStatus;

- (void)show;

- (void)dismiss;

@end

@protocol SSJMultiFunctionButtonDelegate

//  将要选中某个按钮后触发的回调，index：选中按钮的下标
- (void)slidePagingHeaderView:(SSJMultiFunctionButtonView *)headerView willSelectButtonAtIndex:(NSUInteger)index;

@end
