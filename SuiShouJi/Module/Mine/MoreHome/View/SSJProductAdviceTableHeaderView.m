//
//  SSJProductAdviceTableHeaderView.m
//  SuiShouJi
//
//  Created by yi cai on 2016/12/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJProductAdviceTableHeaderView.h"
#import "SSJCustomTextView.h"
@interface SSJProductAdviceTableHeaderView()
@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) UITextField *textField;
/**
 建议
 */
@property (nonatomic, strong) SSJCustomTextView *textView;
@property (nonatomic, strong) UIView *bgview;
@property (nonatomic, strong) UIView *bottomBgview;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UILabel *fanKuiLabel;

@end
/**
 左右间距
 */
static NSInteger padding = 15;
@implementation SSJProductAdviceTableHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.bgview];
        [self addSubview:self.bottomBgview];
        [self.bgview addSubview:self.topImageView];
        [self.bgview addSubview:self.textField];
        [self.bgview addSubview:self.textView];
        [self.bgview addSubview:self.submitButton];
        [self.bottomBgview addSubview:self.fanKuiLabel];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bgview.leftTop = CGPointMake(0, 0);
    self.topImageView.leftTop = CGPointMake(0, 0);
    self.textView.leftTop = CGPointMake(padding, CGRectGetMaxY(self.topImageView.frame) + 20);
    self.textField.leftTop = CGPointMake(padding, CGRectGetMaxY(self.textView.frame) + 15);
    self.submitButton.leftTop = CGPointMake(padding, CGRectGetMaxY(self.textField.frame) + 25);
    self.bgview.height = CGRectGetMaxY(self.submitButton.frame) + 20;
    self.bottomBgview.leftTop = CGPointMake(0, CGRectGetMaxY(self.bgview.frame) + 10);
    self.fanKuiLabel.leftTop = CGPointMake(padding, 0);
}
#pragma mark -Getter
- (CGFloat)headerHeight
{
    [self setNeedsDisplay];
    CGFloat height = CGRectGetMaxY(_bottomBgview.frame);
    return height < 100 ? 436 : height;
}

#pragma mark -Lazy
- (UIImageView *)topImageView
{
    if (!_topImageView) {
        UIImage *image = [UIImage imageNamed:@"more_productAdvice_banner.png"];
       float scale = image.size.height / image.size.width;
        _topImageView = [[UIImageView alloc] initWithImage:image];
        _topImageView.size = CGSizeMake(SSJSCREENWITH, SSJSCREENWITH * scale);
    }
    return _topImageView;
}

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.placeholder = @"手机号/邮箱（选填，方便有问题时与您联系）";
        _textField.size = CGSizeMake(SSJSCREENWITH - 2 * padding, 44);
        _textField.font = [UIFont systemFontOfSize:13];
        _textField.layer.cornerRadius = 5;
        _textField.clipsToBounds = YES;
        _textField.backgroundColor = [UIColor clearColor];
        _textField.layer.borderWidth = 0.5;
        _textField.layer.borderColor = [UIColor ssj_colorWithHex:@"dddddd"].CGColor;
        _textField.textColor = [UIColor ssj_colorWithHex:@"333333"];
        [_textField setValue: [UIColor ssj_colorWithHex:@"cccccc"] forKeyPath:@"_placeholderLabel.textColor"];
        
        UIView *leftview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, _textField.height)];
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.leftView = leftview;
    }
    return _textField;
}


- (SSJCustomTextView *)textView
{
    if (!_textView) {
        _textView = [[SSJCustomTextView alloc] init];
        _textView.size = CGSizeMake(SSJSCREENWITH - 2 * padding, 100);
        _textView.placeholder = @"亲爱的用户，请您详细描述产品建议如增加什么功能或者怎样某个功能有什么缺陷改进会更好之类，感谢您的支持～";
        _textView.font = [UIFont systemFontOfSize:13];
        _textView.layer.cornerRadius = 5;
        _textView.clipsToBounds = YES;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.layer.borderColor = [UIColor ssj_colorWithHex:@"dddddd"].CGColor;
        _textView.textColor = [UIColor ssj_colorWithHex:@"333333"];
        _textView.placeholderColor = [UIColor ssj_colorWithHex:@"cccccc"];
        _textView.layer.borderWidth = 0.5;
    }
    return _textView;
}


- (UIButton *)submitButton
{
    if (!_submitButton) {
        _submitButton = [[UIButton alloc] init];
        _submitButton.size = CGSizeMake(SSJSCREENWITH - 2 * padding, 44);
        [_submitButton setTitle:@"提交建议" forState:UIControlStateNormal];
        [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _submitButton.titleLabel.font = [UIFont systemFontOfSize:19];
        _submitButton.layer.cornerRadius = 5;
        _submitButton.clipsToBounds = YES;
       _submitButton.backgroundColor = [UIColor ssj_colorWithHex:@"eb4a64"];
        [_submitButton addTarget:self action:@selector(submitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}

- (UILabel *)fanKuiLabel
{
    if (!_fanKuiLabel) {
        _fanKuiLabel = [[UILabel alloc] init];
        _fanKuiLabel.size = CGSizeMake(SSJSCREENWITH - padding, 40);
        _fanKuiLabel.text = @"我的反馈";
        _fanKuiLabel.font = [UIFont systemFontOfSize:13];
        _fanKuiLabel.backgroundColor = [UIColor clearColor];
    }
    return _fanKuiLabel;
}
- (UIView *)bgview
{
    if (!_bgview) {
        _bgview = [[UIView alloc] init];
        _bgview.backgroundColor = [UIColor whiteColor];
        _bgview.width = SSJSCREENWITH;
    }
    return _bgview;
}

- (UIView *)bottomBgview
{
    if (!_bottomBgview) {
        _bottomBgview = [[UIView alloc] init];
        _bottomBgview.size = CGSizeMake(SSJSCREENWITH, 40);
        _bottomBgview.backgroundColor = [UIColor whiteColor];
        [_bottomBgview ssj_setBorderStyle:SSJBorderStyleBottom];
        [_bottomBgview ssj_setBorderWidth:0.5];
        [self.bottomBgview ssj_setBorderColor:[UIColor ssj_colorWithHex:@"dddddd"]];
        
    }
    return _bottomBgview;
}



#pragma mark - action
- (void)submitButtonClicked
{
    if (self.textView.text.length < 1) {
        [CDAutoHideMessageHUD showMessage:@"请输入建议再提交哦"];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(submitAdviceButtonClickedWithMessage:additionalMessage:)] && self.textView.text.length) {
        [self.delegate submitAdviceButtonClickedWithMessage:_textView.text additionalMessage:_textField.text];
    }
}

- (void)clearAdviceContext
{
    [self endEditing:YES];
    self.textView.text = @"";
    self.textField.text = @"";
}

//- (void)updateCellAppearanceAfterThemeChanged
//{
//    [self.bottomBgview ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
//    self.bottomBgview.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
//    self.bgview.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
//    [self.submitButton setBackgroundColor: [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor alpha:SSJ_CURRENT_THEME.backgroundAlpha]];
//    self.textField.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha].CGColor;
//    self.textView.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha].CGColor;
//    self.textView.placeholderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor alpha:0.5];
//    [self.textField setValue: [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];//次要颜色透明度的50%
//    self.textField.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
//    self.textView.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
//    self.fanKuiLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
//}

@end
