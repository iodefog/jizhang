//
//  SSJTextFieldAddition.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJTextFieldToolbarManager : NSObject

- (void)installTextFieldToolbar:(UITextField *)textField;

- (void)uninstallTextFieldToolbar:(UITextField *)textField;

- (void)uninstallAllTextFieldToolbar;

@end

@interface UITextField (SSJToolbar)

- (void)ssj_setOrder:(NSUInteger)order;

- (NSUInteger)ssj_order;

@end
