//
//  SSJShareBookSecretPreviewViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/6/7.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBookSecretPreviewViewController.h"

@interface SSJShareBookSecretPreviewViewController ()

@property (nonatomic, strong) UIButton *shareButton;
@end

@implementation SSJShareBookSecretPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.shareButton];
}

- (void)updateViewConstraints {
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottomMargin.left.right.mas_equalTo(self);
        make.height.mas_equalTo(50);
    }];
}
#pragma mark - Event
- (void)shareCodeToOther {
//    NSString *content = [NSString stringWithFormat:@"%@邀你加入【%@】，希望和你开启共享记账之旅，快来！",nickName,weakSelf.item.booksName];
//    
//    [SSJShareManager shareWithType:SSJShareTypeUrl image:nil UrlStr:[NSString stringWithFormat:@"%@",[url mj_url]] title:SSJAppName() content:content PlatformType:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_QQ)] inController:self ShareSuccess:NULL];

}

#pragma mark - Lazy
- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [[UIButton alloc] init];
        _shareButton.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor];
        [_shareButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.loginButtonTitleColor] forState:UIControlStateNormal];
        [_shareButton setTitle:@"发送" forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(shareCodeToOther) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareButton;
}

@end
