//
//  SSJMagicExportSelectDateView.m
//  SuiShouJi
//
//  Created by old lang on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportSelectDateView.h"

@interface SSJMagicExportSelectDateView ()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UILabel *beginDateTitleLab;

@property (nonatomic, strong) UILabel *endDateTitleLab;

@property (nonatomic, strong) UILabel *beginDateLab;

@property (nonatomic, strong) UILabel *endDateLab;

@property (nonatomic, strong) UIView *beginDateBaseLineView;

@property (nonatomic, strong) UIView *endDateBaseLineView;

@property (nonatomic, strong) UIImageView *arrowView;

@end

@implementation SSJMagicExportSelectDateView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        
        [self addSubview:self.titleLab];
        [self addSubview:self.beginDateBaseLineView];
        [self addSubview:self.endDateBaseLineView];
        [self addSubview:self.beginDateTitleLab];
        [self addSubview:self.beginDateLab];
        [self addSubview:self.endDateTitleLab];
        [self addSubview:self.endDateLab];
        [self addSubview:self.arrowView];
    }
    return self;
}

- (void)layoutSubviews {
    self.titleLab.width = 164;
    [self.titleLab sizeToFit];
    self.titleLab.top = 14;
    self.titleLab.centerX = self.width * 0.5;
    
    self.beginDateTitleLab.leftTop = CGPointMake(10, 84);
    [self.beginDateLab sizeToFit];
    self.beginDateLab.leftTop = CGPointMake(10, 116);
    
    self.endDateTitleLab.rightTop = CGPointMake(self.width - 10, 84);
    [self.endDateLab sizeToFit];
    self.endDateLab.rightTop = CGPointMake(self.width - 10, 116);
    
    self.arrowView.center = CGPointMake(self.width * 0.5, self.endDateLab.height * 0.5 + self.endDateLab.top);
    
    CGFloat baseLineViewWidth = (self.width - self.arrowView.width - 40) * 0.5;
    self.beginDateBaseLineView.frame = CGRectMake(10, 108, baseLineViewWidth, 45);
    
    self.endDateBaseLineView.frame = CGRectMake(self.arrowView.right + 10, 108, baseLineViewWidth, 45);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.width, 176);
}

- (void)setBeginDate:(NSDate *)beginDate {
    [self setNeedsLayout];
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"亲爱的用户，您在"];
    [title appendAttributedString:[[NSAttributedString alloc] initWithString:[beginDate formattedDateWithFormat:@"yyyy年M月d日"] attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor]}]];
    [title appendAttributedString:[[NSAttributedString alloc] initWithString:@"开启了记账之旅"]];
    self.titleLab.attributedText = title;
    
    self.beginDateLab.text = [beginDate formattedDateWithFormat:@"yyyy年M月d日"];
}

- (void)setEndDate:(NSDate *)endDate {
    [self setNeedsLayout];
    self.endDateLab.text = [endDate formattedDateWithFormat:@"yyyy年M月d日"];
}

- (void)clickBeginDateAction {
    if (_beginDateAction) {
        _beginDateAction();
    }
}

- (void)clickEndDateAction {
    if (_endDateAction) {
        _endDateAction();
    }
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 164, 0)];
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _titleLab.numberOfLines = 0;
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
    }
    return _titleLab;
}

- (UILabel *)beginDateTitleLab {
    if (!_beginDateTitleLab) {
        _beginDateTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 164, 0)];
        _beginDateTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        _beginDateTitleLab.text = @"起始";
        _beginDateTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        [_beginDateTitleLab sizeToFit];
    }
    return _beginDateTitleLab;
}

- (UILabel *)endDateTitleLab {
    if (!_endDateTitleLab) {
        _endDateTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 164, 0)];
        _endDateTitleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        _endDateTitleLab.text = @"结束";
        _endDateTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        [_endDateTitleLab sizeToFit];
    }
    return _endDateTitleLab;
}

- (UILabel *)beginDateLab {
    if (!_beginDateLab) {
        _beginDateLab = [[UILabel alloc] init];
        _beginDateLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _beginDateLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _beginDateLab.text = @"--年--月--日";
    }
    return _beginDateLab;
}

- (UILabel *)endDateLab {
    if (!_endDateLab) {
        _endDateLab = [[UILabel alloc] init];
        _endDateLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _endDateLab.text = @"--年--月--日";
        _endDateLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _endDateLab;
}

- (UIView *)beginDateBaseLineView {
    if (!_beginDateBaseLineView) {
        _beginDateBaseLineView = [[UIView alloc] init];
        _beginDateBaseLineView.backgroundColor = [UIColor clearColor];
        [_beginDateBaseLineView ssj_setBorderWidth:1];
        [_beginDateBaseLineView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_beginDateBaseLineView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBeginDateAction)];
        [_beginDateBaseLineView addGestureRecognizer:tap];
    }
    return _beginDateBaseLineView;
}

- (UIView *)endDateBaseLineView {
    if (!_endDateBaseLineView) {
        _endDateBaseLineView = [[UIView alloc] init];
        _endDateBaseLineView.backgroundColor = [UIColor clearColor];
        [_endDateBaseLineView ssj_setBorderWidth:1];
        [_endDateBaseLineView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_endDateBaseLineView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickEndDateAction)];
        [_endDateBaseLineView addGestureRecognizer:tap];
    }
    return _endDateBaseLineView;
}

- (UIImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _arrowView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor];
    }
    return _arrowView;
}

@end
