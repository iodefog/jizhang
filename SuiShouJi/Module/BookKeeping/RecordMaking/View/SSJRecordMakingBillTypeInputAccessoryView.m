//
//  SSJRecordMakingBillTypeInputAccessoryView.m
//  SuiShouJi
//
//  Created by old lang on 16/5/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingBillTypeInputAccessoryView.h"

static const CGFloat kButtonWidth = 80.0;
static const UIEdgeInsets kButtonInset = {7, 5, 7, 5};
//static const UIEdgeInsets kButtonInset = {0, 0, 0, 0};

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
        
        [self updateAppearance];
        [self setNeedsUpdateConstraints];

        @weakify(self);
        [RACObserve(self.memberBtn, hidden) subscribeNext:^(id x) {
            @strongify(self);
            [self setNeedsUpdateConstraints];
            [self setNeedsLayout];
        }];
    }
    return self;
}

- (void)updateConstraints {
    [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(50);
        make.left.and.top.mas_equalTo(0);
    }];
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(37);
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.left.mas_equalTo(0);
    }];
    [self.memoView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(40);
        make.width.mas_equalTo(self.topView.mas_width).offset(-40);
        make.height.mas_equalTo(self.topView.mas_height);
    }];
    
    NSMutableArray *tmpBtns = [NSMutableArray array];
    [tmpBtns addObject:self.accountBtn];
    [tmpBtns addObject:self.dateBtn];
    if (!self.memberBtn.hidden) {
        [tmpBtns addObject:self.memberBtn];
    }
    [tmpBtns addObject:self.photoBtn];
    [tmpBtns ssj_distributeViewsAlongAxis:SSJAxisTypeHorizontal withFixedItemLength:kButtonWidth];
    [tmpBtns mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.height.mas_equalTo(self.bottomView);
    }];
    
    [super updateConstraints];
}

- (void)updateAppearance {
    [self setButtonTitleColor:SSJ_SECONDARY_COLOR forState:SSJButtonStateNormal];
    [self setButtonTitleColor:SSJ_MAIN_COLOR forState:SSJButtonStateSelected];
    
    self.topView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainFillColor];
    [self.topView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    self.memoIcon.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    
    self.bottomView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainFillColor];
    [self.bottomView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    self.memoView.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.memoView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"写点啥备注下" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    
    [self.accountBtn setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor] forState:SSJButtonStateNormal];
    [self.accountBtn setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha] forState:SSJButtonStateNormal];
    
    [self.dateBtn setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor] forState:SSJButtonStateNormal];
    [self.dateBtn setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha] forState:SSJButtonStateNormal];
    
    [self.memberBtn setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor] forState:SSJButtonStateNormal];
    [self.memberBtn setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha] forState:SSJButtonStateNormal];
    
    [self.photoBtn setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor] forState:SSJButtonStateNormal];
    [self.photoBtn setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha] forState:SSJButtonStateNormal];
}

#pragma mark - Getter
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 50)];
        
        UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        img.left = 10;
        img.centerY = _topView.height * 0.5;
        [_topView addSubview:img];
        [_topView ssj_setBorderWidth:1];
        [_topView ssj_setBorderStyle:(SSJBorderStyleTop | SSJBorderStyleBottom)];
    }
    return _topView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _topView.bottom, self.width, 37)];
        [_bottomView ssj_setBorderWidth:1];
        [_bottomView ssj_setBorderStyle:SSJBorderStyleBottom];
    }
    return _bottomView;
}

- (UIImageView *)memoIcon {
    if (!_memoIcon) {
        _memoIcon = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"record_making_memo"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _memoIcon.left = 12;
        _memoIcon.centerY = self.topView.height * 0.5;
    }
    return _memoIcon;
}

- (UITextField *)memoView {
    if (!_memoView) {
        _memoView = [[UITextField alloc] initWithFrame:CGRectMake(40, 0, self.topView.width - 40, self.topView.height)];
        _memoView.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _memoView.returnKeyType = UIReturnKeyDone;
        _memoView.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _memoView;
}

- (SSJButton *)accountBtn {
    if (!_accountBtn) {
        _accountBtn = [[SSJButton alloc] init];
        _accountBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _accountBtn.borderWidth = 1 / [UIScreen mainScreen].scale;
        _accountBtn.cornerRadius = 12;
        _accountBtn.contentInset = kButtonInset;
    }
    return _accountBtn;
}

- (SSJButton *)dateBtn {
    if (!_dateBtn) {
        _dateBtn = [[SSJButton alloc] init];
        _dateBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _dateBtn.borderWidth = 1 / [UIScreen mainScreen].scale;
        _dateBtn.cornerRadius = 12;
        _dateBtn.contentInset = kButtonInset;
    }
    return _dateBtn;
}

- (SSJButton *)memberBtn {
    if (!_memberBtn) {
        _memberBtn = [[SSJButton alloc] init];
        _memberBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _memberBtn.borderWidth = 1 / [UIScreen mainScreen].scale;
        _memberBtn.cornerRadius = 12;
        _memberBtn.contentInset = kButtonInset;
    }
    return _memberBtn;
}

- (SSJButton *)photoBtn {
    if (!_photoBtn) {
        _photoBtn = [[SSJButton alloc] init];
        _photoBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _photoBtn.borderWidth = 1 / [UIScreen mainScreen].scale;
        _photoBtn.cornerRadius = 12;
        _photoBtn.contentInset = kButtonInset;
    }
    return _photoBtn;
}

- (void)setButtonTitleColor:(UIColor *)color forState:(SSJButtonState)state {
    [self.accountBtn setTitleColor:color forState:state];
    [self.dateBtn setTitleColor:color forState:state];
    [self.memberBtn setTitleColor:color forState:state];
    [self.photoBtn setTitleColor:color forState:state];
}

@end
