//
//  SSJFingerprintPWDViewController.h
//  SuiShouJi
//
//  Created by old lang on 2017/6/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

//  指纹密码

#import "SSJBaseViewController.h"
#import "UIViewController+SSJPageFlow.h"

@class LAContext;

@interface SSJFingerprintPWDViewController : SSJBaseViewController

@property (nonatomic, strong) LAContext *context;

@end
