//
//  SSJRecordMakingBillTypeInputAccessoryView.h
//  SuiShouJi
//
//  Created by old lang on 16/5/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSJRecordMakingBillTypeInputAccessoryView;

@interface SSJRecordMakingBillTypeInputAccessoryView : UIView

@property (nonatomic, strong, readonly) UITextField *memoView;

@property (nonatomic, strong, readonly) UIButton *accountBtn;

@property (nonatomic, strong, readonly) UIButton *dateBtn;

@property (nonatomic, strong, readonly) UIButton *photoBtn;

@property (nonatomic, strong, readonly) UIButton *periodBtn;

@property (nonatomic, strong) UIColor *buttonTitleNormalColor;

@property (nonatomic, strong) UIColor *buttonTitleSelectedColor;

@end
