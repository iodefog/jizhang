//
//  SSJBudgetEditUnitTextField.h
//  SuiShouJi
//
//  Created by old lang on 16/3/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SSJBudgetEditUnitTextFieldStyle) {
    SSJBudgetEditUnitTextFieldStyleLeft,
    SSJBudgetEditUnitTextFieldStyleRight
};

SSJ_DEPRECATED
@interface SSJBudgetEditUnitTextField : UITextField

@property (nonatomic, copy) NSString *unit;

@property (nonatomic) SSJBudgetEditUnitTextFieldStyle style;

@end
