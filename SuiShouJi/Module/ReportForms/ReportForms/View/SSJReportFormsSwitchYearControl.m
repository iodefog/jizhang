//
//  SSJReportFormsSwitchYearControl.m
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJReportFormsSwitchYearControl.h"

@interface SSJReportFormsSwitchYearControl ()

@property (nonatomic, strong) UIButton *preBtn;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation SSJReportFormsSwitchYearControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.preBtn];
        [self addSubview:self.nextBtn];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    self.titleLabel.center = CGPointMake(self.width * 0.5, self.height * 0.5);
    self.preBtn.size = self.nextBtn.size = CGSizeMake(27, self.height);
    self.preBtn.right = self.titleLabel.left;
    self.nextBtn.left = self.titleLabel.right;
}

- (void)setTitle:(NSString *)title {
    if (![_titleLabel.text isEqualToString:title]) {
        _titleLabel.text = title;
        [_titleLabel sizeToFit];
        [self setNeedsLayout];
    }
}

- (UIButton *)preBtn {
    if (!_preBtn) {
        _preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_preBtn setImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
    }
    return _preBtn;
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextBtn setImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
    }
    return _nextBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:@"#393939"];
    }
    return _titleLabel;
}

@end
