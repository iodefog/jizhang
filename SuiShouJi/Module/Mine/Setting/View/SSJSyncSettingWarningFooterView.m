//
//  SSJSyncSettingWarningFooterView.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/3.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJSyncSettingWarningFooterView.h"

@interface SSJSyncSettingWarningFooterView ()

@property (nonatomic, strong) UIImageView *warningLogo;

@property (nonatomic, strong) UILabel *warningLab;

@end

@implementation SSJSyncSettingWarningFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.warningLogo];
        [self addSubview:self.warningLab];
        [self updateAppearanceAccordingToTheme];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    self.warningLab.width = SSJSCREENWITH - self.warningLogo.right - 12 - 15;
    [self.warningLab sizeToFit];
    return CGSizeMake(SSJSCREENWITH, self.warningLab.height + 24);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.warningLogo.size = self.warningLogo.image.size;
    self.warningLogo.leftTop = CGPointMake(15, 12);
    
    self.warningLab.width = SSJSCREENWITH - self.warningLogo.right - 12 - 15;
    self.warningLab.leftTop = CGPointMake(self.warningLogo.right + 12, 12);
    [self.warningLab sizeToFit];
}

//- (void)updateConstraints {
//    [self.warningLogo mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(12);
//        make.left.mas_equalTo(15);
//        make.size.mas_equalTo(self.warningLogo.image.size);
//    }];
//    [self.warningLab mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(12);
//        make.left.mas_equalTo(self.warningLogo.mas_right).offset(12);
//        make.right.mas_equalTo(-15);
//        make.bottom.mas_equalTo(-12);
//        make.height.mas_equalTo(36);
//    }];
//    [super updateConstraints];
//}

- (void)setWarningText:(NSString *)warningText {
    _warningText = warningText;
    self.warningLab.text = warningText;
//    [self setNeedsUpdateConstraints];
    [self sizeToFit];
    [self setNeedsLayout];
}

- (void)updateAppearanceAccordingToTheme {
    self.warningLab.textColor = SSJ_SECONDARY_COLOR;
}

- (UIImageView *)warningLogo {
    if (!_warningLogo) {
        _warningLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warning"]];
    }
    return _warningLogo;
}

- (UILabel *)warningLab {
    if (!_warningLab) {
        _warningLab = [[UILabel alloc] init];
        _warningLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _warningLab.numberOfLines = 0;
    }
    return _warningLab;
}

@end
