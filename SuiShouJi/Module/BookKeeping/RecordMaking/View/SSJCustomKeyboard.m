
//
//  SSJCustomKeyboard.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/16.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCustomKeyboard.h"
#import "SSJCustomKeyBoardButton.h"

@interface SSJCustomKeyboard()
@property(nonatomic,weak)UITextField *textField;
@end

@implementation SSJCustomKeyboard{
    CGFloat _buttonHeight;
    CGFloat _buttonWight;
}


- (instancetype)initWithFrame:(CGRect)frame withTextField:(UITextField*)textField {
    if (self = [super initWithFrame:frame]) {
        self.textField = textField;
        _buttonHeight = self.height / 9;
        _buttonWight = self.width / 4;
    }
    return self;
}

-(void)setNumKey{
    for (int i = 0; i < 9; i ++) {
        SSJCustomKeyBoardButton *numButton = [[SSJCustomKeyBoardButton alloc]init];
        numButton.keyboardButtonType = KeyTypeNumKey;
        numButton.frame = CGRectMake(i % 3 * _buttonWight, i / 3 * _buttonHeight, _buttonWight, _buttonHeight);
    }
}

@end
