//
//  SSJMemoMakingView.m
//  SuiShouJi
//
//  Created by ricky on 16/4/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMemoMakingView.h"
#import <YYKeyboardManager/YYKeyboardManager.h>


@interface SSJMemoMakingView()<YYKeyboardObserver>
@property(nonatomic, strong) UIImageView *penImage;
@property(nonatomic) int maxLength;
@property(nonatomic, strong) UIView *bottomView;
@property(nonatomic, strong) UIButton *comfirmButton;
@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, strong) UITextView *textInput;
@property(nonatomic, strong) UILabel *textLengthLabel;
@property (nonatomic,strong) UIView *backView;
@end
@implementation SSJMemoMakingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.maxLength = 50;
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.penImage];
        [self addSubview:self.textInput];
        [self addSubview:self.textLengthLabel];
        [self addSubview:self.bottomView];
        [self.bottomView addSubview:self.comfirmButton];
        [self.bottomView addSubview:self.cancelButton];
        [[YYKeyboardManager defaultManager] addObserver:self];
        [self sizeToFit];
    }
    return self;
}

-(void)dealloc{
    [[YYKeyboardManager defaultManager] removeObserver:self];
}

-(CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake([UIApplication sharedApplication].keyWindow.width - 20, 160);
}

- (void)show {
    if (self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    self.bottom = keyWindow.height;
    
    self.centerX = keyWindow.width / 2;
    
    //    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.3 target:self touchAction:@selector(dismiss) animation:^{
    //        self.bottom = keyWindow.height;
    //    } timeInterval:0.25 fininshed:NULL];
    
    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.3 target:self touchAction:@selector(dismiss)];
    
    [self.textInput becomeFirstResponder];
    
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [self.textInput resignFirstResponder];
    
    [self.superview ssj_hideBackViewForView:self animation:^{
        self.top = keyWindow.bottom;
    } timeInterval:0.25 fininshed:NULL];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    self.penImage.size = CGSizeMake(15, 30);
    self.penImage.leftTop = CGPointMake(10, 20);
    self.textInput.size = CGSizeMake(self.width - 50, 49);
    self.textInput.leftTop = CGPointMake(self.penImage.right + 10, 20);
    self.textLengthLabel.right = self.width - 10;
    self.textLengthLabel.top = self.textInput.bottom + 15;
    self.bottomView.size = CGSizeMake(self.width, 50);
    self.bottomView.rightBottom = CGPointMake(0, self.height);
    self.bottomView.centerX = self.width / 2;
    self.comfirmButton.size = CGSizeMake(55, 27);
    self.comfirmButton.right = self.width - 10;
    self.comfirmButton.centerY = self.bottomView.height / 2;
    self.cancelButton.size = CGSizeMake(55, 27);
    self.cancelButton.right = self.comfirmButton.left - 20;
    self.cancelButton.centerY = self.bottomView.height / 2;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString *string = textView.text ? : @"";
    string = [string stringByReplacingCharactersInRange:range withString:text];
    if (string.length > self.maxLength) {
        if (self.typeErrorBlock) {
            self.typeErrorBlock([NSString stringWithFormat:@"最多只能输入%d个字",self.maxLength]);
        }
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.textLengthLabel.text = [NSString stringWithFormat:@"剩余%d个字",self.maxLength - (int)textView.text.length];
    [self.textLengthLabel sizeToFit];
    if (textView.text.length >= self.maxLength) {
        textView.text = [textView.text substringToIndex:self.maxLength];
        self.textLengthLabel.text = @"剩余0个字";
    }
}


#pragma mark - @protocol YYKeyboardObserver
- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    [UIView animateWithDuration:transition.animationCurve delay:0 options:transition.animationOption animations:^{
        CGRect kbFrame = [[YYKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.superview];
        CGRect popframe = self.frame;
        popframe.origin.y = kbFrame.origin.y - popframe.size.height - 20;
        self.frame = popframe;
    } completion:^(BOOL finished) {
        
    }];
}



-(UITextView *)textInput{
    if (!_textInput) {
        _textInput = [[UITextView alloc]init];
        _textInput.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _textInput.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _textInput.delegate = self;
    }
    return _textInput;
}

-(UILabel *)textLengthLabel{
    if (!_textLengthLabel) {
        _textLengthLabel = [[UILabel alloc]init];
        _textLengthLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        _textLengthLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        _textLengthLabel.text = [NSString stringWithFormat:@"剩余%d个字",self.maxLength];
        [_textLengthLabel sizeToFit];
    }
    return _textLengthLabel;
}

-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = [UIColor ssj_colorWithHex:@"f6f6f6"];
        [_bottomView ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
        [_bottomView ssj_setBorderStyle:SSJBorderStyleTop];
        [_bottomView ssj_setBorderWidth:1.0f / [UIScreen mainScreen].scale];
    }
    return _bottomView;
}

-(UIButton *)comfirmButton{
    if (!_comfirmButton) {
        _comfirmButton = [[UIButton alloc]init];                         
        [_comfirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_comfirmButton setTitleColor:[UIColor ssj_colorWithHex:@"eb4a64"] forState:UIControlStateNormal];
        _comfirmButton.layer.cornerRadius = 3.0f;
        _comfirmButton.layer.borderColor = [UIColor ssj_colorWithHex:@"eb4a64"].CGColor;
        _comfirmButton.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
        [_comfirmButton addTarget:self action:@selector(comfirmButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _comfirmButton;
}

-(UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc]init];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor ssj_colorWithHex:@"cccccc"] forState:UIControlStateNormal];
        _cancelButton.layer.cornerRadius = 3.0f;
        _cancelButton.layer.borderColor = [UIColor ssj_colorWithHex:@"cccccc"].CGColor;
        _cancelButton.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
        [_cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

-(UIImageView *)penImage{
    if (!_penImage) {
        _penImage = [[UIImageView alloc]init];
        _penImage.image = [UIImage imageNamed:@"home_pen_nor"];
    }
    return _penImage;
}

-(void)cancelButtonClicked:(id)sender{
    [self dismiss];
}

-(void)comfirmButtonClicked:(id)sender{
    [self dismiss];
    if (self.comfirmButtonClickedBlock) {
        self.comfirmButtonClickedBlock([self.textInput.text ssj_emojiFilter]);
    }
}

-(void)setOriginalText:(NSString *)originalText{
    _originalText = originalText;
    if (_originalText.length > _maxLength) {
        return;
    }
    self.textInput.text = originalText;
    self.textLengthLabel.text = [NSString stringWithFormat:@"剩余%d个字",self.maxLength - (int)_originalText.length];
    [self.textLengthLabel sizeToFit];
}



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
