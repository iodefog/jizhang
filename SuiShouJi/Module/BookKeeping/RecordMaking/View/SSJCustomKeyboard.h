//
//  SSJCustomKeyboard.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/16.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJCustomKeyBoardButton.h"

@interface SSJCustomKeyboard : UIView

+ (SSJCustomKeyboard *)sharedInstance;

//小数点模式
@property(nonatomic) BOOL decimalModel;

//加或者减模式 1为加,0为减
@property(nonatomic) BOOL PlusOrMinusModel;

@property(nonatomic,strong)SSJCustomKeyBoardButton *ComfirmButton;


@property (nonatomic, weak) UITextField *textField;

@end



@interface NSObject (SSJCustomKeyboard)

- (void)textFieldDidBeginEditing:(UITextField *)textField;

@end