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
#import "SSJBillingChargeCellItem.h"

@interface SSJRecordMakingViewController : SSJBaseViewController<UIScrollViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>

//当前选中的年
@property (nonatomic) long selectedYear;

//当前选中的月
@property (nonatomic) long selectedMonth;

//当前选中的日
@property (nonatomic) long selectedDay;

//流水item(item为空位新建,有值为修改)
@property (nonatomic,strong) SSJBillingChargeCellItem *item;

@end
