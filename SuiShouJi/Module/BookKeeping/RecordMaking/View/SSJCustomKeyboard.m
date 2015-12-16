
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
        self.decimal = NO;
    }
    return self;
}


//数字键
-(void)setNumKey{
    for (int i = 0; i < 9; i ++) {
        SSJCustomKeyBoardButton *numButton = [[SSJCustomKeyBoardButton alloc]init];
        numButton.frame = CGRectMake(i % 3 * _buttonWight, i / 3 * _buttonHeight, _buttonWight, _buttonHeight);
        [numButton setTitle:[NSString stringWithFormat:@"%d",i + 1] forState:UIControlStateNormal];
        numButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [numButton setTintColor:[UIColor whiteColor]];
        [numButton addTarget:self action:@selector(NumKeyClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    SSJCustomKeyBoardButton *numButton = [[SSJCustomKeyBoardButton alloc]init];
    numButton.leftBottom = CGPointMake(_buttonWight,self.height);
    [numButton setTitle:@"0" forState:UIControlStateNormal];
    numButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [numButton setTintColor:[UIColor whiteColor]];
    [numButton addTarget:self action:@selector(NumKeyClicked:) forControlEvents:UIControlEventTouchUpInside];
}

//退格键
-(void)addBackspaceKey{
    SSJCustomKeyBoardButton *BackspaceButton = [[SSJCustomKeyBoardButton alloc]init];
    BackspaceButton.rightTop = CGPointMake(self.width,0);
    [BackspaceButton setTitle:@"return" forState:UIControlStateNormal];
    BackspaceButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [BackspaceButton setTintColor:[UIColor whiteColor]];
    [BackspaceButton addTarget:self action:@selector(BackspaceKeyClicked:) forControlEvents:UIControlEventTouchUpInside];
}

//清除键
-(void)addClearKey{
    SSJCustomKeyBoardButton *ClearButton = [[SSJCustomKeyBoardButton alloc]init];
    ClearButton.leftBottom = CGPointMake(_buttonWight * 2,self.height);
    [ClearButton setTitle:@"C" forState:UIControlStateNormal];
    ClearButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [ClearButton setTintColor:[UIColor whiteColor]];
    [ClearButton addTarget:self action:@selector(ClearKeyClicked:) forControlEvents:UIControlEventTouchUpInside];
}

//+键
-(void)addPlusKey{
    SSJCustomKeyBoardButton *PlusButton = [[SSJCustomKeyBoardButton alloc]init];
    PlusButton.leftBottom = CGPointMake(_buttonWight * 2,self.height);
    [PlusButton setTitle:@"+" forState:UIControlStateNormal];
    PlusButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [PlusButton setTintColor:[UIColor whiteColor]];
    [PlusButton addTarget:self action:@selector(PlusKeyClicked:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)addMinusKey{
    SSJCustomKeyBoardButton *MinusButton = [[SSJCustomKeyBoardButton alloc]init];
    MinusButton.leftBottom = CGPointMake(_buttonWight * 2,self.height);
    [MinusButton setTitle:@"-" forState:UIControlStateNormal];
    MinusButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [MinusButton setTintColor:[UIColor whiteColor]];
    [MinusButton addTarget:self action:@selector(MinusKeyClicked:) forControlEvents:UIControlEventTouchUpInside];
}

//小数点键
-(void)addDecimalKey{
    SSJCustomKeyBoardButton *DecimalButton = [[SSJCustomKeyBoardButton alloc]init];
    DecimalButton.leftBottom = CGPointMake(_buttonWight * 2,self.height);
    [DecimalButton setTitle:@"+" forState:UIControlStateNormal];
    DecimalButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [DecimalButton setTintColor:[UIColor whiteColor]];
    [DecimalButton addTarget:self action:@selector(DecimalKeyClicked:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)addComfirmKey{
    SSJCustomKeyBoardButton *ComfirmButton = [[SSJCustomKeyBoardButton alloc]init];
    ComfirmButton.leftBottom = CGPointMake(_buttonWight * 2,self.height);
    [ComfirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [ComfirmButton setTitle:@"=" forState:UIControlStateSelected];
    ComfirmButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [ComfirmButton setTintColor:[UIColor whiteColor]];
    [ComfirmButton addTarget:self action:@selector(ComfirmKeyClicked:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)NumKeyClicked:(UIButton*)button{
    [self.delegate didNumKeyPressed:button];
}

-(void)BackspaceKeyClicked:(UIButton*)button{
    [self.delegate didBackspaceKeyPressed];
}

-(void)ClearKeyClicked:(UIButton*)button{
    [self.delegate didClearKeyPressed];
}

-(void)DecimalKeyClicked:(UIButton*)button{
    self.decimal = ! self.decimal;
    [self.delegate didDecimalPointKeyPressed];
}

-(void)MinusKeyClicked:(UIButton*)button{
    [self.delegate didMinusKeyPressed];
}

-(void)PlusKeyClicked:(UIButton*)button{
    [self.delegate didPlusKeyPressed];
}

-(void)ComfirmKeyClicked:(UIButton*)button{
    [self.delegate didComfirmKeyPressed];
}
@end
