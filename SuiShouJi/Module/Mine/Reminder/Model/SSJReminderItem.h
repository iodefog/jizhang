//
//  SSJReminderItem.h
//  SuiShouJi
//
//  Created by ricky on 16/8/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJReminderItem : NSObject

// 提醒id
@property(nonatomic, strong) NSString *remindId;

// 提醒名称
@property(nonatomic, strong) NSString *remindName;

// 提醒备注
@property(nonatomic, strong) NSString *remindMemo;

// 提醒内容
@property(nonatomic, strong) NSString *remindContent;

// 提醒周期(0为每天,1为工作日,2为每周末,3为每周,4为每月,5为每月最后一天,6为每年,7为仅一次)
@property(nonatomic) NSInteger remindCycle;

// 提醒类别(0为其他,1为记账,2为信用卡,3为借贷)
@property(nonatomic) NSInteger remindType;

// 提醒时间
@property(nonatomic, strong) NSString *remindDate;

// 提醒开关(0为关闭,1为开启)
@property(nonatomic) BOOL remindState;

// 月末是否开启提醒(0为关闭,1为开启)
@property(nonatomic) BOOL remindAtTheEndOfMonth;

// 提醒对应的资金帐户id
@property(nonatomic, strong) NSString *remindFundid;

@end
