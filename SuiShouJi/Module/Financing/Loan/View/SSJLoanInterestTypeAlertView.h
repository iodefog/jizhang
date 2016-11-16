//
//  SSJLoanInterestTypeAlertView.h
//  SuiShouJi
//
//  Created by old lang on 16/11/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SSJLoanInterestTypeAlertViewButtonItem;

@interface SSJLoanInterestTypeAlertView : UIView

- (instancetype)initWithTitle:(nullable NSString *)title sureButtonItem:(nullable SSJLoanInterestTypeAlertViewButtonItem *)sureButtonItem otherButtonItem:(nullable SSJLoanInterestTypeAlertViewButtonItem *)otherButtonItem,...;

@end

typedef void(^SSJLoanInterestTypeAlertViewButtonAction)();

@interface SSJLoanInterestTypeAlertViewButtonItem : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, strong) UIColor *borderColor;

@property (nonatomic, strong) UIColor *fillColor;

@property (nonatomic, copy) SSJLoanInterestTypeAlertViewButtonAction action;

+ (instancetype)itemWithTitle:(NSString *)title
                   titleColor:(UIColor *)titleColor
                  borderColor:(UIColor *)borderColor
                    fillColor:(UIColor *)fillColor
                       action:(SSJLoanInterestTypeAlertViewButtonAction)action;

@end

NS_ASSUME_NONNULL_END
