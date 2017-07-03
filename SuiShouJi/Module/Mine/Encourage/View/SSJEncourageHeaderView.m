//
//  SSJEncourageHeaderView.m
//  SuiShouJi
//
//  Created by ricky on 2017/6/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJEncourageHeaderView.h"
#import "SSJStartChecker.h"

@interface SSJEncourageHeaderView()

@property(nonatomic, strong) UIImageView *iconImage;

@property(nonatomic, strong) UILabel *appNameLab;

@property(nonatomic, strong) UILabel *versionLab;

@property(nonatomic, strong) UIButton *updateButton;

@end

@implementation SSJEncourageHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [self addSubview:self.iconImage];
        [self addSubview:self.appNameLab];
        [self addSubview:self.versionLab];
        if (![SSJStartChecker sharedInstance].isInReview) {
            [self addSubview:self.updateButton];    
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];
        [self updateConstraintsIfNeeded];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)updateConstraints {
    [self.iconImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.top.mas_equalTo(30);
        make.centerX.mas_equalTo(self);
    }];
    
    [self.appNameLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconImage.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self);
    }];
    
    [self.versionLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.appNameLab).offset(29);
        if ([SSJStartChecker sharedInstance].isInReview) {
            make.centerX.mas_equalTo(self);
        } else {
            make.right.mas_equalTo(self.mas_centerX).offset(10);
        }
    }];
    
    [self.updateButton mas_updateConstraints:^(MASConstraintMaker *make) {
        if ([self.updateButton.titleLabel.text isEqualToString:@"检查更新"]) {
            make.size.mas_equalTo(CGSizeMake(60, 20));
        }
        make.centerY.mas_equalTo(self.versionLab.mas_centerY);
        make.left.mas_equalTo(self.versionLab.mas_right).offset(20);
    }];
    
    [super updateConstraints];
}

- (UIImageView *)iconImage {
    if (!_iconImage) {
        _iconImage = [[UIImageView alloc] init];
        _iconImage.image = [UIImage imageNamed:SSJAppIcon()];
        [_iconImage sizeToFit];
    }
    return _iconImage;
}

- (UILabel *)versionLab {
    if (!_versionLab) {
        _versionLab = [[UILabel alloc] init];
        _versionLab.text = [NSString stringWithFormat:@"版本：%@",SSJAppVersion()];
        _versionLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _versionLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _versionLab;
}

- (UILabel *)appNameLab {
    if (!_appNameLab) {
        _appNameLab = [[UILabel alloc] init];
        _appNameLab.text = SSJAppName();
        _appNameLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _appNameLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _appNameLab;
}

- (UIButton *)updateButton {
    if (!_updateButton) {
        _updateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _updateButton.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        [_updateButton setTitle:@"检查更新" forState:UIControlStateNormal];
        [_updateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _updateButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _updateButton.layer.cornerRadius = 4;
    }
    return _updateButton;
}

- (void)setCurrentVersion:(NSString *)currentVersion {
    if ([SSJAppVersion() isEqualToString:currentVersion]) {
        _updateButton.backgroundColor = [UIColor clearColor];
        [_updateButton setTitle:@"当前已是最新版本" forState:UIControlStateNormal];
        [_updateButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] forState:UIControlStateNormal];
        _updateButton.enabled = NO;
    } else {
        _updateButton.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        [_updateButton setTitle:@"检查更新" forState:UIControlStateNormal];
        [_updateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _updateButton.enabled = YES;
    }
}

- (void)updateCellAppearanceAfterThemeChanged {
    if ([SSJAppVersion() isEqualToString:_currentVersion]) {
        _updateButton.backgroundColor = [UIColor clearColor];
        [_updateButton setTitle:@"当前已是最新版本" forState:UIControlStateNormal];
        [_updateButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] forState:UIControlStateNormal];
    } else {
        _updateButton.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        [_updateButton setTitle:@"检查更新" forState:UIControlStateNormal];
        [_updateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    _versionLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _appNameLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
