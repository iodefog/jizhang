//
//  SSJReminderItem.m
//  SuiShouJi
//
//  Created by ricky on 16/8/18.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReminderItem.h"

@implementation SSJReminderItem

- (id)copyWithZone:(nullable NSZone *)zone {
    SSJReminderItem *item = [[SSJReminderItem alloc] init];
    item.remindId = self.remindId;
    item.remindName = self.remindName;
    item.remindMemo = self.remindMemo;
    item.remindContent = self.remindContent;
    item.remindCycle = self.remindCycle;
    item.remindType = self.remindType;
    item.remindDate = self.remindDate;
    item.remindState = self.remindState;
    item.remindAtTheEndOfMonth = self.remindAtTheEndOfMonth;
    item.minimumDate = self.minimumDate;
    item.borrowtarget = self.borrowtarget;
    item.borrowtOrLend = self.borrowtOrLend;
    return item;
}

@end
