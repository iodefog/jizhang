
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
        
    }
    return self;
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
        _arrowImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _arrowImage;
}

- (void)setModel:(SSJFundingParentmodel *)model {
    _model = model;
    self.titleLab.text = _model.name;
    self.memoLab.text = _model.memo;
    self.fundIconImage.image = [UIImage imageNamed:_model.icon];
}

@end
