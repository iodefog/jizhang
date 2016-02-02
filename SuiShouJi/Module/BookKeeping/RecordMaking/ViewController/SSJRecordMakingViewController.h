//
//  SSJRecordMakingViewController.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/16.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

//记一笔页面
#import "SSJBaseViewController.h"
#import "SSJCustomKeyboard.h"
#import "SSJBookKeepHomeItem.h"

@interface SSJRecordMakingViewController : SSJBaseViewController<SSJCustomKeyboardDelegate,UIScrollViewDelegate,UITextFieldDelegate>
@property (nonatomic) long selectedYear;
@property (nonatomic) long selectedMonth;
@property (nonatomic) long selectedDay;

//流水item(item为空位新建,有值为修改)
@property (nonatomic,strong) SSJBookKeepHomeItem *item;

@end
