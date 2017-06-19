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

- (BOOL)isFirstResponder;

- (void)updateAppearance;

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

- (BOOL)isFirstResponder {
    return [self.field isFirstResponder];
}

- (void)updateAppearance {
    for (UIView *view in self.borderViews) {
        view.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor].CGColor;
    }
    self.field.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
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
        _field.keyboardType = UIKeyboardTypeNumberPad;
        [_field addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventAllEditingEvents];
        _field.delegate = self;
        _field.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
    }
    return _field;
}

@end

#pragma mark - 
#pragma mark - SSJBooksTypeDeletionAuthCodeAlertView

static const int kAuthCodeDigits = 4;

@interface SSJBooksTypeDeletionAuthCodeAlertView () <YYKeyboardObserver>

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UILabel *authCodeLab;

@property (nonatomic, strong) SSJBooksTypeDeletionAuthCodeField *authCodeField;

@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) UIButton *sureBtn;

@property (nonatomic, strong) NSString *authCode;

@property (nonatomic, strong) UIView *backView;

@end

@implementation SSJBooksTypeDeletionAuthCodeAlertView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 5;
        [self addSubview:self.titleLab];
        [self addSubview:self.authCodeLab];
        [self addSubview:self.authCodeField];
        [self addSubview:self.cancelBtn];
        [self addSubview:self.sureBtn];
        [self sizeToFit];
        [self setupBindings];
        [self updateAppearance];
        [self setNeedsUpdateConstraints];
        [[YYKeyboardManager defaultManager] addObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearance) name:SSJThemeDidChangeNotification object:nil];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(280, 270);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateAuthCodeText];
}

- (void)updateConstraints {
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(25);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(self);
    }];
    [self.authCodeLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLab.mas_bottom).offset(25);
        make.centerX.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(148, 40));
    }];
    [self.authCodeField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.authCodeLab.mas_bottom).offset(25);
        make.centerX.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(205, 40));
    }];
    [self.sureBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(self);
        make.height.mas_equalTo(50);
    }];
    [self.cancelBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.sureBtn.mas_right);
        make.bottom.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.width.and.height.mas_equalTo(self.sureBtn);
    }];
    
    [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(SSJ_KEYWINDOW);
    }];
    [super updateConstraints];
}

- (void)show {
    self.authCodeField.authCode = nil;
    [self genAuthCode];
    self.centerX = SSJ_KEYWINDOW.width * 0.5;
    self.top = SSJ_KEYWINDOW.height;
    self.backView.alpha = 0;
    if (!self.backView.superview) {
        [SSJ_KEYWINDOW addSubview:self.backView];
    }
    if (!self.superview) {
        [SSJ_KEYWINDOW addSubview:self];
    }
    [self.authCodeField becomeFirstResponder];
}

- (void)dismiss {
    [self.authCodeField resignFirstResponder];
}

#pragma mark - Event
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

#pragma mark - Private
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
    [self updateAuthCodeText];
}

- (void)updateAuthCodeText {
    if (CGRectIsEmpty(self.authCodeLab.bounds)) {
        return;
    }
    CGSize textSize = [self.authCode sizeWithAttributes:@{NSFontAttributeName:self.authCodeLab.font}];
    CGFloat kern = (self.authCodeLab.width - textSize.width) / (self.authCode.length + 1);
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.firstLineHeadIndent = kern;
    self.authCodeLab.attributedText = [[NSAttributedString alloc] initWithString:self.authCode attributes:@{NSParagraphStyleAttributeName:style, NSKernAttributeName:@(kern)}];
}

- (void)setupBindings {
    RACSignal *sg_1 = [[self.authCodeField rac_signalForControlEvents:UIControlEventAllEditingEvents] map:^id(SSJBooksTypeDeletionAuthCodeField *field) {
        return @(field.authCode.length == kAuthCodeDigits);
    }];
    RACSignal *sg_2 = [RACObserve(self.authCodeField, authCode) map:^id(NSString *authCode) {
        return @(authCode.length == kAuthCodeDigits);
    }];
    RAC(self.sureBtn, enabled) = [RACSignal merge:@[sg_1, sg_2]];
}

- (void)updateAppearance {
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
    self.titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.authCodeLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.authCodeLab.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.authCodeGroundColor];
    [self.sureBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];
    [self.sureBtn setTitleColor:[[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
    [self.sureBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor]];
    [self.cancelBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
    [self.cancelBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor]];
    [self.authCodeField updateAppearance];
}

#pragma mark - YYKeyboardObserver
- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    if (![self.authCodeField isFirstResponder]) {
        return;
    }
    if (!transition.fromVisible && transition.toVisible) {
        self.backView.alpha = 0.3;
        self.centerY = (SSJ_KEYWINDOW.height - [YYKeyboardManager defaultManager].keyboardFrame.size.height) * 0.5;
    } else if (transition.fromVisible && !transition.toVisible) {
        self.backView.alpha = 0;
        self.top = SSJ_KEYWINDOW.bottom;
    }
}

- (void)setMessage:(NSAttributedString *)message {
    _titleLab.attributedText = message;
    [self setNeedsUpdateConstraints];
}

- (void)setSureButtonTitle:(NSString *)sureButtonTitle {
    [self.sureBtn setTitle:sureButtonTitle forState:UIControlStateNormal];
}

- (void)setCancelButtonTitle:(NSString *)cancelButtonTitle {
    [self.cancelBtn setTitle:cancelButtonTitle forState:UIControlStateNormal];
}

#pragma mark - Lazyloading
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _titleLab.numberOfLines = 0;
    }
    return _titleLab;
}

- (UILabel *)authCodeLab {
    if (!_authCodeLab) {
        _authCodeLab = [[UILabel alloc] init];
        _authCodeLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
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
        _cancelBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [_cancelBtn ssj_setBorderStyle:(SSJBorderStyleTop | SSJBorderStyleLeft)];
    }
    return _cancelBtn;
}

- (UIButton *)sureBtn {
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_sureBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_sureBtn addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
        [_sureBtn ssj_setBorderStyle:(SSJBorderStyleTop)];
    }
    return _sureBtn;
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor ssj_colorWithHex:@"#333333"];
    }
    return _backView;
}

@end
