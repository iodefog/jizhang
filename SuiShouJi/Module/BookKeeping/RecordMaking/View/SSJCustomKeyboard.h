//
//  SSJCustomKeyboard.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/16.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SSJCustomKeyboardDelegate <NSObject>
- (void)didNumKeyPressed:(UIButton *)button;
- (void)didDecimalPointKeyPressed;
- (void)didClearKeyPressed;
- (void)didBackspaceKeyPressed;
- (void)didPlusKeyPressed;
- (void)didMinusKeyPressed;
- (void)didComfirmKeyPressed;

@end
@interface SSJCustomKeyboard : UIView

@property(nonatomic) BOOL decimal;
@property(nonatomic, assign) id<SSJCustomKeyboardDelegate> delegate;

@end
