//
//  SSJReminderDateSelectView.h
//  SuiShouJi
//
//  Created by ricky on 16/8/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJReminderDateSelectView : UIView

@property(nonatomic, strong) NSDate *currentDate;

@property (nonatomic, copy) void (^dateSetBlock)(NSDate *date);

@property(nonatomic, strong) NSDate *minmumDate;

-(void)show;

-(void)dismiss;
@end
