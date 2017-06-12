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

@property(nonatomic, strong) NSString *title;

@property(nonatomic) int maxLength;

@property(nonatomic, strong) UIView *titleView;

@property(nonatomic, strong) UIView *bottomView;

@property(nonatomic, strong) UIButton *comfirmButton;

@property(nonatomic, strong) UIButton *cancelButton;

@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) UITextView *textInput;

@property(nonatomic, strong) UILabel *textLengthLabel;

@property (nonatomic,strong) UIView *backView;

@end

@implementation SSJNickNameModifyView

- (instancetype)initWithFrame:(CGRect)frame maxTextLength:(int)maxTextLength title:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        self.title = title;
        self.maxLength = maxTextLength;
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainFillColor];
        [self addSubview:self.titleLabel];
        [self addSubview:self.textInput];
        [self addSubview:self.textLengthLabel];
        [self addSubview:self.comfirmButton];
        [self addSubview:self.cancelButton];
        [[YYKeyboardManager defaultManager] addObserver:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];

        [self sizeToFit];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[YYKeyboardManager defaultManager] removeObserver:self];
}

-(CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake([UIApplication sharedApplication].keyWindow.width - 20, 180);
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

- (void)updateConstraints {
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(42);
        make.left.top.mas_equalTo(self);
    }];
    
    [self.textInput mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(80);
        make.left.mas_equalTo(self);
    }];
    
    [self.textLengthLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.textInput.mas_bottom).offset(- 9);
        make.right.mas_equalTo(self.textInput.mas_right).offset(- 15);
    }];
    
    [self.comfirmButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom);
        make.right.mas_equalTo(self.mas_right);
        make.width.mas_equalTo(self.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(53);
    }];
    
    [self.cancelButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom);
        make.left.mas_equalTo(self.mas_left);
        make.width.mas_equalTo(self.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(53);
    }];
    
    [super updateConstraints];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString *string = textView.text ? : @"";
    string = [string stringByReplacingCharactersInRange:range withString:text];
    if (string.length > self.maxLength) {
        self.textLengthLabel.text = @"剩余0个字";
        [self.textLengthLabel sizeToFit];
        if (self.typeErrorBlock) {
            self.typeErrorBlock([NSString stringWithFormat:@"最多只能输入%d个字", self.maxLength]);
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
        [self.textLengthLabel sizeToFit];
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


-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [_titleLabel ssj_setBorderStyle:SSJBorderStyleBottom];
        [_titleLabel ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        [_titleLabel ssj_setBorderWidth:1];
        _titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = self.title;
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

-(UITextView *)textInput{
    if (!_textInput) {
        _textInput = [[UITextView alloc]init];
        _textInput.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _textInput.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_textInput ssj_setBorderStyle:SSJBorderStyleBottom];
        [_textInput ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor]];
        _textInput.delegate = self;
        _textInput.backgroundColor = [UIColor clearColor];
        _textInput.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    return _textInput;
}

-(UILabel *)textLengthLabel{
    if (!_textLengthLabel) {
        _textLengthLabel = [[UILabel alloc]init];
        _textLengthLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _textLengthLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        _textLengthLabel.text = [NSString stringWithFormat:@"剩余%d个字",self.maxLength];
        [_textLengthLabel sizeToFit];
    }
    return _textLengthLabel;
}

-(UIButton *)comfirmButton{
    if (!_comfirmButton) {
        _comfirmButton = [[UIButton alloc]init];
        [_comfirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_comfirmButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
        [_comfirmButton addTarget:self action:@selector(comfirmButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _comfirmButton;
}

-(UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc]init];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton ssj_setBorderStyle:SSJBorderStyleRight];
        [_cancelButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor]];
        
        [_cancelButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

-(void)cancelButtonClicked:(id)sender{
    [self dismiss];
}

-(void)comfirmButtonClicked:(id)sender{
    [self dismiss];
//    SSJPRINT(@"-------%@",[self.textInput.text ssj_emojiFilter]);
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

- (void)updateCellAppearanceAfterThemeChanged {
    [_titleLabel ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    _titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    [_textInput ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor]];
    _textInput.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _textLengthLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    [_comfirmButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
    [_cancelButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
