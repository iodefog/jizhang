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

typedef NS_ENUM(NSUInteger, SSJLoanInterestTypeAlertViewType) {
    SSJLoanInterestTypeAlertViewTypeOriginalPrincipal = SSJLoanInterestTypeOriginalPrincipal,
    SSJLoanInterestTypeAlertViewTypeChangePrincipal = SSJLoanInterestTypeChangePrincipal
};

@interface SSJLoanInterestTypeAlertView : UIView

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *originalPrincipalButtonTitle;

@property (nonatomic, copy) NSString *changePrincipalButtonTitle;

@property (nonatomic) SSJLoanInterestTypeAlertViewType interestType;

@property (nonatomic, copy) void (^sureAction)(SSJLoanInterestTypeAlertView *);

@end

NS_ASSUME_NONNULL_END
