//
//  SSJCustomKeyboard.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/16.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJCustomKeyBoardButton.h"

@protocol SSJCustomKeyboardDelegate <NSObject>
- (void)didNumKeyPressed:(UIButton *)button;
- (void)didDecimalPointKeyPressed;
- (void)didBackspaceKeyPressed;

@end
@interface SSJCustomKeyboard : UIView

//小数点模式
@property(nonatomic) BOOL decimalModel;

//加或者减模式 1为加,0为减
@property(nonatomic) BOOL PlusOrMinusModel;

@property(nonatomic,strong)SSJCustomKeyBoardButton *ComfirmButton;

@property(nonatomic, assign) id<SSJCustomKeyboardDelegate> delegate;

@end
