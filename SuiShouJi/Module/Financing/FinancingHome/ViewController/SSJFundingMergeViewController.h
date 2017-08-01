//
//  SSJFundingMergeViewController.h
//  SuiShouJi
//
//  Created by 赵天立 on 2017/7/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"

@interface SSJFundingMergeViewController : SSJBaseViewController

@property (nonatomic, strong) SSJBaseCellItem *transferInFundItem;

@property (nonatomic, strong) SSJBaseCellItem *transferOutFundItem;

@property (nonatomic) BOOL transferInSelectable;

@property (nonatomic) BOOL transferOutSelectable;

@property (nonatomic) BOOL isCreditCardOrNot;


@end
