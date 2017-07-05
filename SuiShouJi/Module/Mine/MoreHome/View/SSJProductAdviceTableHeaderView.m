//
//  SSJProductAdviceTableHeaderView.m
//  SuiShouJi
//
//  Created by yi cai on 2016/12/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJProductAdviceTableHeaderView.h"
#import "SSJProductAdviceNetWorkService.h"
#import "SSJCustomTextView.h"
@interface SSJProductAdviceTableHeaderView()<SSJBaseNetworkServiceDelegate>

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UIButton *adviceBtn;

@property (nonatomic, strong) UIButton *faultBtn;

@property (nonatomic, strong) UIButton *tucaoBtn;

@property (nonatomic, strong) UITextField *textField;
/**
 建议
 */
@property (nonatomic, strong) SSJCustomTextView *textView;

@property (nonatomic, strong) UIView *bottomBgview;

@property (nonatomic, strong) UIButton *submitButton;

@property (nonatomic, strong) UILabel *fanKuiLabel;

@property (nonatomic, strong) SSJProductAdviceNetWorkService *adviceService;

@property (nonatomic, assign) SSJAdviceType adviceType;
@end

@implementation SSJProductAdviceTableHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
        [self addSubview:self.topView];
//        [self addSubview:self.bottomBgview];
        [self addSubview:self.textField];
        [self addSubview:self.textView];
        [self addSubview:self.submitButton];
        [self addSubview:self.fanKuiLabel];
//        [self updateCellAppearanceAfterThemeChanged];
        [self updateConstraintsIfNeeded];
    }
    return self;
}

- (void)updateConstraints {
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.offset(65);
    }];
    
    [self.adviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(15);
        make.top.mas_equalTo(20);
        make.width.offset(85);
        make.height.offset(25);
    }];
    
    [self.faultBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.topView);
        make.centerY.width.height.mas_equalTo(self.adviceBtn);
    }];
    
    [self.tucaoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-15);
        make.width.centerY.height.mas_equalTo(self.faultBtn);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.mas_equalTo(self.topView);
        make.height.mas_equalTo(120);
        make.top.mas_equalTo(self.topView.mas_bottom);
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.mas_equalTo(self.topView);
        make.height.mas_equalTo(49);
        make.top.mas_equalTo(self.textView.mas_bottom);
    }];
    
    [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(self.textField.mas_bottom).offset(24);
        make.right.offset(-15);
        make.height.offset(44);
    }];
    
    [self.fanKuiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.submitButton.mas_left);
        make.width.greaterThanOrEqualTo(0);
        make.top.mas_equalTo(self.submitButton.mas_bottom).offset(80);
    }];
    
    [super updateConstraints];
}

#pragma mark - SSJBaseNetworkService
-(void)serverDidFinished:(SSJBaseNetworkService *)service
{
    if ([service.returnCode isEqualToString:@"1"]) {
        [self clearAdviceContext];
    }
    [CDAutoHideMessageHUD showMessage:service.desc];
}

#pragma mark -Getter
- (CGFloat)headerHeight
{
    return 417;
}

#pragma mark -Lazy
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = [UIColor whiteColor];
        [_topView addSubview:self.adviceBtn];
        [_topView addSubview:self.faultBtn];
        [_topView addSubview:self.tucaoBtn];
    }
    return _topView;
}

- (UIButton *)adviceBtn {
    if (!_adviceBtn) {
        _adviceBtn = [[UIButton alloc] init];
        _adviceBtn.layer.cornerRadius = 4;
        _adviceBtn.layer.masksToBounds = YES;
        _adviceBtn.layer.borderColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].borderColor].CGColor;
        _adviceBtn.layer.borderWidth = 1;
        [_adviceBtn setTitle:@"产品建议" forState:UIControlStateNormal];
        [_adviceBtn setTitleColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].mainColor] forState:UIControlStateNormal];
        _adviceBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
//        [_adviceBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].mainBackGroundColor] forState:UIControlStateNormal];
//        [_adviceBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].borderColor] forState:UIControlStateReserved];
        [[_adviceBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
            btn.selected = !btn.selected;
            if (btn.selected == YES) {
                btn.backgroundColor = [UIColor ssj_colorWithHex:@"dddddd"];
                self.adviceType = SSJAdviceTypeAdvice;
            } else {
                btn.backgroundColor = [UIColor whiteColor];
            }
            self.faultBtn.selected = NO;
            self.faultBtn.backgroundColor = [UIColor whiteColor];
            
            self.tucaoBtn.selected = NO;
            self.tucaoBtn.backgroundColor = [UIColor whiteColor];
        }];
    }
    return _adviceBtn;
}

- (UIButton *)faultBtn {
    if (!_faultBtn) {
        _faultBtn = [[UIButton alloc] init];
        _faultBtn.layer.cornerRadius = 4;
        _faultBtn.layer.masksToBounds = YES;
        _faultBtn.layer.borderColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].borderColor].CGColor;
        _faultBtn.layer.borderWidth = 1;
        [_faultBtn setTitle:@"使用故障" forState:UIControlStateNormal];
        [_faultBtn setTitleColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].mainColor] forState:UIControlStateNormal];
        _faultBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [[_faultBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
            btn.selected = !btn.selected;
            if (btn.selected == YES) {
                btn.backgroundColor = [UIColor ssj_colorWithHex:@"dddddd"];
                self.adviceType = SSJAdviceTypeFault;
            } else {
                btn.backgroundColor = [UIColor whiteColor];
            }
            self.tucaoBtn.selected = NO;
            self.tucaoBtn.backgroundColor = [UIColor whiteColor];
            
            self.adviceBtn.selected = NO;
            self.adviceBtn.backgroundColor = [UIColor whiteColor];
        }];
    }
    return _faultBtn;
}

- (UIButton *)tucaoBtn {
    if (!_tucaoBtn) {
        _tucaoBtn = [[UIButton alloc] init];
        _tucaoBtn.layer.cornerRadius = 4;
        _tucaoBtn.layer.masksToBounds = YES;
        _tucaoBtn.layer.borderColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].borderColor].CGColor;
        _tucaoBtn.layer.borderWidth = 1;
        [_tucaoBtn setTitle:@"我要吐槽" forState:UIControlStateNormal];
        [_tucaoBtn setTitleColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].mainColor] forState:UIControlStateNormal];
        _tucaoBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [[_tucaoBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *btn) {
            btn.selected = !btn.selected;
            if (btn.selected == YES) {
                btn.backgroundColor = [UIColor ssj_colorWithHex:@"dddddd"];
                self.adviceType = SSJAdviceTypeTuCao;
            } else {
                btn.backgroundColor = [UIColor whiteColor];
            }
            self.faultBtn.selected = NO;
            self.faultBtn.backgroundColor = [UIColor whiteColor];
            
            self.adviceBtn.selected = NO;
            self.adviceBtn.backgroundColor = [UIColor whiteColor];
        }];
    }
    return _tucaoBtn;
}

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.backgroundColor = [UIColor whiteColor];
        _textField.placeholder = @"手机号/微信号/QQ号）";
        _textField.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [_textField ssj_setBorderColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].borderColor]];
        [_textField ssj_setBorderWidth:1];
        [_textField ssj_setBorderStyle:SSJBorderStyleBottom];
        _textField.textColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].mainColor];
        [_textField setValue: [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].borderColor] forKeyPath:@"_placeholderLabel.textColor"];
        UIView *leftview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 13, _textField.height)];
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.leftView = leftview;
    }
    return _textField;
}


- (SSJCustomTextView *)textView
{
    if (!_textView) {
        _textView = [[SSJCustomTextView alloc] init];
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.placeholder = @"请填写反馈内容，越详细越好哦～";
        _textView.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [_textView ssj_setBorderColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].borderColor]];
        [_textView ssj_setBorderWidth:1];
        [_textView ssj_setBorderStyle:SSJBorderStyleBottom | SSJBorderStyleTop];
        _textView.textColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].mainColor];
        _textView.placeholderColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].borderColor];
        _textView.placeholderTopConst = 0;
        _textView.placeholderLeftConst = 13;
    }
    return _textView;
}


- (UIButton *)submitButton
{
    if (!_submitButton) {
        _submitButton = [[UIButton alloc] init];
        [_submitButton setTitle:@"提交" forState:UIControlStateNormal];
        [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _submitButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _submitButton.layer.cornerRadius = 5;
        _submitButton.clipsToBounds = YES;
       _submitButton.backgroundColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].marcatoColor];
        [_submitButton addTarget:self action:@selector(submitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}

- (UILabel *)fanKuiLabel
{
    if (!_fanKuiLabel) {
        _fanKuiLabel = [[UILabel alloc] init];
        _fanKuiLabel.text = @"直面小鱼，快速反馈";
        _fanKuiLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _fanKuiLabel.textColor = [UIColor ssj_colorWithHex:@"#999999"];
        _fanKuiLabel.backgroundColor = [UIColor clearColor];
    }
    return _fanKuiLabel;
}

- (UIView *)bottomBgview
{
    if (!_bottomBgview) {
        _bottomBgview = [[UIView alloc] init];
        _bottomBgview.backgroundColor = [UIColor whiteColor];
        [_bottomBgview ssj_setBorderStyle:SSJBorderStyleBottom];
        [_bottomBgview ssj_setBorderWidth:0.5];
        [_bottomBgview ssj_setBorderColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].borderColor]];
        
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
    BOOL isSelected = NO;
    NSArray *bunArr = @[self.adviceBtn,self.faultBtn,self.tucaoBtn];
    for (UIButton *btn in bunArr) {
        if (btn.selected) {
            isSelected = YES;
        }
    }
    if (!isSelected) {
        [CDAutoHideMessageHUD showMessage:@"请选择类型再提交哦"];
        return;
    }
    [self.adviceService requestAdviceMessageListWithType:self.adviceType message:self.textView.text additionalMessage:self.textField.text];

}

- (void)clearAdviceContext
{
    [self endEditing:YES];
    self.textView.text = @"";
    self.textField.text = @"";
}

#pragma mark -Lazy
- (SSJProductAdviceNetWorkService *)adviceService{
    if (!_adviceService) {
        _adviceService = [[SSJProductAdviceNetWorkService alloc]initWithDelegate:self];
        _adviceService.httpMethod = SSJBaseNetworkServiceHttpMethodPOST;
    }
    return _adviceService;
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
