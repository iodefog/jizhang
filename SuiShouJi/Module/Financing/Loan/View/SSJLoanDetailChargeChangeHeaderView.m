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
        _titleLab.font = [UIFont systemFontOfSize:14];
        [self addSubview:_titleLab];
        
        _arrow = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"loan_arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _arrow.transform = CGAffineTransformMakeRotation(_expanded ? 0 : M_PI);
        [self addSubview:_arrow];
        
        [self updateAppearance];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
        
        self.backgroundColor = [UIColor whiteColor];
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

- (void)updateAppearance {
    _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _arrow.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

- (void)tapAction {
    self.expanded = !self.expanded;
    if (_tapHandle) {
        _tapHandle(self);
    }
}

@end
