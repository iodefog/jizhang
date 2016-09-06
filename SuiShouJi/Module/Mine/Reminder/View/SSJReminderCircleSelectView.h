//
//  SSJReminderCircleSelectView.h
//  SuiShouJi
//
//  Created by ricky on 16/9/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJReminderCircleSelectView : UIView

@property (nonatomic) NSInteger selectCircleType;

@property (nonatomic) BOOL incomeOrExpenture;

@property(nonatomic, strong) NSString *title;

//点击按钮的回调
typedef void (^chargeCircleSelectBlock)(NSInteger chargeCircleType);


@property(nonatomic, copy) chargeCircleSelectBlock chargeCircleSelectBlock;

@property (nonatomic, copy) BOOL (^shouldDismissWhenSureButtonClick)(SSJReminderCircleSelectView *);

@property (nonatomic, copy) void (^dismissAction)(SSJReminderCircleSelectView *);


- (void)show;

- (void)dismiss;

@end
