//
//  SSJWishStartViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/14.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishStartViewController.h"
#import "SSJMakeWishViewController.h"
#import "SSJWishManageViewController.h"

@interface SSJWishStartViewController ()

@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UIButton *startBtn;

@end

@implementation SSJWishStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showNavigationBarBaseLine = NO;
    self.title = @"为心愿存钱";
    [self setUpUI];
    [self appearanceWithTheme];
    [self updateViewConstraints];
}

#pragma mark - Layout
- (void)updateViewConstraints {
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self).offset(-80);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.greaterThanOrEqualTo(0);
    }];
    
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).offset(-68);
        make.left.right.mas_equalTo(self.tipLabel);
        make.height.mas_equalTo(44);
    }];
    [super updateViewConstraints];
}

#pragma mark - Private
- (void)setUpUI {
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.startBtn];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self appearanceWithTheme];
}

- (void)appearanceWithTheme {
    self.tipLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.startBtn.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor];
    if ([SSJ_CURRENT_THEME.ID isEqualToString:SSJDefaultThemeID]) {
        self.backgroundView.image = [UIImage ssj_compatibleImageNamed:@"wish_start_bg"];
    }
}

- (void)ssj_backOffAction {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Lazy
- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.text = @"过往再美\n未来也是要靠智慧和钱生活的\n\n在这里，和一百万人一起\n为心愿存钱，一步步实现自己的小心愿";
        _tipLabel.numberOfLines = 0;
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _tipLabel;
}

- (UIButton *)startBtn {
    if (!_startBtn) {
        _startBtn = [[UIButton alloc] init];
        _startBtn.layer.cornerRadius = 6;
        _startBtn.layer.masksToBounds = YES;
        [_startBtn setTitle:@"开启" forState:UIControlStateNormal];
        _startBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        @weakify(self);
        [[_startBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            SSJMakeWishViewController *makeWishVC = [[SSJMakeWishViewController alloc] init];
            [self.navigationController pushViewController:makeWishVC animated:YES];
        }];
    }
    return _startBtn;
}
@end
