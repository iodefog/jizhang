//
//  SSJForgetPasswordSecondStepViewController.h
//  SuiShouJi
//
//  Created by old lang on 16/1/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBaseViewController.h"
#import "UIViewController+SSJPageFlow.h"

SSJ_DEPRECATED
@interface SSJForgetPasswordSecondStepViewController : SSJBaseViewController

@property (nonatomic, copy) NSString *mobileNo;

@property (nonatomic, copy) NSString *authCode;

@end
