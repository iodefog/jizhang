//
//  SSJNickNameModifyView.m
//  SuiShouJi
//
//  Created by ricky on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNickNameModifyView.h"

@interface SSJNickNameModifyView()
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
        self.layer.cornerRadius = 3.f;
        self.backgroundColor = [UIColor whiteColor];
        self.title = title;
        self.maxLength = maxTextLength;
        [self addSubview:self.titleView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.textInput];
        [self addSubview:self.textLengthLabel];
        [self addSubview:self.bottomView];
        [self addSubview:self.comfirmButton];
        [self addSubview:self.cancelButton];
        [self.textInput becomeFirstResponder];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
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
    }
    return _textInput;
}

-(UILabel *)textLengthLabel{
    if (!_textLengthLabel) {
        _textLengthLabel = [[UILabel alloc]init];
        _textLengthLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        _textLengthLabel.font = [UIFont systemFontOfSize:12];
        _textLengthLabel.text = [NSString stringWithFormat:@"剩余%d个字",self.maxLength];
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
        _comfirmButton.layer.borderColor = [UIColor ssj_colorWithHex:@""];
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
        _cancelButton.layer.borderColor = [UIColor ssj_colorWithHex:@""];
        _cancelButton.layer.borderWidth = 1.f / [UIScreen mainScreen].scale;
        [_cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

-(void)cancelButtonClicked:(id)sender{
    [self.textInput resignFirstResponder];
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
