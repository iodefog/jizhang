//
//  SSJChargeReminderItem.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseItem.h"

@interface SSJChargeReminderItem : SSJBaseItem
@property (nonatomic) BOOL isOnOrNot;
@property (nonatomic,strong) NSString *timeString;
@property (nonatomic,strong) NSString *circleString;
@end
