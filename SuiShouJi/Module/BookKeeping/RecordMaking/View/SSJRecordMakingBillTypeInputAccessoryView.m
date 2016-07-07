//
//  SSJRecordMakingBillTypeInputAccessoryView.m
//  SuiShouJi
//
//  Created by old lang on 16/5/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingBillTypeInputAccessoryView.h"

static NSString *const kBorderColorValue = @"cccccc";

@interface SSJRecordMakingBillTypeInputAccessoryView ()

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIImageView *memoIcon;

@property (nonatomic, strong) UITextField *memoView;

@property (nonatomic, strong) UIButton *accountBtn;

@property (nonatomic, strong) UIButton *dateBtn;

@property (nonatomic, strong) UIButton *photoBtn;

@end

@implementation SSJRecordMakingBillTypeInputAccessoryView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.topView];
        [self addSubview:self.bottomView];
        
        [self.topView addSubview:self.memoIcon];
        [self.topView addSubview:self.memoView];
        [self.bottomView addSubview:self.accountBtn];
        [self.bottomView addSubview:self.dateBtn];
        [self.bottomView addSubview:self.photoBtn];
    }
    return self;
}

- (void)layoutSubviews {
    _topView.frame = CGRectMake(0, 0, self.width, 50);
    _bottomView.frame = CGRectMake(0, _topView.bottom, self.width, 37);
    
    CGFloat horizontalGap = (_bottomView.width - _accountBtn.width - _dateBtn.width - _photoBtn.width) * 0.25;
    _accountBtn.left = horizontalGap;
    _dateBtn.left = _accountBtn.right + horizontalGap;
    _photoBtn.left = _dateBtn.right + horizontalGap;
    _accountBtn.centerY = _dateBtn.centerY = _photoBtn.centerY = _bottomView.height * 0.5;
}

- (void)setButtonTitleNormalColor:(UIColor *)buttonTitleNormalColor {
    [_accountBtn setTitleColor:buttonTitleNormalColor forState:UIControlStateNormal];
    [_dateBtn setTitleColor:buttonTitleNormalColor forState:UIControlStateNormal];
    [_photoBtn setTitleColor:buttonTitleNormalColor forState:UIControlStateNormal];
    
    [_accountBtn setTitleColor:buttonTitleNormalColor forState:(UIControlStateNormal | UIControlStateHighlighted)];
    [_dateBtn setTitleColor:buttonTitleNormalColor forState:(UIControlStateNormal | UIControlStateHighlighted)];
    [_photoBtn setTitleColor:buttonTitleNormalColor forState:(UIControlStateNormal | UIControlStateHighlighted)];
}

- (void)setButtonTitleSelectedColor:(UIColor *)buttonTitleSelectedColor {
    [_accountBtn setTitleColor:buttonTitleSelectedColor forState:UIControlStateSelected];
    [_dateBtn setTitleColor:buttonTitleSelectedColor forState:UIControlStateSelected];
    [_photoBtn setTitleColor:buttonTitleSelectedColor forState:UIControlStateSelected];
    
    [_accountBtn setTitleColor:buttonTitleSelectedColor forState:(UIControlStateSelected | UIControlStateHighlighted)];
    [_dateBtn setTitleColor:buttonTitleSelectedColor forState:(UIControlStateSelected | UIControlStateHighlighted)];
    [_photoBtn setTitleColor:buttonTitleSelectedColor forState:(UIControlStateSelected | UIControlStateHighlighted)];
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
        [_topView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor]];
        [_topView ssj_setBorderStyle:(SSJBorderStyleTop | SSJBorderStyleBottom)];
    }
    return _topView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _topView.bottom, self.width, 37)];
        _bottomView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainFillColor];
        [_bottomView ssj_setBorderWidth:1];
        [_bottomView ssj_setBorderColor:[UIColor ssj_colorWithHex:@"D9DADC"]];
        [_bottomView ssj_setBorderStyle:SSJBorderStyleBottom];
    }
    return _bottomView;
}

- (UIImageView *)memoIcon {
    if (!_memoIcon) {
        _memoIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"record_making_memo"]];
        _memoIcon.left = 12;
        _memoIcon.centerY = self.topView.height * 0.5;
    }
    return _memoIcon;
}

- (UITextField *)memoView {
    if (!_memoView) {
        _memoView = [[UITextField alloc] initWithFrame:CGRectMake(40, 0, self.topView.width - 40, self.topView.height)];
        _memoView.font = [UIFont systemFontOfSize:13];
        _memoView.placeholder = @"写点啥备注下";
        _memoView.returnKeyType = UIReturnKeyDone;
    }
    return _memoView;
}

- (UIButton *)accountBtn {
    if (!_accountBtn) {
        _accountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _accountBtn.frame = CGRectMake(0, 0, 90, 24);
        _accountBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _accountBtn.layer.borderWidth = 1;
        _accountBtn.layer.borderColor = [UIColor ssj_colorWithHex:kBorderColorValue].CGColor;
        _accountBtn.layer.cornerRadius = _accountBtn.height * 0.5;
    }
    return _accountBtn;
}

- (UIButton *)dateBtn {
    if (!_dateBtn) {
        _dateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _dateBtn.frame = CGRectMake(0, 0, 90, 24);
        _dateBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _dateBtn.layer.borderWidth = 1;
        _dateBtn.layer.borderColor = [UIColor ssj_colorWithHex:kBorderColorValue].CGColor;
        _dateBtn.layer.cornerRadius = _dateBtn.height * 0.5;
    }
    return _dateBtn;
}

- (UIButton *)photoBtn {
    if (!_photoBtn) {
        _photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoBtn.frame = CGRectMake(0, 0, 90, 24);
        _photoBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _photoBtn.layer.borderWidth = 1;
        _photoBtn.layer.borderColor = [UIColor ssj_colorWithHex:kBorderColorValue].CGColor;
        _photoBtn.layer.cornerRadius = _photoBtn.height * 0.5;
    }
    return _photoBtn;
}

@end
