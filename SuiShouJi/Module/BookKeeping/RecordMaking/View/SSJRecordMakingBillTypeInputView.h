//
//  SSJRecordMakingBillTypeInputView.h
//  SuiShouJi
//
//  Created by old lang on 16/5/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJRecordMakingBillTypeInputView : UIView

@property (nonatomic, copy) NSString *billTypeName;

@property (nonatomic, strong, readonly) UITextField *moneyInput;

@property (nonatomic, strong) UIColor *fillColor;

@end
