
//
//  SSJCustomKeyboard.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/16.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCustomKeyboard.h"

@interface SSJCustomKeyboard()
@property(nonatomic,strong)SSJCustomKeyBoardButton *BackspaceButton;
@property(nonatomic,strong)SSJCustomKeyBoardButton *ClearButton;
@property(nonatomic,strong)SSJCustomKeyBoardButton *PlusButton;
@property(nonatomic,strong)SSJCustomKeyBoardButton *MinusButton;
@property(nonatomic,strong)SSJCustomKeyBoardButton *DecimalButton;
@property(nonatomic,strong)SSJCustomKeyBoardButton *ZeroButton;
@property(nonatomic,strong)NSMutableArray *numButtonArray;

@end

@implementation SSJCustomKeyboard{
    CGFloat _buttonHeight;
    CGFloat _buttonWight;
    BOOL _numkeyHavePressed;
    NSString *_caculationResult;
    float _caculationValue;
    NSInteger _lastPressNum;
    NSString *_intPart;
    NSString *_decimalPart;
    int _decimalCount;
}

static id _instance;
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance=[super allocWithZone:zone];
    });
    return _instance;
}

+ (SSJCustomKeyboard *)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200)];
    });
    return _instance;
}


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor ssj_colorWithHex:@"f1f1f1"];
        _buttonHeight = self.height / 4;
        _buttonWight = self.width / 4;
        self.decimalModel = NO;
        self.numButtonArray = [[NSMutableArray alloc]init];
        self.backgroundColor = [UIColor clearColor];
        self.numKeyHasPressed = NO;
        self.rightNum = 0;
        self.leftNum = 0;
        self.lastPressTag = 0;
        [self setNumKey];
        [self addSubview:self.DecimalButton];
        [self addSubview:self.ZeroButton];
        [self addSubview:self.ClearButton];
        [self addSubview:self.BackspaceButton];
        [self addSubview:self.PlusButton];
        [self addSubview:self.MinusButton];
        [self addSubview:self.ComfirmButton];
    }
    return self;
}

-(void)layoutSubviews{
    for (int i = 0; i < 9; i ++) {
        ((SSJCustomKeyBoardButton*)([self.numButtonArray objectAtIndex:i])).frame = CGRectMake(i % 3 * _buttonWight, i / 3 * _buttonHeight, _buttonWight, _buttonHeight);
    }
    self.DecimalButton.size = CGSizeMake(_buttonWight, _buttonHeight);
    self.DecimalButton.leftBottom = CGPointMake(0, 200);
    self.ZeroButton.size = CGSizeMake(_buttonWight, _buttonHeight);
    self.ZeroButton.leftBottom = CGPointMake(self.DecimalButton.right, self.bottom);
    self.ClearButton.size = CGSizeMake(_buttonWight, _buttonHeight);
    self.ClearButton.leftBottom = CGPointMake(self.ZeroButton.right, self.bottom);
    self.BackspaceButton.size = CGSizeMake(_buttonWight, _buttonHeight);
    self.BackspaceButton.rightTop = CGPointMake(self.right, 0);
    self.PlusButton.size = CGSizeMake(_buttonWight, _buttonHeight);
    self.PlusButton.rightTop = CGPointMake(self.width, self.BackspaceButton.bottom);
    self.MinusButton.size = CGSizeMake(_buttonWight, _buttonHeight);
    self.MinusButton.rightTop = CGPointMake(self.width, self.PlusButton.bottom);
    self.ComfirmButton.size = CGSizeMake(_buttonWight, _buttonHeight);
    self.ComfirmButton.rightBottom = CGPointMake(self.width, self.height);
}

//数字键
-(void)setNumKey{
    for (int i = 0; i < 9; i ++) {
        SSJCustomKeyBoardButton *numButton = [[SSJCustomKeyBoardButton alloc]init];
        [numButton setTitle:[NSString stringWithFormat:@"%d",i + 1] forState:UIControlStateNormal];
        numButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [numButton setTintColor:[UIColor whiteColor]];
        [numButton addTarget:self action:@selector(keyboardBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.numButtonArray addObject:numButton];
        numButton.titleLabel.font = [UIFont systemFontOfSize:24];
        numButton.backgroundColor = [UIColor ssj_colorWithHex:@"#ffffff"];
        numButton.layer.borderColor = [UIColor ssj_colorWithHex:@"e2e2e2"].CGColor;
        numButton.layer.borderWidth = 1.0f / 2;
        numButton.tag = i + 1;
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
        [_ZeroButton addTarget:self action:@selector(keyboardBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        _ZeroButton.titleLabel.font = [UIFont systemFontOfSize:24];
        _ZeroButton.backgroundColor = [UIColor ssj_colorWithHex:@"#ffffff"];
        _ZeroButton.layer.borderColor = [UIColor ssj_colorWithHex:@"e2e2e2"].CGColor;
        _ZeroButton.layer.borderWidth = 1.0f / 2;
        _ZeroButton.tag = 10;
    }
    return _ZeroButton;
}

//退格键
-(SSJCustomKeyBoardButton*)BackspaceButton{
    if (!_BackspaceButton) {
        _BackspaceButton = [[SSJCustomKeyBoardButton alloc]init];
        _BackspaceButton.rightTop = CGPointMake(self.width,0);
        [_BackspaceButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        _BackspaceButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_BackspaceButton setTintColor:[UIColor whiteColor]];
        [_BackspaceButton addTarget:self action:@selector(keyboardBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        _BackspaceButton.titleLabel.font = [UIFont systemFontOfSize:24];
        _BackspaceButton.backgroundColor = [UIColor ssj_colorWithHex:@"#ffffff"];
        _BackspaceButton.layer.borderColor = [UIColor ssj_colorWithHex:@"e2e2e2"].CGColor;
        _BackspaceButton.layer.borderWidth = 1.0f / 2;
        _BackspaceButton.tag = 11;
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
        [_ClearButton addTarget:self action:@selector(keyboardBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        _ClearButton.titleLabel.font = [UIFont systemFontOfSize:24];
        _ClearButton.backgroundColor = [UIColor whiteColor];
        _ClearButton.layer.borderColor = [UIColor ssj_colorWithHex:@"e2e2e2"].CGColor;
        _ClearButton.layer.borderWidth = 1.0f / 2;
        _ClearButton.tag = 12;
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
        [_PlusButton addTarget:self action:@selector(keyboardBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        _PlusButton.titleLabel.font = [UIFont systemFontOfSize:24];
        _PlusButton.backgroundColor = [UIColor whiteColor];
        _PlusButton.layer.borderColor = [UIColor ssj_colorWithHex:@"e2e2e2"].CGColor;
        _PlusButton.layer.borderWidth = 1.0f / 2;
        _PlusButton.tag = 13;
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
        [_MinusButton addTarget:self action:@selector(keyboardBtnTouched:) forControlEvents:UIControlEventTouchUpInside];\
        _MinusButton.titleLabel.font = [UIFont systemFontOfSize:24];
        _MinusButton.backgroundColor = [UIColor whiteColor];
        _MinusButton.layer.borderColor = [UIColor ssj_colorWithHex:@"e2e2e2"].CGColor;
        _MinusButton.layer.borderWidth = 1.0f / 2;
        _MinusButton.tag = 14;
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
        [_DecimalButton addTarget:self action:@selector(keyboardBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        _DecimalButton.titleLabel.font = [UIFont systemFontOfSize:24];
        _DecimalButton.backgroundColor = [UIColor whiteColor];
        _DecimalButton.layer.borderColor = [UIColor ssj_colorWithHex:@"e2e2e2"].CGColor;
        _DecimalButton.layer.borderWidth = 1.0f / 2;
        _DecimalButton.tag = 15;
    }
    return _DecimalButton;
}

//确认键
-(SSJCustomKeyBoardButton*)ComfirmButton{
    if (!_ComfirmButton) {
        _ComfirmButton = [[SSJCustomKeyBoardButton alloc]init];
        _ComfirmButton.leftBottom = CGPointMake(_buttonWight * 2,self.height);
        [_ComfirmButton setTitle:@"OK" forState:UIControlStateNormal];
        _ComfirmButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_ComfirmButton setTintColor:[UIColor whiteColor]];
        [_ComfirmButton addTarget:self action:@selector(keyboardBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        _ComfirmButton.titleLabel.font = [UIFont systemFontOfSize:24];
        _ComfirmButton.backgroundColor = [UIColor whiteColor];
        _ComfirmButton.layer.borderColor = [UIColor ssj_colorWithHex:@"e2e2e2"].CGColor;
        _ComfirmButton.layer.borderWidth = 1.0f / 2;
        _ComfirmButton.tag = 16;
    }
    return _ComfirmButton;
}

/* 返回_textField的文本选择范围 */
- (NSRange)selectedRange{
    UITextPosition *beginning = _textField.beginningOfDocument;
    UITextRange *selectedRange = _textField.selectedTextRange;
    UITextPosition *selectionStart = selectedRange.start;
    UITextPosition *selectionEnd = selectedRange.end;
    const NSInteger location = [_textField offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [_textField offsetFromPosition:selectionStart toPosition:selectionEnd];
    return NSMakeRange(location, length);
}

- (void)keyboardBtnTouched:(UIButton *)sender{
    if (self.textField==nil) {
        return;
    }
    if (![self.textField.text isEqualToString: @""]) {
        self.numKeyHasPressed = YES;
    }
    if ([sender.titleLabel.text isEqualToString:@"OK"]) {
        [self.textField resignFirstResponder];
        return;
    }
    BOOL shouldChangeText = YES;
    NSString *inputString;
    if (sender.tag == 12) {
        inputString = @"";
        self.leftNum = 0;
        self.rightNum = 0;
        self.plusOrMinusKeyHasPressed = NO;
        self.lastPressTag = 12;
    }else if (sender.tag == 11){
        inputString = @"";
    }else if (sender.tag == 16 && [sender.titleLabel.text isEqualToString: @"="]){
        self.rightNum = [self.textField.text floatValue];
        if (self.PlusOrMinusModel == YES) {
            self.leftNum = self.leftNum + self.rightNum;
        }else{
            self.leftNum = self.leftNum - self.rightNum;
        }
        NSNumber *resultNum = [NSNumber numberWithFloat:self.leftNum];
        _lastPressTag = 16;
        inputString = [resultNum stringValue];
        [self.ComfirmButton setTitle:@"OK" forState:UIControlStateNormal];
    }else if (sender.tag <= 10 || sender.tag == 15){
        inputString = sender.titleLabel.text;
    }else if (sender.tag == 13){
        if (self.lastPressTag != 13) {
            if (self.plusOrMinusKeyHasPressed == NO) {
                self.leftNum = [self.textField.text floatValue];
            }else{
                self.rightNum = [self.textField.text floatValue];
            }
        }
        self.leftNum = self.leftNum + self.rightNum;
        NSNumber *resultNum = [NSNumber numberWithFloat:self.leftNum];
        self.textField.text = [resultNum stringValue];
        inputString = [resultNum stringValue];
        self.rightNum = 0;
        self.PlusOrMinusModel = YES;
        self.plusOrMinusKeyHasPressed = YES;
        [self.ComfirmButton setTitle:@"=" forState:UIControlStateNormal];
        self.lastPressTag = 13;
    }else if (sender.tag == 14){
        if (self.lastPressTag != 14) {
            if (self.plusOrMinusKeyHasPressed == NO) {
                self.leftNum = [self.textField.text floatValue];
            }else{
                self.rightNum = [self.textField.text floatValue];
            }
        }
        self.leftNum = self.leftNum - self.rightNum;
        NSNumber *resultNum = [NSNumber numberWithFloat:self.leftNum];
        self.textField.text = [resultNum stringValue];
        inputString = [resultNum stringValue];
        self.rightNum = 0;
        self.PlusOrMinusModel = NO;
        self.plusOrMinusKeyHasPressed = YES;
        [self.ComfirmButton setTitle:@"=" forState:UIControlStateNormal];
        self.lastPressTag = 14;
    }

    if (_textField.delegate && [_textField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        NSRange selectedRange = [self selectedRange];
        NSRange changeRange = selectedRange;
        if (sender.tag == 12 || sender.tag == 13 || sender.tag == 14) {
            if (selectedRange.length == 0) {
                if (selectedRange.location >= 1) {
                    changeRange = NSMakeRange(0, self.textField.text.length);
                } else {
                    return;
                }
            }
        }else if (sender == self.ComfirmButton){
            if (selectedRange.length == 0) {
                if (selectedRange.location >= 1) {
                    changeRange = NSMakeRange(0, self.textField.text.length);
                } else {
                    return;
                }
            }
        }else if (sender.tag == 11){
            if (selectedRange.length == 0) {
                if (selectedRange.location >= 1) {
                    changeRange = NSMakeRange(selectedRange.location - 1, 1);
                } else {
                    return;
                }
            }
        }else if (sender.tag <= 10 && (self.lastPressTag == 13 || self.lastPressTag == 14)){
            if (selectedRange.length == 0) {
                if (selectedRange.location >= 1) {
                    changeRange = NSMakeRange(0, self.textField.text.length);
                } else {
                    return;
                }
            }
        }
        self.lastPressTag = sender.tag;
        shouldChangeText = [_textField.delegate textField:_textField shouldChangeCharactersInRange:changeRange replacementString:inputString];
    }
    if (shouldChangeText) {
        if (sender.tag == 12) {
            self.textField.text = @"";
        }else if (sender.tag <= 10){
            [self.textField insertText:sender.titleLabel.text];
            if (self.numKeyHasPressed == NO && sender.tag == 10) {
                self.numKeyHasPressed = NO;
            }else{
                self.numKeyHasPressed = YES;
            }
        }else if (sender.tag == 11){
            [self.textField deleteBackward];
        }else if (sender.tag == 15){
            [self.textField insertText:sender.titleLabel.text];
        }
    }
}
@end

@implementation NSObject (SSJCustomKeyboard)

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    SSJCustomKeyboard *customKeyboard = [SSJCustomKeyboard sharedInstance];
    if (textField.inputView == customKeyboard) {
        customKeyboard.textField = textField;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    SSJCustomKeyboard *customKeyboard = [SSJCustomKeyboard sharedInstance];
    if (textField.inputView == customKeyboard) {
        customKeyboard.leftNum = 0;
        customKeyboard.rightNum = 0;
        customKeyboard.lastPressTag = 0;
        customKeyboard.plusOrMinusKeyHasPressed = NO;
    }
}

@end

