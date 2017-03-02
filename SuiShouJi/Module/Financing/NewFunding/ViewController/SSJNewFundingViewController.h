//
//  SSJNewFundingViewController.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "SSJFundingItem.h"
#import "SSJFinancingGradientColorItem.h"

@interface SSJNewFundingViewController : SSJBaseViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

typedef void (^addNewFundBlock)(SSJFundingItem *newFundingItem);

@property(nonatomic,copy) addNewFundBlock addNewFundBlock;

@property(nonatomic,copy) NSString *selectParent;

@property(nonatomic,copy) SSJFinancingGradientColorItem *selectColor;

@property(nonatomic,copy) NSString *selectIcoin;

@end
