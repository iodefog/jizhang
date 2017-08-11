//
//  SSJLoanInterestTypeAlertView.m
//  SuiShouJi
//
//  Created by old lang on 16/11/16.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanInterestTypeAlertView.h"

static NSString *const kNormalBorderColorValue = @"#aaaaaa";

static NSString *const kSelectedBorderColorValue = @"#EE4F4F";

@interface SSJLoanInterestTypeAlertView ()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIButton *originalPrincipalButton;

@property (nonatomic, strong) UIButton *changePrincipalButton;

@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) UIImageView *background;

@end

@implementation SSJLoanInterestTypeAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.background];
        [self addSubview:self.titleLab];
        [self addSubview:self.originalPrincipalButton];
        [self addSubview:self.changePrincipalButton];
        [self addSubview:self.sureButton];
        [self sizeToFit];
        
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 3;
        self.backgroundColor = [UIColor whiteColor];
        self.interestType = SSJLoanInterestTypeUnknown;
        
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    return CGSizeMake(window.width * 0.86, 324);
}

- (void)layoutSubviews {
    self.originalPrincipalButton.size = CGSizeMake(self.width * 0.82, 44);
    self.changePrincipalButton.size = CGSizeMake(self.width * 0.82, 44);
    self.sureButton.size = CGSizeMake(self.width * 0.82, 44);
    
    self.originalPrincipalButton.layer.cornerRadius = self.originalPrincipalButton.height * 0.5;
    self.changePrincipalButton.layer.cornerRadius = self.changePrincipalButton.height * 0.5;
    self.sureButton.layer.cornerRadius = self.sureButton.height * 0.5;
    
    [self.titleLab sizeToFit];
    self.titleLab.top = 45;
    self.originalPrincipalButton.top = 90;
    self.changePrincipalButton.top = 150;
    self.sureButton.top = 246;
    
    self.titleLab.centerX = self.originalPrincipalButton.centerX = self.changePrincipalButton.centerX = self.sureButton.centerX = self.width * 0.5;
    
    self.background.width = self.width;
    self.background.height = 50;
    self.background.bottom = self.height;
}

#pragma mark - Event
- (void)originalPrincipalButtonAction {
    self.interestType = SSJLoanInterestTypeOriginalPrincipal;
}

- (void)changePrincipalButtonAction {
    self.interestType = SSJLoanInterestTypeChangePrincipal;
}

- (void)sureButtonAction {
    if (self.sureAction) {
        self.sureAction(self);
    }
}

#pragma mark - Setter
- (void)setTitle:(NSString *)title {
    self.titleLab.text = title;
}

- (void)setOriginalPrincipalButtonTitle:(NSString *)originalPrincipalButtonTitle {
    [self.originalPrincipalButton setTitle:originalPrincipalButtonTitle forState:UIControlStateNormal];
}

- (void)setChangePrincipalButtonTitle:(NSString *)changePrincipalButtonTitle {
    [self.changePrincipalButton setTitle:changePrincipalButtonTitle forState:UIControlStateNormal];
}

- (void)setInterestType:(SSJLoanInterestTypeAlertViewType)interestType {
    _interestType = interestType;
    switch (_interestType) {
        case SSJLoanInterestTypeAlertViewTypeOriginalPrincipal:
            self.originalPrincipalButton.layer.borderColor = [UIColor ssj_colorWithHex:kSelectedBorderColorValue].CGColor;
            self.changePrincipalButton.layer.borderColor = [UIColor ssj_colorWithHex:kNormalBorderColorValue].CGColor;
            break;
            
        case SSJLoanInterestTypeAlertViewTypeChangePrincipal:
            self.originalPrincipalButton.layer.borderColor = [UIColor ssj_colorWithHex:kNormalBorderColorValue].CGColor;
            self.changePrincipalButton.layer.borderColor = [UIColor ssj_colorWithHex:kSelectedBorderColorValue].CGColor;
            break;
    }
}

#pragma mark - Getter
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _titleLab.textColor = [UIColor ssj_colorWithHex:@"#393939"];
    }
    return _titleLab;
}

- (UIButton *)originalPrincipalButton {
    if (!_originalPrincipalButton) {
        _originalPrincipalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalPrincipalButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _originalPrincipalButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _originalPrincipalButton.titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        [_originalPrincipalButton setTitleColor:[UIColor ssj_colorWithHex:@"#343434"] forState:UIControlStateNormal];
        [_originalPrincipalButton addTarget:self action:@selector(originalPrincipalButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        _originalPrincipalButton.layer.borderWidth = 1;
        _originalPrincipalButton.layer.borderColor = [UIColor ssj_colorWithHex:kNormalBorderColorValue].CGColor;
    }
    return _originalPrincipalButton;
}

- (UIButton *)changePrincipalButton {
    if (!_changePrincipalButton) {
        _changePrincipalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _changePrincipalButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _changePrincipalButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _changePrincipalButton.titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        [_changePrincipalButton setTitleColor:[UIColor ssj_colorWithHex:@"#343434"] forState:UIControlStateNormal];
        [_changePrincipalButton addTarget:self action:@selector(changePrincipalButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        _changePrincipalButton.layer.borderWidth = 1;
        _changePrincipalButton.layer.borderColor = [UIColor ssj_colorWithHex:kSelectedBorderColorValue].CGColor;
    }
    return _changePrincipalButton;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.clipsToBounds = YES;
        _sureButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:kSelectedBorderColorValue] forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(sureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

- (UIImageView *)background {
    if (!_background) {
        _background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loan_alert_background"]];
    }
    return _background;
}

@end
