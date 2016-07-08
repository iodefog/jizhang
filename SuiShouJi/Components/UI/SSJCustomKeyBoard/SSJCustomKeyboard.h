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


//右操作数
@property (nonatomic) float rightNum;


//左操作数
@property (nonatomic) float leftNum;


//是否点击过数字按钮
@property (nonatomic) BOOL numKeyHasPressed;

//加减键是否被按过
@property (nonatomic) BOOL plusOrMinusKeyHasPressed;

//上一次点击的按钮
@property (nonatomic) NSInteger lastPressTag;

// 按键标题颜色，默认黑色
@property (nonatomic, strong) UIColor *titleColor;

// 按钮分割线颜色，默认黑色
@property (nonatomic, strong) UIColor *separatorColor;

@end



@interface NSObject (SSJCustomKeyboard)

- (void)textFieldDidBeginEditing:(UITextField *)textField;

- (void)textFieldDidEndEditing:(UITextField *)textField;

@end