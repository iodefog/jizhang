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

@property (nonatomic, strong) UILabel *beginDateLab;

@property (nonatomic, strong) UILabel *endDateLab;

@property (nonatomic, strong) UIButton *beginDateBtn;

@property (nonatomic, strong) UIButton *endDateBtn;

@property (nonatomic, strong) UIImageView *arrowView;

@end

@implementation SSJMagicExportSelectDateView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.titleLab];
        [self addSubview:self.beginDateLab];
        [self addSubview:self.beginDateBtn];
        [self addSubview:self.endDateLab];
        [self addSubview:self.endDateBtn];
        [self addSubview:self.arrowView];
    }
    return self;
}

- (void)layoutSubviews {
    [self.beginDateBtn ssj_relayoutBorder];
    [self.endDateBtn ssj_relayoutBorder];
    
    self.titleLab.top = 14;
    self.titleLab.centerX = self.width * 0.5;
    
//    [self.beginDateLab sizeToFit];
//    [self.beginDateLab ssj_relayoutBorder];
    
    self.arrowView.center = CGPointMake(self.width * 0.5, self.beginDateBtn.centerY);
    
    CGFloat beginLeft = (self.width - self.arrowView.left - self.beginDateBtn.width) * 0.5;
    self.beginDateLab.leftTop = CGPointMake(beginLeft, 94);
    self.beginDateBtn.leftTop = CGPointMake(beginLeft, 116);
    
    CGFloat endLeft = (self.width - self.arrowView.right - self.endDateBtn.width) * 0.5 + self.arrowView.right;
    self.endDateLab.leftTop = CGPointMake(endLeft, 94);
    self.endDateBtn.leftTop = CGPointMake(endLeft, 116);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.width, 176);
}

- (void)setBeginDate:(NSDate *)beginDate {
    [self setNeedsLayout];
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"亲爱的用户，您在"];
    [title appendAttributedString:[[NSAttributedString alloc] initWithString:[beginDate formattedDateWithFormat:@"yyyy年M月d日"] attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"47cfbe"]}]];
    [title appendAttributedString:[[NSAttributedString alloc] initWithString:@"开启了记账之旅～"]];
    self.titleLab.attributedText = title;
    [self.titleLab sizeToFit];
    
    [self.beginDateBtn setTitle:[beginDate formattedDateWithFormat:@"yyyy年M月d日"] forState:UIControlStateNormal];
}

- (void)setEndDate:(NSDate *)endDate {
    [self.endDateBtn setTitle:[endDate formattedDateWithFormat:@"yyyy年M月d日"] forState:UIControlStateNormal];
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 164, 0)];
        _titleLab.numberOfLines = 0;
        _titleLab.font = [UIFont systemFontOfSize:14];
    }
    return _titleLab;
}

- (UILabel *)beginDateLab {
    if (!_beginDateLab) {
        _beginDateLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 164, 0)];
        _beginDateLab.font = [UIFont systemFontOfSize:16];
        _beginDateLab.text = @"起始";
        [_beginDateLab sizeToFit];
    }
    return _beginDateLab;
}

- (UILabel *)endDateLab {
    if (!_endDateLab) {
        _endDateLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 164, 0)];
        _endDateLab.font = [UIFont systemFontOfSize:16];
        _endDateLab.text = @"结束";
        [_endDateLab sizeToFit];
    }
    return _endDateLab;
}

- (UIButton *)beginDateBtn {
    if (!_beginDateBtn) {
        _beginDateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _beginDateBtn.size = CGSizeMake(120, 30);
        _beginDateBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_beginDateBtn setTitle:@"--年--月--日" forState:UIControlStateNormal];
        [_beginDateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_beginDateBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:@"47cfbe"]];
        [_beginDateBtn ssj_setBorderStyle:SSJBorderStyleBottom];
        [_beginDateBtn ssj_setBorderWidth:1];
    }
    return _beginDateBtn;
}

- (UIButton *)endDateBtn {
    if (!_endDateBtn) {
        _endDateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _endDateBtn.size = CGSizeMake(120, 30);
        _endDateBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_endDateBtn setTitle:@"--年--月--日" forState:UIControlStateNormal];
        [_endDateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_endDateBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:@"47cfbe"]];
        [_endDateBtn ssj_setBorderStyle:SSJBorderStyleBottom];
        [_endDateBtn ssj_setBorderWidth:1];
    }
    return _endDateBtn;
}

- (UIImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        _arrowView.size = CGSizeMake(40, 20);
    }
    return _arrowView;
}

@end
