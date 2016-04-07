//
//  SSJChargeReminderTimeView.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJChargeReminderTimeView : UIView
//选择时间回调
typedef void (^timerSetBlock)(NSString *time , NSDate *date);

@property (nonatomic, copy) timerSetBlock timerSetBlock;

-(void)show;
-(void)dismiss;
@end
