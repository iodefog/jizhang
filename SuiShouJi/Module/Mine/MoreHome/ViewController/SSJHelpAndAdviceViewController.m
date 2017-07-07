//
//  SSJHelpAndAdviceViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/5.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJHelpAndAdviceViewController.h"
#import "SSJProductAdviceViewController.h"

@interface SSJHelpAndAdviceViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) UIButton *helpBtn;

@property (nonatomic, strong) UIWebView *webView;
@end

@implementation SSJHelpAndAdviceViewController
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
        self.appliesTheme = NO;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"帮助与反馈";
    [self.view addSubview:self.webView];
    [self.view addSubview:self.helpBtn];
    [self updateViewConstraints];
}

- (void)updateViewConstraints {
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_offset(0);
        make.top.mas_equalTo(SSJ_NAVIBAR_BOTTOM);
        make.bottom.mas_offset(-50);
    }];
    
    [self.helpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_offset(0);
        make.top.mas_equalTo(self.webView.mas_bottom);
        make.height.mas_equalTo(50);
    }];
    [super updateViewConstraints];
}

#pragma mark - UIWebViewDelegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [CDAutoHideMessageHUD showMessage:error.description];
}

- (UIButton *)helpBtn {
    if (!_helpBtn) {
        _helpBtn = [[UIButton alloc] init];
        [_helpBtn setTitle:@"反馈" forState:UIControlStateNormal];
        [_helpBtn setTitleColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].marcatoColor] forState:UIControlStateNormal];
        _helpBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        @weakify(self);
        [[_helpBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            SSJProductAdviceViewController *proVC = [[SSJProductAdviceViewController alloc] init];
            proVC.defaultAdviceType = SSJAdviceTypeAdvice;
            [self.navigationController pushViewController:proVC animated:YES];
        }];
        [_helpBtn ssj_setBorderColor:[UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].cellSeparatorColor]];
        [_helpBtn ssj_setBorderStyle:SSJBorderStyleTop];
        [_helpBtn ssj_setBorderWidth:1];
        _helpBtn.backgroundColor = [UIColor whiteColor];
    }
    return _helpBtn;
}

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://jzcms.youyuwo.com/a/bangzhu/index.html"]];
        [_webView loadRequest:request];
        _webView.delegate = self;
    }
    return _webView;
}


@end
