//
//  SSJRecordMakingBillTypeInputAccessoryView.m
//  SuiShouJi
//
//  Created by old lang on 16/5/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingBillTypeInputAccessoryView.h"

static const int kMaxCharacterLength = 50;

@interface SSJRecordMakingBillTypeInputAccessoryView () <UITextFieldDelegate>

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UITextField *memoView;

@property (nonatomic, strong) UIButton *accountBtn;

@property (nonatomic, strong) UIButton *dateBtn;

@property (nonatomic, strong) UIButton *photoBtn;

@property (nonatomic, strong) UIButton *periodBtn;

@end

@implementation SSJRecordMakingBillTypeInputAccessoryView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.topView];
        [self addSubview:self.bottomView];
        
        [self.topView addSubview:self.memoView];
        [self.bottomView addSubview:self.accountBtn];
        [self.bottomView addSubview:self.dateBtn];
        [self.bottomView addSubview:self.photoBtn];
        [self.bottomView addSubview:self.periodBtn];
    }
    return self;
}

- (void)layoutSubviews {
    _topView.frame = CGRectMake(0, 0, self.width, 50);
    _bottomView.frame = CGRectMake(0, _topView.bottom, self.width, 37);
    
    CGFloat horizontalGap = (_bottomView.width - _accountBtn.width - _dateBtn.width - _photoBtn.width - _periodBtn.width) * 0.2;
    _accountBtn.left = horizontalGap;
    _dateBtn.left = _accountBtn.right + horizontalGap;
    _photoBtn.left = _dateBtn.right + horizontalGap;
    _periodBtn.left = _photoBtn.right + horizontalGap;
    _accountBtn.centerY = _dateBtn.centerY = _photoBtn.centerY = _periodBtn.centerY = _bottomView.height * 0.5;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = textField.text ? : @"";
    text = [text stringByReplacingCharactersInRange:range withString:string];
    if (string.length > kMaxCharacterLength) {
        [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"最多只能输入%d个字", kMaxCharacterLength]];
        return NO;
    }
    return YES;
}

#pragma mark - Getter
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 50)];
        _topView.backgroundColor = [UIColor whiteColor];
        UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        img.left = 10;
        img.centerY = _topView.height * 0.5;
        [_topView addSubview:img];
        [_topView ssj_setBorderWidth:1];
        [_topView ssj_setBorderColor:[UIColor ssj_colorWithHex:@"D9DADC"]];
        [_topView ssj_setBorderStyle:(SSJBorderStyleTop | SSJBorderStyleBottom)];
    }
    return _topView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _topView.bottom, self.width, 37)];
        _bottomView.backgroundColor = [UIColor ssj_colorWithHex:@"F4F4F4"];
        [_bottomView ssj_setBorderWidth:1];
        [_bottomView ssj_setBorderColor:[UIColor ssj_colorWithHex:@"D9DADC"]];
        [_bottomView ssj_setBorderStyle:SSJBorderStyleBottom];
    }
    return _bottomView;
}

- (UITextField *)memoView {
    if (!_memoView) {
        _memoView = [[UITextField alloc] initWithFrame:CGRectMake(40, 0, self.topView.width - 40, self.topView.height)];
        _memoView.delegate = self;
        _memoView.font = [UIFont systemFontOfSize:13];
        _memoView.placeholder = @"写点啥备注下";
    }
    return _memoView;
}

- (UIButton *)accountBtn {
    if (!_accountBtn) {
        _accountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _accountBtn.frame = CGRectMake(0, 0, 66, 24);
        _accountBtn.layer.borderWidth = 1;
        _accountBtn.layer.borderColor = [UIColor ssj_colorWithHex:@"858585"].CGColor;
        _accountBtn.layer.cornerRadius = _accountBtn.height * 0.5;
    }
    return _accountBtn;
}

- (UIButton *)dateBtn {
    if (!_dateBtn) {
        _dateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _dateBtn.frame = CGRectMake(0, 0, 66, 24);
        _dateBtn.layer.borderWidth = 1;
        _dateBtn.layer.borderColor = [UIColor ssj_colorWithHex:@"858585"].CGColor;
        _dateBtn.layer.cornerRadius = _dateBtn.height * 0.5;
    }
    return _dateBtn;
}

- (UIButton *)photoBtn {
    if (!_photoBtn) {
        _photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoBtn.frame = CGRectMake(0, 0, 66, 24);
        _photoBtn.layer.borderWidth = 1;
        _photoBtn.layer.borderColor = [UIColor ssj_colorWithHex:@"858585"].CGColor;
        _photoBtn.layer.cornerRadius = _photoBtn.height * 0.5;
    }
    return _photoBtn;
}

- (UIButton *)periodBtn {
    if (!_periodBtn) {
        _periodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _periodBtn.frame = CGRectMake(0, 0, 66, 24);
        _periodBtn.layer.borderWidth = 1;
        _periodBtn.layer.borderColor = [UIColor ssj_colorWithHex:@"858585"].CGColor;
        _periodBtn.layer.cornerRadius = _periodBtn.height * 0.5;
    }
    return _periodBtn;
}

@end
