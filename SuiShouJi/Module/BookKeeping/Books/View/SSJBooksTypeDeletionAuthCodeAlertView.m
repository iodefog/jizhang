//
//  SSJBooksTypeDeletionAuthCodeAlertView.m
//  SuiShouJi
//
//  Created by old lang on 17/4/24.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBooksTypeDeletionAuthCodeAlertView.h"
#import "YYKeyboardManager.h"

#pragma mark -
#pragma mark - SSJBooksTypeDeletionAuthCodeField

static const CGFloat kGap = 15;

@interface SSJBooksTypeDeletionAuthCodeField : UIControl

@property (nonatomic, copy) NSString *authCode;

- (BOOL)becomeFirstResponder;

- (BOOL)resignFirstResponder;

@end

@interface SSJBooksTypeDeletionAuthCodeField () <UITextFieldDelegate>

@property (nonatomic) int codeDigits;

@property (nonatomic, strong) UITextField *field;

@property (nonatomic, strong) NSMutableArray<UIView *> *borderViews;

@end

@implementation SSJBooksTypeDeletionAuthCodeField

- (instancetype)initWithFrame:(CGRect)frame authCodeDigits:(int)digits {
    if (self = [super initWithFrame:frame]) {
        self.codeDigits = digits;
        [self addSubview:self.field];
        self.borderViews = [NSMutableArray arrayWithCapacity:digits];
        for (int i = 0; i < digits; i ++) {
            UIView *view = [[UIView alloc] init];
            view.userInteractionEnabled = NO;
            view.layer.borderWidth = 1;
            view.layer.borderColor = [UIColor blueColor].CGColor;
            [self addSubview:view];
            [self.borderViews addObject:view];
        }
    }
    return self;
}

- (void)updateConstraints {
    [self.field mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    [self.borderViews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:15 leadSpacing:0 tailSpacing:0];
    [self.borderViews mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(self);
    }];
    [super updateConstraints];
}

- (void)setAuthCode:(NSString *)authCode {
    self.field.text = authCode;
}

- (NSString *)authCode {
    return self.field.attributedText.string;
}

- (BOOL)becomeFirstResponder {
    return [self.field becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [self.field resignFirstResponder];
}

- (void)textDidChange:(id)value {
    [self updateSpaceBetweenLetters];
    [self sendActionsForControlEvents:UIControlEventAllEditingEvents];
}

- (void)updateSpaceBetweenLetters {
    CGFloat cellWdith = (CGRectGetWidth(self.bounds) - (self.codeDigits - 1) * kGap) / self.codeDigits;
    NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *preAttributeLetter = nil;
    CGFloat preKern = 0;
    for (int i = 0; i < self.field.text.length; i ++) {
        NSString *letter = [self.field.text substringWithRange:NSMakeRange(i, 1)];
        CGSize letterSize = [letter sizeWithAttributes:@{NSFontAttributeName:self.field.font}];
        CGFloat kern = (cellWdith - letterSize.width) * 0.5;
        NSMutableAttributedString *attributeLetter = nil;
        if (i == 0) {
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.firstLineHeadIndent = kern;
            attributeLetter = [[NSMutableAttributedString alloc] initWithString:letter attributes:@{NSParagraphStyleAttributeName:style}];
        } else {
            [attributeText addAttributes:@{NSKernAttributeName:@(kern + preKern + kGap)} range:NSMakeRange(i - 1, 1)];
            attributeLetter = [[NSMutableAttributedString alloc] initWithString:letter attributes:@{}];
        }
        [attributeText appendAttributedString:attributeLetter];
        preAttributeLetter = attributeLetter;
        preKern = kern;
    }
    _field.attributedText = attributeText;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (text.length > self.codeDigits) {
        return NO;
    }
    return YES;
}

- (UITextField *)field {
    if (!_field) {
        _field = [[UITextField alloc] init];
        _field.textColor = [UIColor blackColor];
        _field.keyboardType = UIKeyboardTypeNumberPad;
        [_field addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventAllEditingEvents];
        _field.delegate = self;
    }
    return _field;
}

@end

#pragma mark - 
#pragma mark - SSJBooksTypeDeletionAuthCodeAlertView

static const int kAuthCodeDigits = 4;

static const CGFloat kAnimationDuration = 0.25;

@interface SSJBooksTypeDeletionAuthCodeAlertView () <YYKeyboardObserver>

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UILabel *authCodeLab;

@property (nonatomic, strong) SSJBooksTypeDeletionAuthCodeField *authCodeField;

@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) UIButton *sureBtn;

@property (nonatomic, strong) NSString *authCode;

@end

@implementation SSJBooksTypeDeletionAuthCodeAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 3;
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.titleLab];
        [self addSubview:self.authCodeLab];
        [self addSubview:self.authCodeField];
        [self addSubview:self.cancelBtn];
        [self addSubview:self.sureBtn];
        [self sizeToFit];
        [self setNeedsUpdateConstraints];
        [[YYKeyboardManager defaultManager] addObserver:self];
        [self setupBindings];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(290, 230);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.cancelBtn ssj_relayoutBorder];
    [self.sureBtn ssj_relayoutBorder];
}

- (void)updateConstraints {
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(14);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(240);
    }];
    [self.authCodeLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLab.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(148, 40));
    }];
    [self.authCodeField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.authCodeLab.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(194, 35));
    }];
    [self.cancelBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(145, 50));
    }];
    [self.sureBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.cancelBtn.mas_right);
        make.bottom.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(145, 50));
    }];
    [super updateConstraints];
}

- (void)show {
    self.authCodeField.authCode = nil;
    [self.authCodeField becomeFirstResponder];
    [self genAuthCode];
    [SSJ_KEYWINDOW ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.3 target:nil touchAction:NULL animation:NULL timeInterval:kAnimationDuration fininshed:NULL];
}

- (void)dismiss {
    [self.superview ssj_hideBackViewForView:self animation:NULL timeInterval:kAnimationDuration fininshed:NULL];
}

- (void)cancelAction {
    [self dismiss];
}

- (void)sureAction {
    if ([self.authCodeField.authCode isEqualToString:self.authCode]) {
        [self dismiss];
        if (self.finishVerification) {
            self.finishVerification();
        }
    } else {
        [CDAutoHideMessageHUD showMessage:@"输入错误，请重新输入"];
        [self shake:^{
            self.authCodeField.authCode = nil;
        }];
    }
}

- (void)shake:(void(^)())completion {
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1.0 / 12 animations:^{
            self.transform = CGAffineTransformMakeTranslation(-10, 0);
        }];
        [UIView addKeyframeWithRelativeStartTime:1.0 / 12 relativeDuration:1.0 / 6 animations:^{
            self.transform = CGAffineTransformMakeTranslation(10, 0);
        }];
        [UIView addKeyframeWithRelativeStartTime:3.0 / 12 relativeDuration:1.0 / 6 animations:^{
            self.transform = CGAffineTransformMakeTranslation(-10, 0);
        }];
        [UIView addKeyframeWithRelativeStartTime:5.0 / 12 relativeDuration:1.0 / 6 animations:^{
            self.transform = CGAffineTransformMakeTranslation(10, 0);
        }];
        [UIView addKeyframeWithRelativeStartTime:7.0 / 12 relativeDuration:1.0 / 6 animations:^{
            self.transform = CGAffineTransformMakeTranslation(-10, 0);
        }];
        [UIView addKeyframeWithRelativeStartTime:9.0 / 12 relativeDuration:1.0 / 6 animations:^{
            self.transform = CGAffineTransformMakeTranslation(10, 0);
        }];
        [UIView addKeyframeWithRelativeStartTime:11.0 / 12 relativeDuration:1.0 / 12 animations:^{
            self.transform = CGAffineTransformIdentity;
        }];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)genAuthCode {
    NSMutableString *authCode = [NSMutableString stringWithCapacity:kAuthCodeDigits];
    for (int i = 0; i < kAuthCodeDigits; i ++) {
        int number = arc4random() % 10;
        [authCode appendFormat:@"%d", number];
    }
    self.authCode = [authCode copy];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.firstLineHeadIndent = 22;
    self.authCodeLab.attributedText = [[NSAttributedString alloc] initWithString:authCode attributes:@{NSParagraphStyleAttributeName:style, NSKernAttributeName:@12}];
}

- (void)setupBindings {
    RAC(self.sureBtn, enabled) = [[self.authCodeField rac_signalForControlEvents:UIControlEventAllEditingEvents] map:^id(SSJBooksTypeDeletionAuthCodeField *field) {
        return @(field.authCode.length == kAuthCodeDigits);
    }];
}

#pragma mark - YYKeyboardObserver
- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    if (!transition.fromVisible || transition.toVisible) {
//        [self mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.centerX.mas_equalTo(self.superview);
//            make.centerY.mas_equalTo(self.superview.mas_top).offset((SSJ_KEYWINDOW.height - [YYKeyboardManager defaultManager].keyboardFrame.size.height) * 0.5);
//        }];
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.centerX = self.superview.width * 0.5;
            self.centerY = (SSJ_KEYWINDOW.height - [YYKeyboardManager defaultManager].keyboardFrame.size.height) * 0.5;
        }];
    }
}

#pragma mark - Lazyloading
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:13];
        _titleLab.textColor = [UIColor ssj_colorWithHex:@"#999999"];
        _titleLab.text = @"删除后将难以恢复，仍然删除，请输入下列验证码";
        _titleLab.numberOfLines = 0;
    }
    return _titleLab;
}

- (UILabel *)authCodeLab {
    if (!_authCodeLab) {
        _authCodeLab = [[UILabel alloc] init];
        _authCodeLab.font = [UIFont systemFontOfSize:15];
        _authCodeLab.textColor = [UIColor blackColor];
        _authCodeLab.backgroundColor = [UIColor lightGrayColor];
    }
    return _authCodeLab;
}

- (SSJBooksTypeDeletionAuthCodeField *)authCodeField {
    if (!_authCodeField) {
        _authCodeField = [[SSJBooksTypeDeletionAuthCodeField alloc] initWithFrame:CGRectZero authCodeDigits:kAuthCodeDigits];
    }
    return _authCodeField;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor ssj_colorWithHex:@"#333333"] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [_cancelBtn ssj_setBorderStyle:(SSJBorderStyleTop | SSJBorderStyleRight)];
        [_cancelBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:@"#dddddd"]];
    }
    return _cancelBtn;
}

- (UIButton *)sureBtn {
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_sureBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_sureBtn setTitleColor:[UIColor ssj_colorWithHex:@"#333333"] forState:UIControlStateNormal];
        [_sureBtn setTitleColor:[[UIColor ssj_colorWithHex:@"#333333"] colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        [_sureBtn addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
        [_sureBtn ssj_setBorderStyle:(SSJBorderStyleTop)];
        [_sureBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:@"#dddddd"]];
    }
    return _sureBtn;
}

@end
