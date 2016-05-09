//
//  SSJRecordMakingBillTypeInputView.h
//  SuiShouJi
//
//  Created by old lang on 16/5/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJRecordMakingBillTypeInputAccessoryView.h"

@interface SSJRecordMakingBillTypeInputView : UIView

@property (nonatomic, copy) NSString *billTypeName;

@property (nonatomic, copy) NSString *money;

@property (nonatomic, strong, readonly) SSJRecordMakingBillTypeInputAccessoryView *accessoryView;

- (void)becomeFirstResponder;

- (void)resignFirstResponder;

@end
