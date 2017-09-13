//
//  SSJFundingMergeViewController.h
//  SuiShouJi
//
//  Created by 赵天立 on 2017/7/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "SSJFundAccountMergeHelper.h"
#import "SSJFinancingHomeitem.h"

@interface SSJFundingMergeViewController : SSJBaseViewController

@property (nonatomic, strong) SSJFinancingHomeitem *transferInFundItem;

@property (nonatomic, strong) SSJFinancingHomeitem *transferOutFundItem;

@property (nonatomic) BOOL transferInSelectable;

@property (nonatomic) BOOL transferOutSelectable;

@property (nonatomic) BOOL needToDelete;

@property (nonatomic) SSJFundsTransferType transferInType;

@property (nonatomic) SSJFundsTransferType transferOutType;

@end
