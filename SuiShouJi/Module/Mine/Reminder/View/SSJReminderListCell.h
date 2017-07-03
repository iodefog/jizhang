//
//  SSJCreditCardListCell.h
//  SuiShouJi
//
//  Created by ricky on 16/8/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseTableViewCell.h"

@interface SSJReminderListCell : SSJBaseTableViewCell

@property (nonatomic, copy) void (^switchAction)(SSJReminderListCell *cell,UISwitch *switchAction);

@end
