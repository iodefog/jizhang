
//
//  SSJFundingParentSelectHeader.m
//  SuiShouJi
//
//  Created by ricky on 2017/8/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFundingParentSelectHeader.h"

@interface SSJFundingParentSelectHeader()

@property (nonatomic, strong) UIImageView *fundIconImage;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UILabel *memoLab;

@property (nonatomic, strong) UIImageView *arrowImage;

@end

@implementation SSJFundingParentSelectHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.fundIconImage];
        [self.contentView addSubview:self.titleLab];
        [self.contentView addSubview:self.memoLab];
        [self.contentView addSubview:self.arrowImage];
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateConstraints {
    [self.fundIconImage mas_updateConstraints:^(MASConstraintMaker *make) {
        if (!self.model.memo.length) {
            make.centerY.mas_equalTo(self);
        } else {
            make.top.mas_equalTo(self).offset(18);
        }
        make.left.mas_equalTo(15);
    }];
    
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.fundIconImage);
        make.left.mas_equalTo(self).offset(45);
    }];
    
    [self.memoLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLab.mas_bottom).offset(10);
        make.left.mas_equalTo(self.titleLab);
    }];
    
    [self.arrowImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLab);
        make.right.mas_equalTo(15);
    }];
    
    [super updateConstraints];
}

- (UIImageView *)fundIconImage {
    if (!_fundIconImage) {
        _fundIconImage = [[UIImageView alloc] init];
    }
    return _fundIconImage;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _titleLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _titleLab;
}

- (UILabel *)memoLab {
    if (!_memoLab) {
        _memoLab = [[UILabel alloc] init];
        _memoLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _memoLab.font = [UIFont systemFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _memoLab;
}

- (UIImageView *)arrowImage {
    if (!_arrowImage) {
        _arrowImage = [[UIImageView alloc] init];
        _arrowImage.image = [[UIImage imageNamed:@"ft_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _arrowImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _arrowImage;
}

- (void)setModel:(SSJFundingParentmodel *)model {
    _model = model;
    self.titleLab.text = _model.name;
    self.memoLab.text = _model.memo;
    self.fundIconImage.image = [UIImage imageNamed:_model.icon];
    self.arrowImage.hidden = _model.subFunds.count;
}

- (void)updateCellAppearanceAfterThemeChanged {
    _arrowImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _memoLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.model.subFunds.count) {
        self.model.expended = !self.model.expended;
        if (self.model.expended) {
            self.arrowImage.layer.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        } else {
            self.arrowImage.layer.transform = CATransform3DIdentity;
        }
        if (self.didSelectFundParentHeader) {
            self.didSelectFundParentHeader(self.model);
        }
    }
}

@end
