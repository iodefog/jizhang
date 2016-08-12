//
//  SSJRecordMakingBillTypeInputAccessoryView.m
//  SuiShouJi
//
//  Created by old lang on 16/5/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingBillTypeInputAccessoryView.h"

#define SSJ_BUTTON_NORMAL_BORDER_COLOR [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor alpha:0.5].CGColor
#define SSJ_BUTTON_SELECTED_BORDER_COLOR [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor].CGColor

@interface SSJRecordMakingBillTypeInputAccessoryView ()

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIImageView *memoIcon;

@property (nonatomic, strong) UITextField *memoView;

@property (nonatomic, strong) UIButton *accountBtn;

@property (nonatomic, strong) UIButton *dateBtn;

@property (nonatomic, strong) UIButton *photoBtn;

@property (nonatomic, strong) UIButton *memberBtn;

@end

@implementation SSJRecordMakingBillTypeInputAccessoryView

- (void)dealloc {
    [self.photoBtn removeObserver:self forKeyPath:@"selected"];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.topView];
        [self addSubview:self.bottomView];
        
        [self.topView addSubview:self.memoIcon];
        [self.topView addSubview:self.memoView];
        [self.bottomView addSubview:self.accountBtn];
        [self.bottomView addSubview:self.dateBtn];
        [self.bottomView addSubview:self.memberBtn];
        [self.bottomView addSubview:self.photoBtn];
        
        [self.photoBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)layoutSubviews {
    _topView.frame = CGRectMake(0, 0, self.width, 50);
    _bottomView.frame = CGRectMake(0, _topView.bottom, self.width, 37);
    
    CGFloat horizontalGap = (_bottomView.width - _accountBtn.width - _dateBtn.width - _photoBtn.width - _memberBtn.width) * 0.2;
    _accountBtn.left = horizontalGap;
    _dateBtn.left = _accountBtn.right + horizontalGap;
    _memberBtn.left = _dateBtn.right + horizontalGap;
    _photoBtn.left = _memberBtn.right + horizontalGap;
    _accountBtn.centerY = _dateBtn.centerY = _photoBtn.centerY =_memberBtn.centerY = _bottomView.height * 0.5;
}

- (void)setButtonTitleNormalColor:(UIColor *)buttonTitleNormalColor {
    [_accountBtn setTitleColor:buttonTitleNormalColor forState:UIControlStateNormal];
    [_dateBtn setTitleColor:buttonTitleNormalColor forState:UIControlStateNormal];
    [_photoBtn setTitleColor:buttonTitleNormalColor forState:UIControlStateNormal];
    
    [_accountBtn setTitleColor:buttonTitleNormalColor forState:(UIControlStateNormal | UIControlStateHighlighted)];
    [_dateBtn setTitleColor:buttonTitleNormalColor forState:(UIControlStateNormal | UIControlStateHighlighted)];
    [_memberBtn setTitleColor:buttonTitleNormalColor forState:(UIControlStateNormal | UIControlStateHighlighted)];
    [_photoBtn setTitleColor:buttonTitleNormalColor forState:(UIControlStateNormal | UIControlStateHighlighted)];
}

- (void)setButtonTitleSelectedColor:(UIColor *)buttonTitleSelectedColor {
    [_accountBtn setTitleColor:buttonTitleSelectedColor forState:UIControlStateSelected];
    [_dateBtn setTitleColor:buttonTitleSelectedColor forState:UIControlStateSelected];
    [_photoBtn setTitleColor:buttonTitleSelectedColor forState:UIControlStateSelected];
    
    [_accountBtn setTitleColor:buttonTitleSelectedColor forState:(UIControlStateSelected | UIControlStateHighlighted)];
    [_dateBtn setTitleColor:buttonTitleSelectedColor forState:(UIControlStateSelected | UIControlStateHighlighted)];
    [_memberBtn setTitleColor:buttonTitleSelectedColor forState:(UIControlStateNormal | UIControlStateHighlighted)];
    [_photoBtn setTitleColor:buttonTitleSelectedColor forState:(UIControlStateSelected | UIControlStateHighlighted)];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    if ([keyPath isEqualToString:@"selected"] && object == _photoBtn) {
        _photoBtn.layer.borderColor = _photoBtn.selected ? SSJ_BUTTON_SELECTED_BORDER_COLOR : SSJ_BUTTON_NORMAL_BORDER_COLOR;
    }
}

#pragma mark - Getter
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 50)];
        _topView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
        
        UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        img.left = 10;
        img.centerY = _topView.height * 0.5;
        [_topView addSubview:img];
        [_topView ssj_setBorderWidth:1];
        [_topView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        [_topView ssj_setBorderStyle:(SSJBorderStyleTop | SSJBorderStyleBottom)];
    }
    return _topView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _topView.bottom, self.width, 37)];
        _bottomView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainFillColor];
        [_bottomView ssj_setBorderWidth:1];
        [_bottomView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
        [_bottomView ssj_setBorderStyle:SSJBorderStyleBottom];
    }
    return _bottomView;
}

- (UIImageView *)memoIcon {
    if (!_memoIcon) {
        _memoIcon = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"record_making_memo"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _memoIcon.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _memoIcon.left = 12;
        _memoIcon.centerY = self.topView.height * 0.5;
    }
    return _memoIcon;
}

- (UITextField *)memoView {
    if (!_memoView) {
        _memoView = [[UITextField alloc] initWithFrame:CGRectMake(40, 0, self.topView.width - 40, self.topView.height)];
        _memoView.font = [UIFont systemFontOfSize:13];
        _memoView.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _memoView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"写点啥备注下" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        _memoView.returnKeyType = UIReturnKeyDone;
    }
    return _memoView;
}

- (UIButton *)accountBtn {
    if (!_accountBtn) {
        _accountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _accountBtn.frame = CGRectMake(0, 0, 70, 24);
        _accountBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _accountBtn.layer.borderWidth = 1;
        _accountBtn.layer.borderColor = SSJ_BUTTON_SELECTED_BORDER_COLOR;
        _accountBtn.layer.cornerRadius = _accountBtn.height * 0.5;
    }
    return _accountBtn;
}

- (UIButton *)dateBtn {
    if (!_dateBtn) {
        _dateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _dateBtn.frame = CGRectMake(0, 0, 70, 24);
        _dateBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _dateBtn.layer.borderWidth = 1;
        _dateBtn.layer.borderColor = SSJ_BUTTON_SELECTED_BORDER_COLOR;
        _dateBtn.layer.cornerRadius = _dateBtn.height * 0.5;
    }
    return _dateBtn;
}

- (UIButton *)memberBtn {
    if (!_memberBtn) {
        _memberBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _memberBtn.frame = CGRectMake(0, 0, 70, 24);
        _memberBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _memberBtn.layer.borderWidth = 1;
        [_memberBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];
        _memberBtn.layer.borderColor = SSJ_BUTTON_SELECTED_BORDER_COLOR;
        _memberBtn.layer.cornerRadius = _memberBtn.height * 0.5;
    }
    return _memberBtn;
}

- (UIButton *)photoBtn {
    if (!_photoBtn) {
        _photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoBtn.frame = CGRectMake(0, 0, 70, 24);
        _photoBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _photoBtn.layer.borderWidth = 1;
        _photoBtn.layer.borderColor = SSJ_BUTTON_SELECTED_BORDER_COLOR;
        _photoBtn.layer.cornerRadius = _photoBtn.height * 0.5;
    }
    return _photoBtn;
}

@end
