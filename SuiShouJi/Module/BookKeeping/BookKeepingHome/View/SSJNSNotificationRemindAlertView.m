//
//  SSJNSNotificationRemindAlertView.m
//  SuiShouJi
//
//  Created by yi cai on 2017/6/30.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJNSNotificationRemindAlertView.h"

#import "SSJGeTuiManager.h"

@interface SSJNSNotificationRemindAlertView ()
@property (nonatomic, strong) UIImageView *topImageView;

@property (nonatomic, strong) UILabel *titleL;

@property (nonatomic, strong) UIButton *openButton;
@end

@implementation SSJNSNotificationRemindAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 12;
        self.layer.masksToBounds = YES;
        
        [self addSubview:self.topImageView];
        [self addSubview:self.titleL];
        [self addSubview:self.openButton];
        
        [self setNeedsUpdateConstraints];
    }
    return self;
}


- (void)updateConstraints {
    
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(20);
    }];
    
    [self.titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.width.greaterThanOrEqualTo(0);
        make.top.mas_equalTo(self.topImageView.mas_bottom).offset(15);
    }];
    
    [self.openButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleL.mas_bottom).offset(40);
        make.left.mas_equalTo(10);
        make.rightMargin.mas_equalTo(-10);
        make.height.mas_equalTo(44);
    }];

    [super updateConstraints];
}

- (void)show {
    //是否已经弹出过授权通知弹框
    if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) return;
    
    //拒绝
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SSJNoticeRemindKey]) return;
    if (self.superview) return;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.hidden = NO;
    [keyWindow addSubview:self];
    self.size = CGSizeMake(keyWindow.width-56, 260);
    self.center = keyWindow.center;
    [keyWindow ssj_showViewWithBackView:self backColor:[UIColor blackColor] alpha:0.5 target:self touchAction:@selector(dismiss)];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SSJNoticeRemindKey];

}

- (void)dismiss {
    if (!self.superview) return;
    @weakify(self);
    [self.superview ssj_hideBackViewForView:self animation:^{
        @strongify(self);
        self.hidden = YES;
    } timeInterval:0.25 fininshed:^(BOOL complation) {
        [self removeFromSuperview];
    }];
}

- (void)openButtonClicked {
    //开启通知授权
    [self dismiss];
    [[SSJGeTuiManager shareManager] registerRemoteNotificationWithDelegate:[UIApplication sharedApplication]];
}

#pragma mark - Lazy

- (UIImageView *)topImageView
{
    if (!_topImageView) {
        _topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notice_open_image"]];
    }
    return _topImageView;
}

- (UILabel *)titleL {
    if (!_titleL) {
        _titleL = [[UILabel alloc] init];
        _titleL.numberOfLines = 0;
        _titleL.textAlignment = NSTextAlignmentCenter;
        _titleL.text = @"开启记账\n小鱼会根据你的设定来提醒记账";
        _titleL.textColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].mainColor];
        _titleL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _titleL;
}

- (UIButton *)openButton
{
    if (!_openButton) {
        _openButton = [[UIButton alloc] init];
        _openButton.backgroundColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].marcatoColor];
        _openButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [_openButton setTitle:@"请通知我" forState:UIControlStateNormal];
        [_openButton addTarget:self action:@selector(openButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _openButton.layer.cornerRadius = 8;
        _openButton.layer.masksToBounds = YES;
    }
    return _openButton;
}



@end
