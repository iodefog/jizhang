//
//  SSJNewFundingViewController.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "SSJFinancingHomeitem.h"
#import "TPKeyboardAvoidingTableView.h"

SSJ_DEPRECATED
@interface SSJModifyFundingViewController : SSJBaseViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) SSJFinancingHomeitem *item;

@end
