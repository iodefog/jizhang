//
//  SSJShareBookSecretPreviewViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/6/7.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJShareBookSecretPreviewViewController.h"
#import "SSJShareManager.h"

@interface SSJShareBookSecretPreviewViewController ()

@property (nonatomic, strong) UIButton *shareButton;
@end

@implementation SSJShareBookSecretPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"邀请函";
    [self.view addSubview:self.shareButton];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.shareButton.left = 0;
    self.shareButton.width = SSJSCREENWITH;
    self.shareButton.top = self.view.height - 60;
    self.shareButton.height = 60;
}


#pragma mark - Event
- (void)shareCodeToOther {
    [SSJShareManager shareWithType:SSJShareTypeUrl image:nil UrlStr:self.webView.request.URL.absoluteString title:SSJAppName() content:self.shareContent PlatformType:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_QQ)] inController:self ShareSuccess:nil];

}

#pragma mark - Lazy
- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [[UIButton alloc] init];
        _shareButton.backgroundColor = [UIColor ssj_colorWithHex:@"#eb4a64"];
        [_shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_shareButton setTitle:@"发送" forState:UIControlStateNormal];
        _shareButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:18];
        [_shareButton addTarget:self action:@selector(shareCodeToOther) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareButton;
}

@end
