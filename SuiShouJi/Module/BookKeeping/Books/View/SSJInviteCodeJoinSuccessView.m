//
//  SSJInviteCodeJoinSuccessView.m
//  SuiShouJi
//
//  Created by yi cai on 2017/6/8.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJInviteCodeJoinSuccessView.h"

@interface SSJInviteCodeJoinSuccessView ()
/**topImage*/
@property (nonatomic, strong) UIImageView *topImageView;

/**title*/
@property (nonatomic, strong) UILabel *centerLab;

/**sureButton*/
@property (nonatomic, strong) UIButton *sureButton;

/**bgVeiw*/
@property (nonatomic, strong) UIView *bgView;
@end

@implementation SSJInviteCodeJoinSuccessView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.bgView];
        [self addSubview:self.topImageView];
        [self.bgView addSubview:self.centerLab];
        [self.bgView addSubview:self.sureButton];
        [self themeAppearance];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeAppearance) name:SSJThemeDidChangeNotification object:nil];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.size.mas_equalTo(self.topImageView.image.size);
    }];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(self.topImageView.image.size.height * 0.5);
        make.width.mas_equalTo(280);
    }];
    
    [self.centerLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).offset(78);
        make.left.mas_equalTo(self.bgView).offset(22);
        make.right.mas_equalTo(self.bgView).offset(-22);
    }];
    
    [self.sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.centerLab.mas_bottom).offset(40);
        make.left.mas_equalTo(self.bgView).offset(30);
        make.bottom.mas_equalTo(self.bgView).offset(-34);
        make.right.mas_equalTo(self.bgView).offset(-30);
        make.height.mas_equalTo(44);
    }];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topImageView);
        make.left.and.bottom.and.right.mas_equalTo(self.bgView);
        if (self.superview) {
            make.center.mas_equalTo(self.superview);
        }
    }];
    
    [super updateConstraints];
}

#pragma mark - Private
- (void)showWithDesc:(NSString *)desc {
    self.centerLab.text = desc;
    [self setNeedsUpdateConstraints];
    
    self.alpha = 0;
    self.center = CGPointMake(SSJSCREENWITH * 0.5, SSJSCREENHEIGHT * 0.5);
    [SSJ_KEYWINDOW ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.5 target:self touchAction:@selector(dismiss) animation:^{
        self.alpha = 1;
    } timeInterval:0.25 fininshed:NULL];
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    [self.superview ssj_hideBackViewForView:self animation:^{
        self.top = SSJ_KEYWINDOW.bottom;
    } timeInterval:0.25 fininshed:nil];
}

#pragma mark - Notice
- (void)themeAppearance {
    self.sureButton.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor];
    self.centerLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.bgView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
    [self.sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

#pragma mark - Lazy
- (UIImageView *)topImageView {
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"create_share_book_success"]];
        _topImageView.backgroundColor = [UIColor clearColor];
    }
    return _topImageView;
}

- (UILabel *)centerLab {
    if (!_centerLab) {
        _centerLab = [[UILabel alloc] init];
        _centerLab.numberOfLines = 0;
        _centerLab.preferredMaxLayoutWidth = 236;
        _centerLab.backgroundColor = [UIColor clearColor];
        _centerLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _centerLab.textAlignment = NSTextAlignmentCenter;
    }
    return _centerLab;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [[UIButton alloc] init];
        [_sureButton setTitle:@"知道了" forState:UIControlStateNormal];
        _sureButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        _sureButton.layer.cornerRadius = 22;
        _sureButton.layer.masksToBounds = YES;
        [_sureButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.layer.cornerRadius = 12;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
