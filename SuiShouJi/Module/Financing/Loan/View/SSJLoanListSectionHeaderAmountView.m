//
//  SSJLoanListSectionHeaderAmountView.m
//  SuiShouJi
//
//  Created by old lang on 16/8/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanListSectionHeaderAmountView.h"

@interface SSJLoanListSectionHeaderAmountView ()

@property (nonatomic, strong) UILabel *amountTitleLab;

@property (nonatomic, strong) UILabel *amountValueLab;

@end

@implementation SSJLoanListSectionHeaderAmountView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.amountTitleLab];
        [self addSubview:self.amountValueLab];
    }
    return self;
}

- (void)layoutSubviews {
    [_amountTitleLab sizeToFit];
    [_amountValueLab sizeToFit];
    
    self.amountTitleLab.left = 19;
    self.amountValueLab.right = self.width - 19;
    self.amountTitleLab.centerY = self.amountValueLab.centerY = self.height * 0.5;
}

- (void)setTitle:(NSString *)title {
    if ([_title isEqualToString:title]) {
        _title = title;
        _amountTitleLab.text = _title;
        [self setNeedsLayout];
    }
}

- (void)setAmount:(NSString *)amount {
    if ([_amount isEqualToString:amount]) {
        _amount = amount;
        _amountValueLab.text = _amount;
        [self setNeedsLayout];
    }
}

- (void)updateAppearance {
    CGFloat alpha = [SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID] ? 0 : 0.1;
    self.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:alpha];
    _amountTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _amountValueLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
}

- (UILabel *)amountTitleLab {
    if (!_amountTitleLab) {
        _amountTitleLab = [[UILabel alloc] init];
        _amountTitleLab.font = [UIFont systemFontOfSize:14];
    }
    return _amountTitleLab;
}

- (UILabel *)amountValueLab {
    if (!_amountValueLab) {
        _amountValueLab = [[UILabel alloc] init];
        _amountValueLab.font = [UIFont systemFontOfSize:14];
    }
    return _amountValueLab;
}

@end
