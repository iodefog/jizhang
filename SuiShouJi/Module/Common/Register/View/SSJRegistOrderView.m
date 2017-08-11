//
//  SSJRegistOrderView.m
//  SuiShouJi
//
//  Created by old lang on 16/1/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRegistOrderView.h"

#define SSJ_NORMAL_COLOR [UIColor ssj_colorWithHex:@"#a7a7a7"]
#define SSJ_HIGHLIGHTED_COLOR [UIColor ssj_colorWithHex:@"#EE4F4F"]

@interface SSJRegistOrderView ()

@property (nonatomic) SSJRegistOrderType orderType;

@property (nonatomic, strong) UILabel *phoneNoLabel;

@property (nonatomic, strong) UILabel *authCodeLabel;

@property (nonatomic, strong) UILabel *passwordLabel;

@property (nonatomic, strong) UILabel *greaterLabel1;

@property (nonatomic, strong) UILabel *greaterLabel2;

@end

@implementation SSJRegistOrderView

- (instancetype)initWithFrame:(CGRect)frame withOrderType:(SSJRegistOrderType)order {
    if (self = [super initWithFrame:frame]) {
        self.orderType = order;
        [self addSubview:self.phoneNoLabel];
        [self addSubview:self.authCodeLabel];
        [self addSubview:self.passwordLabel];
        [self addSubview:self.greaterLabel1];
        [self addSubview:self.greaterLabel2];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame withOrderType:SSJRegistOrderTypeInputPhoneNo];
}

- (void)layoutSubviews {
    CGFloat greaterWidth = (self.width - self.phoneNoLabel.width - self.authCodeLabel.width - self.passwordLabel.width) * 0.5;
    self.phoneNoLabel.frame = CGRectMake(0, 0, self.phoneNoLabel.width, self.height);
    self.greaterLabel1.frame = CGRectMake(self.phoneNoLabel.right, 0, greaterWidth, self.height);
    self.authCodeLabel.frame = CGRectMake(self.greaterLabel1.right, 0, self.authCodeLabel.width, self.height);
    self.greaterLabel2.frame = CGRectMake(self.authCodeLabel.right, 0, greaterWidth, self.height);
    self.passwordLabel.frame = CGRectMake(self.greaterLabel2.right, 0, self.passwordLabel.width, self.height);
}

- (UILabel *)phoneNoLabel {
    if (!_phoneNoLabel) {
        _phoneNoLabel = [[UILabel alloc] init];
        _phoneNoLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
        _phoneNoLabel.textColor = self.orderType == SSJRegistOrderTypeInputPhoneNo ? SSJ_HIGHLIGHTED_COLOR : SSJ_NORMAL_COLOR;
        _phoneNoLabel.text = @"1 输入手机号码";
        [_phoneNoLabel sizeToFit];
    }
    return _phoneNoLabel;
}

- (UILabel *)authCodeLabel {
    if (!_authCodeLabel) {
        _authCodeLabel = [[UILabel alloc] init];
        _authCodeLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
        _authCodeLabel.textColor = self.orderType == SSJRegistOrderTypeInputAuthCode ? SSJ_HIGHLIGHTED_COLOR : SSJ_NORMAL_COLOR;
        _authCodeLabel.text = @"2 输入验证码";
        [_authCodeLabel sizeToFit];
    }
    return _authCodeLabel;
}

- (UILabel *)passwordLabel {
    if (!_passwordLabel) {
        _passwordLabel = [[UILabel alloc] init];
        _passwordLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
        _passwordLabel.textColor = self.orderType == SSJRegistOrderTypeSetPassword ? SSJ_HIGHLIGHTED_COLOR : SSJ_NORMAL_COLOR;
        _passwordLabel.text = @"3 设置密码";
        [_passwordLabel sizeToFit];
    }
    return _passwordLabel;
}

- (UILabel *)greaterLabel1 {
    if (!_greaterLabel1) {
        _greaterLabel1 = [[UILabel alloc] init];
        [self setGreaterLabel:_greaterLabel1];
    }
    return _greaterLabel1;
}

- (UILabel *)greaterLabel2 {
    if (!_greaterLabel2) {
        _greaterLabel2 = [[UILabel alloc] init];
        [self setGreaterLabel:_greaterLabel2];
    }
    return _greaterLabel2;
}

- (void)setGreaterLabel:(UILabel *)label {
    label.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
    label.textColor = SSJ_NORMAL_COLOR;
    label.text = @">";
    label.textAlignment = NSTextAlignmentCenter;
}

@end
