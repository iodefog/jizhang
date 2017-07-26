//
//  SSJBooksTypeEditAlertView.m
//  SuiShouJi
//
//  Created by old lang on 17/4/26.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBooksTypeEditAlertView.h"

static const NSTimeInterval kAnimationDuration = 0.25;

static const CGSize kButtonSize = {200, 40};

@interface SSJBooksTypeEditAlertView ()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIButton *editBtn;

@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) UIButton *transferBtn;

@property (nonatomic, strong) UIButton *cancelBtn;

@end

@implementation SSJBooksTypeEditAlertView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        [self sizeToFit];
        [self addSubview:self.titleLab];
        [self addSubview:self.editBtn];
        [self addSubview:self.deleteBtn];
        [self addSubview:self.cancelBtn];
        [self addSubview:self.transferBtn];
        [self updateAppearance];
        [self setNeedsUpdateConstraints];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAppearance) name:SSJThemeDidChangeNotification object:nil];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(280, 290);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.editBtn ssj_layoutContent];
    [self.deleteBtn ssj_layoutContent];
    [self.transferBtn ssj_layoutContent];
}

- (void)updateConstraints {
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(24);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(16);
    }];
    [self.editBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLab.mas_bottom).offset(25);
        make.centerX.mas_equalTo(self);
        make.size.mas_equalTo(kButtonSize);
    }];
    [self.transferBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.editBtn.mas_bottom).offset(15);
        make.centerX.mas_equalTo(self);
        make.size.mas_equalTo(kButtonSize);
    }];
    [self.deleteBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.transferBtn.mas_bottom).offset(15);
        make.centerX.mas_equalTo(self);
        make.size.mas_equalTo(kButtonSize);
    }];
    [self.cancelBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.deleteBtn.mas_bottom).offset(10);
        make.bottom.centerX.width.mas_equalTo(self);
    }];
    [super updateConstraints];
}

- (void)showWithBookCategory:(SSJBooksCategory)category {
    if (category == SSJBooksCategoryPublic) {
        [self.deleteBtn setTitle:@"退出账本" forState:UIControlStateNormal];
    } else if (category == SSJBooksCategoryPersional) {
        [self.deleteBtn setTitle:@"删除账本" forState:UIControlStateNormal];
    }
    self.alpha = 0;
    self.center = CGPointMake(SSJ_KEYWINDOW.width * 0.5, SSJ_KEYWINDOW.height * 0.5);
    [SSJ_KEYWINDOW ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.3 target:self touchAction:@selector(dismiss) animation:^{
        self.alpha = 1;
    } timeInterval:kAnimationDuration fininshed:NULL];
}

- (void)dismiss {
    [SSJ_KEYWINDOW ssj_hideBackViewForView:self animation:^{
        self.alpha = 0;
    } timeInterval:kAnimationDuration fininshed:NULL];
}

- (void)updateAppearance {
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
    self.titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    
    self.editBtn.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha].CGColor;
    self.editBtn.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    [self.editBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
    
    self.transferBtn.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha].CGColor;
    self.transferBtn.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    [self.transferBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];
    
    self.deleteBtn.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha].CGColor;
    self.deleteBtn.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    [self.deleteBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];

    
    [self.cancelBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _titleLab.text = @"请选择";
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

- (UIButton *)editBtn {
    if (!_editBtn) {
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editBtn.layer.borderWidth = 1;
        _editBtn.layer.cornerRadius = kButtonSize.height * 0.5;
        _editBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _editBtn.spaceBetweenImageAndTitle = 10;
        [_editBtn setTitle:@"编辑账本" forState:UIControlStateNormal];
        [_editBtn setImage:[[UIImage imageNamed:@"books_edite"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        @weakify(self);
        [[_editBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self dismiss];
            if (self.editHandler) {
                self.editHandler();
            }
        }];
    }
    return _editBtn;
}

- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.layer.borderWidth = 1;
        _deleteBtn.layer.cornerRadius = kButtonSize.height * 0.5;
        _deleteBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _deleteBtn.spaceBetweenImageAndTitle = 10;
        [_deleteBtn setTitle:@"删除账本" forState:UIControlStateNormal];
        [_deleteBtn setImage:[[UIImage imageNamed:@"books_delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        @weakify(self);
        [[_deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self dismiss];
            if (self.deleteHandler) {
                self.deleteHandler();
            }
        }];
    }
    return _deleteBtn;
}

- (UIButton *)transferBtn {
    if (!_transferBtn) {
        _transferBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _transferBtn.layer.borderWidth = 1;
        _transferBtn.layer.cornerRadius = kButtonSize.height * 0.5;
        _transferBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _transferBtn.spaceBetweenImageAndTitle = 10;
        [_transferBtn setTitle:@"迁移账本" forState:UIControlStateNormal];
        [_transferBtn setImage:[[UIImage imageNamed:@"books_transfer"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        @weakify(self);
        [[_transferBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self dismiss];
            if (self.transferHandler) {
                self.transferHandler();
            }
        }];
    }
    return _transferBtn;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        @weakify(self);
        [[_cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self dismiss];
        }];
    }
    return _cancelBtn;
}

@end
