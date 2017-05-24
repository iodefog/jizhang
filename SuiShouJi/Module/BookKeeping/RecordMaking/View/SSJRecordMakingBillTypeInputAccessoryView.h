//
//  SSJRecordMakingBillTypeInputAccessoryView.h
//  SuiShouJi
//
//  Created by old lang on 16/5/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJButton.h"

@class SSJRecordMakingBillTypeInputAccessoryView;

@interface SSJRecordMakingBillTypeInputAccessoryView : UIView

@property (nonatomic, strong, readonly) UITextField *memoView;

@property (nonatomic, strong, readonly) SSJButton *accountBtn;

@property (nonatomic, strong, readonly) SSJButton *dateBtn;

@property (nonatomic, strong, readonly) SSJButton *photoBtn;

@property (nonatomic, strong, readonly) SSJButton *memberBtn;

- (void)updateAppearance;

@end
