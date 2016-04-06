//
//  SSJNickNameModifyView.m
//  SuiShouJi
//
//  Created by ricky on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNickNameModifyView.h"
#import <YYKeyboardManager/YYKeyboardManager.h>


@interface SSJNickNameModifyView()<YYKeyboardObserver>
@property(nonatomic, strong) UIView *popView;
@property(nonatomic, strong) NSString *title;
@property(nonatomic) int maxLength;
@property(nonatomic, strong) UIView *titleView;
@property(nonatomic, strong) UIView *bottomView;
@property(nonatomic, strong) UIButton *comfirmButton;
@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UITextView *textInput;
@property(nonatomic, strong) UILabel *textLengthLabel;
@end
@implementation SSJNickNameModifyView

- (instancetype)initWithFrame:(CGRect)frame maxTextLength:(int)maxTextLength title:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.title = title;
        self.maxLength = maxTextLength;
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backViewClicked:)];
        [self addGestureRecognizer:gesture];
        [self addSubview:self.popView];
        [self.popView addSubview:self.titleView];
        [self.titleView addSubview:self.titleLabel];
        [self.popView addSubview:self.textInput];
        [self.popView addSubview:self.textLengthLabel];
        [self.popView addSubview:self.bottomView];
        [self.bottomView addSubview:self.comfirmButton];
        [self.bottomView addSubview:self.cancelButton];
        [self.textInput becomeFirstResponder];
        [[YYKeyboardManager defaultManager] addObserver:self];
        [self sizeToFit];
    }
    return self;
}

-(void)dealloc{
    [[YYKeyboardManager defaultManager] removeObserver:self];
}

-(CGSize)sizeThatFits:(CGSize)size{
    return [UIScreen mainScreen].bounds.size;
}

- (void)show {
    if (self.superview) {
        return;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [keyWindow addSubview:self];
    
    [self.textInput becomeFirstResponder];
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    
    [self.textInput resignFirstResponder];
    
    [self removeFromSuperview];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.popView.size = CGSizeMake(self.width - 20, 200);
    self.popView.bottom = self.height;
    self.popView.centerX = self.width / 2;
    self.titleView.size = CGSizeMake(self.popView.width, 49);
    self.titleView.leftTop = CGPointMake(0, 0);
    self.titleView.centerX = self.popView.width / 2;
    self.titleLabel.center = CGPointMake(self.titleView.width / 2, self.titleView.height / 2);
    self.textInput.size = CGSizeMake(self.popView.width - 20, 49);
    self.textInput.top = self.titleView.bottom + 10;
    self.textInput.centerX = self.popView.width / 2;
    self.textLengthLabel.right = self.textInput.right;
    self.textLengthLabel.top = self.textInput.bottom + 15;
    self.bottomView.size = CGSizeMake(self.popView.width, 50);
    self.bottomView.rightBottom = CGPointMake(0, self.popView.height);
    self.bottomView.centerX = self.popView.width / 2;
    self.comfirmButton.size = CGSizeMake(55, 27);
    self.comfirmButton.right = self.textInput.right;
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
        self.textLengthLabel.text = @"剩余0个字";
        [self.textLengthLabel sizeToFit];
        return NO;
    }
    self.textLengthLabel.text = [NSString stringWithFormat:@"剩余%lu个字",self.maxLength - string.length];
    [self.textLengthLabel sizeToFit];
    return YES;
}


#pragma mark - @protocol YYKeyboardObserver
- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    [UIView animateWithDuration:transition.animationCurve delay:0 options:transition.animationOption animations:^{
        CGRect kbFrame = [[YYKeyboardManager defaultManager] convertRect:transition.toFrame toView:self];
        CGRect popframe = self.popView.frame;
        popframe.origin.y = kbFrame.origin.y - popframe.size.height - 20;
        self.popView.frame = popframe;
    } completion:^(BOOL finished) {
        
    }];
}


-(UIView *)popView{
    if (!_popView) {
        _popView = [[UIView alloc]init];
        _popView.userInteractionEnabled = YES;
        _popView.backgroundColor = [UIColor whiteColor];
        _popView.layer.cornerRadius = 3.0f;
    }
    return _popView;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.text = self.title;
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

-(UITextView *)textInput{
    if (!_textInput) {
        _textInput = [[UITextView alloc]init];
        _textInput.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _textInput.font = [UIFont systemFontOfSize:15];
        _textInput.delegate = self;
    }
    return _textInput;
}

-(UILabel *)textLengthLabel{
    if (!_textLengthLabel) {
        _textLengthLabel = [[UILabel alloc]init];
        _textLengthLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        _textLengthLabel.font = [UIFont systemFontOfSize:12];
        _textLengthLabel.text = [NSString stringWithFormat:@"剩余%d个字",self.maxLength];
        [_textLengthLabel sizeToFit];
    }
    return _textLengthLabel;
}

-(UIView *)titleView{
    if (!_titleView) {
        _titleView = [[UIView alloc]init];
        _titleView.backgroundColor = [UIColor ssj_colorWithHex:@"f6f6f6"];
        [_titleView ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
        [_titleView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_titleView ssj_setBorderWidth:1.0f / [UIScreen mainScreen].scale];
    }
    return _titleView;
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
        [_comfirmButton setTitleColor:[UIColor ssj_colorWithHex:@"47cfbe"] forState:UIControlStateNormal];
        _comfirmButton.layer.cornerRadius = 3.0f;
<<<<<<< HEAD
        _comfirmButton.layer.borderColor = [UIColor ssj_colorWithHex:@"47cfbe"].CGColor;
=======
//        _comfirmButton.layer.borderColor = [UIColor ssj_colorWithHex:@""];
>>>>>>> 3bb4375588f2b33bf3119130405e0306230c600f
        _comfirmButton.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
        [_comfirmButton addTarget:self action:@selector(comfirmButtonClicked:) forControlEvents:UIControlEventTouchDragInside];
    }
    return _comfirmButton;
}

-(UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc]init];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor ssj_colorWithHex:@"cccccc"] forState:UIControlStateNormal];
        _cancelButton.layer.cornerRadius = 3.0f;
<<<<<<< HEAD
        _cancelButton.layer.borderColor = [UIColor ssj_colorWithHex:@"cccccc"].CGColor;
=======
//        _cancelButton.layer.borderColor = [UIColor ssj_colorWithHex:@""];
>>>>>>> 3bb4375588f2b33bf3119130405e0306230c600f
        _cancelButton.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
        [_cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

-(void)backViewClicked:(id)sender{
    [self dismiss];
}

-(void)cancelButtonClicked:(id)sender{
    [self dismiss];
}

-(void)comfirmButtonClicked:(id)sender{
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
