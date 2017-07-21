//
//  SSJReminderEditeViewController.h
//  SuiShouJi
//
//  Created by ricky on 16/8/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "SSJReminderItem.h"

@interface SSJReminderEditeViewController : SSJBaseViewController

@property(nonatomic, copy) SSJReminderItem *item;

@property (nonatomic, copy) void (^addNewReminderAction)(SSJReminderItem *item);

@property (nonatomic, copy) void (^notSaveReminderAction)();


@property (nonatomic, copy) void (^deleteReminderAction)();

@property(nonatomic) BOOL needToSave;

@end
