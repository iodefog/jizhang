//
//  SSJChargeCircleTimeSelectView.h
//  SuiShouJi
//
//  Created by ricky on 16/6/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJChargeCircleTimeSelectView : UIView
//选择时间回调
typedef void (^timerSetBlock)(NSString *dateStr);

@property (nonatomic, copy) timerSetBlock timerSetBlock;

@property(nonatomic, strong) NSDate *currentDate;

-(void)show;
-(void)dismiss;
@end
