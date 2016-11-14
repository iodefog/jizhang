//
//  SSJChargeCircleTimeSelectView.h
//  SuiShouJi
//
//  Created by ricky on 16/6/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJChargeCircleTimeSelectView : UIView

@property (nonatomic, copy) void (^timerSetBlock)(NSString *dateStr);

@property (nonatomic, copy) void (^timeIsTooEarlyBlock)();

@property (nonatomic, copy) void (^timeIsTooLateBlock)();

@property(nonatomic, strong) NSDate *maxDate;

@property(nonatomic, strong) NSDate *minimumDate;

@property(nonatomic, strong) NSDate *currentDate;

-(void)show;
-(void)dismiss;
@end
