//
//  SSJRecordMakingBillTypeInputAccessoryView.m
//  SuiShouJi
//
//  Created by old lang on 16/5/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingBillTypeInputAccessoryView.h"

#define SSJ_BUTTON_NORMAL_BORDER_COLOR [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor]
#define SSJ_BUTTON_SELECTED_BORDER_COLOR [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor]

@interface SSJRecordMakingBillTypeInputAccessoryView ()

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIImageView *memoIcon;

@property (nonatomic, strong) UITextField *memoView;

@property (nonatomic, strong) SSJButton *accountBtn;

@property (nonatomic, strong) SSJButton *dateBtn;

@property (nonatomic, strong) SSJButton *photoBtn;

@property (nonatomic, strong) SSJButton *memberBtn;

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
    
    CGFloat buttonWidth = _bottomView.width / 4;
    
    _accountBtn.size = _dateBtn.size = _photoBtn.size =_memberBtn.size = CGSizeMake(buttonWidth, _bottomView.height);
    
    _accountBtn.leftTop = CGPointMake(0, 0);
    
    _dateBtn.leftTop = CGPointMake(buttonWidth, 0);

    _memberBtn.leftTop = CGPointMake(buttonWidth * 2, 0);
    
    _photoBtn.leftTop = CGPointMake(buttonWidth * 3, 0);

    CGFloat horizontalGap = (_bottomView.width - 280) * 0.2;
    CGFloat verizonGap = (_bottomView.height - 20) * 0.5;
//    _accountBtn.left = horizontalGap;
//    _dateBtn.left = _accountBtn.right + horizontalGap;
//    _memberBtn.left = _dateBtn.right + horizontalGap;
//    _photoBtn.left = _memberBtn.right + horizontalGap;
    _accountBtn.contentInset = _dateBtn.contentInset = _photoBtn.contentInset = _memberBtn.contentInset = UIEdgeInsetsMake(verizonGap / 2, horizontalGap, verizonGap, horizontalGap / 2);
}

- (void)setButtonTitleNormalColor:(UIColor *)buttonTitleNormalColor {
    [_accountBtn setTitleColor:buttonTitleNormalColor forState:SSJButtonStateNormal];
    [_dateBtn setTitleColor:buttonTitleNormalColor forState:SSJButtonStateNormal];
    [_photoBtn setTitleColor:buttonTitleNormalColor forState:SSJButtonStateNormal];
    
    [_accountBtn setTitleColor:buttonTitleNormalColor forState:(SSJButtonStateNormal | SSJButtonStateHighlighted)];
    [_dateBtn setTitleColor:buttonTitleNormalColor forState:(SSJButtonStateNormal | SSJButtonStateHighlighted)];
    [_memberBtn setTitleColor:buttonTitleNormalColor forState:(SSJButtonStateNormal | SSJButtonStateHighlighted)];
    [_photoBtn setTitleColor:buttonTitleNormalColor forState:(SSJButtonStateNormal | SSJButtonStateHighlighted)];
}

- (void)setButtonTitleSelectedColor:(UIColor *)buttonTitleSelectedColor {
    [_accountBtn setTitleColor:buttonTitleSelectedColor forState:SSJButtonStateSelected];
    [_dateBtn setTitleColor:buttonTitleSelectedColor forState:SSJButtonStateSelected];
    [_photoBtn setTitleColor:buttonTitleSelectedColor forState:SSJButtonStateSelected];
    
    [_accountBtn setTitleColor:buttonTitleSelectedColor forState:(SSJButtonStateSelected | SSJButtonStateHighlighted)];
    [_dateBtn setTitleColor:buttonTitleSelectedColor forState:(SSJButtonStateSelected | SSJButtonStateHighlighted)];
    [_memberBtn setTitleColor:buttonTitleSelectedColor forState:(SSJButtonStateSelected | SSJButtonStateHighlighted)];
    [_photoBtn setTitleColor:buttonTitleSelectedColor forState:(SSJButtonStateSelected | SSJButtonStateHighlighted)];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    if ([keyPath isEqualToString:@"selected"] && object == _photoBtn) {
        [_photoBtn setBackgroundColor:_photoBtn.selected ? SSJ_BUTTON_SELECTED_BORDER_COLOR : SSJ_BUTTON_NORMAL_BORDER_COLOR forState:SSJButtonStateNormal];
    }
}

#pragma mark - Getter
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 50)];
        _topView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainFillColor];
        
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
        _memoView.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_4);
        _memoView.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _memoView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"写点啥备注下" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        _memoView.returnKeyType = UIReturnKeyDone;
        _memoView.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _memoView;
}

- (SSJButton *)accountBtn {
    if (!_accountBtn) {
        _accountBtn = [[SSJButton alloc] init];
        _accountBtn.frame = CGRectMake(0, 0, 70, 24);
        _accountBtn.titleLabel.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_4);
        _accountBtn.borderWidth = 1 / [UIScreen mainScreen].scale;
        [_accountBtn setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor] forState:SSJButtonStateNormal];
        [_accountBtn setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha] forState:SSJButtonStateNormal];
        _accountBtn.cornerRadius = 12;
    }
    return _accountBtn;
}

- (SSJButton *)dateBtn {
    if (!_dateBtn) {
        _dateBtn = [[SSJButton alloc] init];
        _dateBtn.frame = CGRectMake(0, 0, 70, 24);
        _dateBtn.titleLabel.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_4);
        _dateBtn.borderWidth = 1 / [UIScreen mainScreen].scale;
        [_dateBtn setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor] forState:SSJButtonStateNormal];
        [_dateBtn setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha] forState:SSJButtonStateNormal];
        _dateBtn.cornerRadius = 12;
    }
    return _dateBtn;
}

- (SSJButton *)memberBtn {
    if (!_memberBtn) {
        _memberBtn = [[SSJButton alloc] init];
        _memberBtn.frame = CGRectMake(0, 0, 70, 24);
        _memberBtn.titleLabel.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_4);
        _memberBtn.borderWidth = 1 / [UIScreen mainScreen].scale;
        [_memberBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:SSJButtonStateNormal];
        [_memberBtn setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor] forState:SSJButtonStateNormal];
        [_memberBtn setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha] forState:SSJButtonStateNormal];
        _memberBtn.cornerRadius = 12;
    }
    return _memberBtn;
}

- (SSJButton *)photoBtn {
    if (!_photoBtn) {
        _photoBtn = [[SSJButton alloc] init];
        _photoBtn.frame = CGRectMake(0, 0, 70, 24);
        _photoBtn.titleLabel.font = SSJ_PingFang_REGULAR_FONT_SIZE(SSJ_FONT_SIZE_4);
        _photoBtn.borderWidth = 1 / [UIScreen mainScreen].scale;
        [_photoBtn setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor] forState:SSJButtonStateNormal];
        [_photoBtn setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha] forState:SSJButtonStateNormal];
        _photoBtn.cornerRadius = 12;
    }
    return _photoBtn;
}

@end
