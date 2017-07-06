//
//  SSJLoginPhoneViewController.h
//  SuiShouJi
//
//  Created by yi cai on 2017/6/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJLoginCommonViewController.h"

@class SSJLoginVerifyPhoneNumViewModel;
@interface SSJLoginPhoneViewController : SSJLoginCommonViewController

/**phone*/
@property (nonatomic, copy) NSString *phoneNum;
@end
