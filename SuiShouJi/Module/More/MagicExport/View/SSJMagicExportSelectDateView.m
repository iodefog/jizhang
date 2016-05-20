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

@end

@implementation SSJMagicExportSelectDateView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.titleLab];
        [self addSubview:self.beginDateBaseLineView];
        [self addSubview:self.beginDateTitleLab];
        [self addSubview:self.beginDateLab];
        [self addSubview:self.endDateTitleLab];
        [self addSubview:self.endDateLab];
    }
    return self;
}

- (void)layoutSubviews {
    self.titleLab.width = 164;
    [self.titleLab sizeToFit];
    self.titleLab.top = 14;
    self.titleLab.centerX = self.width * 0.5;
    
    self.beginDateBaseLineView.frame = CGRectMake(10, 108, self.width - 20, 45);
    [self.beginDateBaseLineView ssj_relayoutBorder];
    
    self.beginDateTitleLab.leftTop = CGPointMake(10, 84);
    [self.beginDateLab sizeToFit];
    self.beginDateLab.leftTop = CGPointMake(10, 116);
    
    self.endDateTitleLab.rightTop = CGPointMake(self.width - 10, 84);
    [self.endDateLab sizeToFit];
    self.endDateLab.rightTop = CGPointMake(self.width - 10, 116);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.width, 176);
}

- (void)setBeginDate:(NSDate *)beginDate {
    [self setNeedsLayout];
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"亲爱的用户，您在"];
    [title appendAttributedString:[[NSAttributedString alloc] initWithString:[beginDate formattedDateWithFormat:@"yyyy年M月d日"] attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"eb4a64"]}]];
    [title appendAttributedString:[[NSAttributedString alloc] initWithString:@"开启了记账之旅"]];
    self.titleLab.attributedText = title;
    
    self.beginDateLab.text = [beginDate formattedDateWithFormat:@"yyyy年M月d日"];
}

- (void)setEndDate:(NSDate *)endDate {
    [self setNeedsLayout];
    self.endDateLab.text = [endDate formattedDateWithFormat:@"yyyy年M月d日"];
}

- (void)selectDateAction {
    if (_selectDateBlock) {
        _selectDateBlock();
    }
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 164, 0)];
        _titleLab.numberOfLines = 0;
        _titleLab.font = [UIFont systemFontOfSize:14];
    }
    return _titleLab;
}

- (UILabel *)beginDateTitleLab {
    if (!_beginDateTitleLab) {
        _beginDateTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 164, 0)];
        _beginDateTitleLab.font = [UIFont systemFontOfSize:12];
        _beginDateTitleLab.text = @"起始";
        _beginDateTitleLab.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        [_beginDateTitleLab sizeToFit];
    }
    return _beginDateTitleLab;
}

- (UILabel *)endDateTitleLab {
    if (!_endDateTitleLab) {
        _endDateTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 164, 0)];
        _endDateTitleLab.font = [UIFont systemFontOfSize:12];
        _endDateTitleLab.text = @"结束";
        _endDateTitleLab.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        [_endDateTitleLab sizeToFit];
    }
    return _endDateTitleLab;
}

- (UILabel *)beginDateLab {
    if (!_beginDateLab) {
        _beginDateLab = [[UILabel alloc] init];
        _beginDateLab.font = [UIFont systemFontOfSize:18];
        _beginDateLab.textColor = [UIColor blackColor];
        _beginDateLab.text = @"--年--月--日";
    }
    return _beginDateLab;
}

- (UILabel *)endDateLab {
    if (!_endDateLab) {
        _endDateLab = [[UILabel alloc] init];
        _endDateLab.font = [UIFont systemFontOfSize:18];
        _endDateLab.text = @"--年--月--日";
        _endDateLab.textColor = [UIColor blackColor];
    }
    return _endDateLab;
}

- (UIView *)beginDateBaseLineView {
    if (!_beginDateBaseLineView) {
        _beginDateBaseLineView = [[UIView alloc] init];
        _beginDateBaseLineView.backgroundColor = [UIColor whiteColor];
        [_beginDateBaseLineView ssj_setBorderWidth:1];
        [_beginDateBaseLineView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_beginDateBaseLineView ssj_setBorderColor:[UIColor ssj_colorWithHex:@"00c6ad"]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectDateAction)];
        [_beginDateBaseLineView addGestureRecognizer:tap];
    }
    return _beginDateBaseLineView;
}

- (UIView *)endDateBaseLineView {
    if (!_endDateBaseLineView) {
        _endDateBaseLineView = [[UIView alloc] init];
        _endDateBaseLineView.backgroundColor = [UIColor whiteColor];
        [_endDateBaseLineView ssj_setBorderWidth:1];
        [_beginDateBaseLineView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_beginDateBaseLineView ssj_setBorderColor:[UIColor ssj_colorWithHex:@"00c6ad"]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectDateAction)];
        [_beginDateBaseLineView addGestureRecognizer:tap];
    }
    return _beginDateBaseLineView;
}

@end
