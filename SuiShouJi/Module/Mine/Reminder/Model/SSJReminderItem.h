//
//  SSJReminderItem.h
//  SuiShouJi
//
//  Created by ricky on 16/8/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJReminderItem : SSJBaseCellItem<NSCopying>

// 提醒id
@property(nonatomic, copy) NSString *remindId;

// 提醒名称
@property(nonatomic, copy) NSString *remindName;

// 提醒备注
@property(nonatomic, copy) NSString *remindMemo;

// 提醒内容
@property(nonatomic, copy) NSString *remindContent;

// 提醒周期(0为每天,1为工作日,2为每周末,3为每周,4为每月,5为每月最后一天,6为每年,7为仅一次)
@property(nonatomic) NSInteger remindCycle;

// 提醒类别(0为其他,1为记账,2为信用卡,3为借贷,4愿望提醒)
@property(nonatomic) SSJReminderType remindType;

// 提醒时间
@property(nonatomic, copy) NSDate *remindDate;

// 提醒开关(0为关闭,1为开启)
@property(nonatomic) BOOL remindState;

// 月末是否开启提醒(0为关闭,1为开启)
@property(nonatomic) BOOL remindAtTheEndOfMonth;


// 最小的时间,对于借贷来说最小时间不能早于借贷的日期
@property(nonatomic, copy) NSDate *minimumDate;

// 借贷的对象
@property(nonatomic, copy) NSString *borrowtarget;

// 借入还是借出,0是借入,1是借出
@property(nonatomic) BOOL borrowtOrLend;

// 借贷的对象
@property(nonatomic, copy) NSString *userId;

// 提醒所对应的资金账户id
@property(nonatomic, copy) NSString *fundId;

@end
