//
//  SSJLoanDetailChargeChangeHeaderView.m
//  SuiShouJi
//
//  Created by old lang on 16/11/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanDetailChargeChangeHeaderView.h"

@interface SSJLoanDetailChargeChangeHeaderView ()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIImageView *arrow;

@end

@implementation SSJLoanDetailChargeChangeHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
        [self addSubview:_titleLab];
        
        _arrow = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"loan_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _arrow.transform = CGAffineTransformMakeRotation(_expanded ? 0 : M_PI);
        [self addSubview:_arrow];
        
        [self ssj_setBorderWidth:1];
        [self ssj_setBorderStyle:(SSJBorderStyleTop | SSJBorderStyleBottom)];
        
        [self updateAppearance];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)layoutSubviews {
    [_titleLab sizeToFit];
    _titleLab.left = 15;
    _titleLab.centerY = self.height * 0.5;
    
    _arrow.right = self.width - 20;
    _arrow.centerY = self.height * 0.5;
}

- (void)setExpanded:(BOOL)expanded {
    if (_expanded != expanded) {
        _expanded = expanded;
        _arrow.transform = CGAffineTransformMakeRotation(_expanded ? 0 : M_PI);
    }
}

- (void)setTitle:(NSString *)title {
    if (![_title isEqualToString:title]) {
        _title = title;
        _titleLab.text = title;
        [self setNeedsLayout];
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    if (![_titleFont isEqual:titleFont]) {
        _titleFont = titleFont;
        _titleLab.font = titleFont;
    }
}

- (void)updateAppearance {
    _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _arrow.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    [self ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
        self.backgroundColor = [UIColor whiteColor];
    } else {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
}

- (void)tapAction {
    self.expanded = !self.expanded;
    if (_tapHandle) {
        _tapHandle(self);
    }
}

@end
