
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
@property(nonatomic,strong)SSJCustomKeyBoardButton *BackspaceButton;
@property(nonatomic,strong)SSJCustomKeyBoardButton *ClearButton;
@property(nonatomic,strong)SSJCustomKeyBoardButton *PlusButton;
@property(nonatomic,strong)SSJCustomKeyBoardButton *MinusButton;
@property(nonatomic,strong)SSJCustomKeyBoardButton *DecimalButton;
@property(nonatomic,strong)SSJCustomKeyBoardButton *ComfirmButton;
@property(nonatomic,strong)SSJCustomKeyBoardButton *ZeroButton;
@property(nonatomic,strong)NSMutableArray *numButtonArray;

@end

@implementation SSJCustomKeyboard{
    CGFloat _buttonHeight;
    CGFloat _buttonWight;
}


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
//        self.backgroundColor = [UIColor redColor];
        _buttonHeight = self.height / 4;
        _buttonWight = self.width / 4;
        self.decimal = NO;
        self.numButtonArray = [[NSMutableArray alloc]init];
        [self setNumKey];
    }
    return self;
}

-(void)layoutSubviews{
    for (int i = 0; i < 9; i ++) {
        ((SSJCustomKeyBoardButton*)([self.numButtonArray objectAtIndex:i])).frame = CGRectMake(i % 3 * _buttonWight, i / 3 * _buttonHeight, _buttonWight, _buttonHeight);
    }
    self.ClearButton.leftBottom = CGPointMake(0, self.bottom);
    self.ClearButton.size = CGSizeMake(_buttonWight, _buttonHeight);
    self.ZeroButton.leftBottom = CGPointMake(self.ClearButton.right, self.bottom);
    self.ZeroButton.size = CGSizeMake(_buttonWight, _buttonHeight);
    self.DecimalButton.leftBottom = CGPointMake(self.ZeroButton.right, self.bottom);
    self.DecimalButton.size = CGSizeMake(_buttonWight, _buttonHeight);
    self.BackspaceButton.rightTop = CGPointMake(self.right, 0);
    self.BackspaceButton.size = CGSizeMake(_buttonWight, _buttonHeight);
    self.PlusButton.rightTop = CGPointMake(self.right, self.BackspaceButton.bottom);
    self.PlusButton.size = CGSizeMake(_buttonWight, _buttonHeight);
    self.MinusButton.rightTop = CGPointMake(self.right, self.PlusButton.bottom);
    self.MinusButton.size = CGSizeMake(_buttonWight, _buttonHeight);
    self.ComfirmButton.rightBottom = CGPointMake(self.right, self.bottom);
    self.ComfirmButton.size = CGSizeMake(_buttonWight, _buttonHeight);

}

//数字键
-(void)setNumKey{
    for (int i = 0; i < 9; i ++) {
        SSJCustomKeyBoardButton *numButton = [[SSJCustomKeyBoardButton alloc]init];
        [numButton setTitle:[NSString stringWithFormat:@"%d",i + 1] forState:UIControlStateNormal];
        numButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [numButton setTintColor:[UIColor whiteColor]];
        [numButton addTarget:self action:@selector(NumKeyClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.numButtonArray addObject:numButton];
        [self addSubview:numButton];
    }

}

-(SSJCustomKeyBoardButton*)ZeroButton{
    if (!_ZeroButton) {
        _ZeroButton = [[SSJCustomKeyBoardButton alloc]init];
        _ZeroButton.leftBottom = CGPointMake(_buttonWight,self.height);
        [_ZeroButton setTitle:@"0" forState:UIControlStateNormal];
        _ZeroButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_ZeroButton setTintColor:[UIColor whiteColor]];
        [_ZeroButton addTarget:self action:@selector(NumKeyClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_ZeroButton];
    }
    return _ZeroButton;
}

//退格键
-(SSJCustomKeyBoardButton*)BackspaceButton{
    if (!_BackspaceButton) {
        _BackspaceButton = [[SSJCustomKeyBoardButton alloc]init];
        _BackspaceButton.rightTop = CGPointMake(self.width,0);
        [_BackspaceButton setTitle:@"return" forState:UIControlStateNormal];
        _BackspaceButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_BackspaceButton setTintColor:[UIColor whiteColor]];
        [_BackspaceButton addTarget:self action:@selector(BackspaceKeyClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_BackspaceButton];
    }
    return _BackspaceButton;
}

//清除键
-(SSJCustomKeyBoardButton*)ClearButton{
    if (!_ClearButton) {
        _ClearButton = [[SSJCustomKeyBoardButton alloc]init];
        [_ClearButton setTitle:@"C" forState:UIControlStateNormal];
        _ClearButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_ClearButton setTintColor:[UIColor whiteColor]];
        [_ClearButton addTarget:self action:@selector(ClearKeyClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_ClearButton];

    }
    return _ClearButton;
}

//+键
-(SSJCustomKeyBoardButton*)PlusButton{
    if (!_PlusButton) {
        _PlusButton = [[SSJCustomKeyBoardButton alloc]init];
        _PlusButton.leftBottom = CGPointMake(_buttonWight * 2,self.height);
        [_PlusButton setTitle:@"+" forState:UIControlStateNormal];
        _PlusButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_PlusButton setTintColor:[UIColor whiteColor]];
        [_PlusButton addTarget:self action:@selector(PlusKeyClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_PlusButton];

    }
    return _PlusButton;
}

-(SSJCustomKeyBoardButton*)MinusButton{
    if (!_MinusButton) {
        _MinusButton = [[SSJCustomKeyBoardButton alloc]init];
        _MinusButton.leftBottom = CGPointMake(_buttonWight * 2,self.height);
        [_MinusButton setTitle:@"-" forState:UIControlStateNormal];
        _MinusButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_MinusButton setTintColor:[UIColor whiteColor]];
        [_MinusButton addTarget:self action:@selector(MinusKeyClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_MinusButton];

    }
    return _MinusButton;
}

//小数点键
-(SSJCustomKeyBoardButton*)DecimalButton{
    if (!_DecimalButton) {
        _DecimalButton = [[SSJCustomKeyBoardButton alloc]init];
        _DecimalButton.leftBottom = CGPointMake(_buttonWight * 2,self.height);
        [_DecimalButton setTitle:@"." forState:UIControlStateNormal];
        _DecimalButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_DecimalButton setTintColor:[UIColor whiteColor]];
        [_DecimalButton addTarget:self action:@selector(DecimalKeyClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_DecimalButton];

    }
    return _DecimalButton;
}

//确认键
-(SSJCustomKeyBoardButton*)ComfirmButton{
    if (!_ComfirmButton) {
        _ComfirmButton = [[SSJCustomKeyBoardButton alloc]init];
        _ComfirmButton.leftBottom = CGPointMake(_buttonWight * 2,self.height);
        [_ComfirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_ComfirmButton setTitle:@"=" forState:UIControlStateSelected];
        _ComfirmButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_ComfirmButton setTintColor:[UIColor whiteColor]];
        [_ComfirmButton addTarget:self action:@selector(ComfirmKeyClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_ComfirmButton];

    }
    return _ComfirmButton;
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
    [self.delegate didDecimalPointKeyPressed];
}

-(void)MinusKeyClicked:(UIButton*)button{
    [self.delegate didMinusKeyPressed];
    
}

-(void)PlusKeyClicked:(UIButton*)button{
    [self.delegate didPlusKeyPressed];
}

-(void)ComfirmKeyClicked:(UIButton*)button{
    [self.delegate didComfirmKeyPressed:button];
}
@end
