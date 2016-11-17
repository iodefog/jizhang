//
//  SSJLoanInterestTypeAlertView.h
//  SuiShouJi
//
//  Created by old lang on 16/11/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJLoanModel.h"

NS_ASSUME_NONNULL_BEGIN

@class SSJLoanInterestTypeAlertViewButtonItem;

@interface SSJLoanInterestTypeAlertView : UIView

@property (nonatomic) SSJLoginType type;

@property (nonatomic) SSJLoanInterestType interestType;

@property (nonatomic) double money;

@end

NS_ASSUME_NONNULL_END
