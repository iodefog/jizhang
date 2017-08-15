//
//  SSJNormalWebViewController.m
//  MoneyMore
//
//  Created by cdd on 15/4/1.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import "SSJNormalWebViewController.h"

@interface SSJNormalWebViewController ()<UIWebViewDelegate,UIActionSheetDelegate>{
    NSTimer *_fakeProgressTimer;
}


//保存前一个视图控制器navbar和toolbar的状态
@property (nonatomic, assign) BOOL previousNavigationControllerToolbarHidden, previousNavigationControllerNavigationBarHidden;
@property (nonatomic, strong) UIBarButtonItem *backButton, *forwardButton, *refreshButton, *stopButton, *actionButton, *fixedSeparator, *flexibleSeparator;

@property (nonatomic, strong) UIButton *gobackButton, *closeButton;
@property (nonatomic, strong) NSURL *webViewCurrentURL;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *lblinkURL;
/**
 titleView
 */
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation SSJNormalWebViewController
@synthesize webView=_webView;

+ (instancetype)webViewVCWithURL:(NSURL *)url{
    SSJNormalWebViewController *webViewVC=[[self alloc]init];
    webViewVC.url=url;
    return webViewVC;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.appliesTheme = NO;
        self.toolBarHidden = YES;
        self.showURLInNavigationBar = NO;
//        self.showPageTitleInNavigationBar = NO;
        self.hidesBottomBarWhenPushed=YES;
        self.progressViewTintColor=[UIColor ssj_colorWithHex:@"#EE4F4F"];
    }
    return self;
}

- (void)viewDidLoad{
    self.previousNavigationControllerToolbarHidden = self.navigationController.toolbarHidden;
    self.previousNavigationControllerNavigationBarHidden = self.navigationController.navigationBarHidden;
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:self.navigationController.navigationBarHidden animated:YES];
    [self.navigationController setToolbarHidden:self.toolBarHidden animated:YES];
    
    //设置导航栏返回和关闭按钮
    [self setUpNav];
    
    [self.view addSubview:self.webView];
    if (self.toolBarItemTintColor) {
        [self.navigationController.toolbar setTintColor:self.toolBarItemTintColor];
    }
    if (self.toolBarTintColor) {
        [self.navigationController.toolbar setBarTintColor:self.toolBarTintColor];
    }
    if (self.url!=nil) {
        [self loadURL:self.url];
    }
    
    self.navigationItem.titleView = self.titleLabel;
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.webView.frame = CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self.navigationController.navigationBar addSubview:self.progressView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.webView stopLoading];
    [self.webView setDelegate:nil];
    [self.progressView removeFromSuperview];
    [self.navigationController setToolbarHidden:self.previousNavigationControllerToolbarHidden animated:animated];
    [self.navigationController setNavigationBarHidden:self.previousNavigationControllerNavigationBarHidden animated:animated];
    [self invalidateTimer];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UIWebView *)webView{
    if (_webView==nil) {
        _webView = [[UIWebView alloc] init];
        [_webView setDelegate:self];
        [_webView setMultipleTouchEnabled:YES];
        [_webView setScalesPageToFit:YES];
        [_webView.scrollView setAlwaysBounceVertical:YES];
    }
    return _webView;
}

- (UILabel *)lblinkURL{
    if (_lblinkURL == nil) {
        self.webView.scrollView.backgroundColor=[UIColor clearColor];
        _lblinkURL=[[UILabel alloc]initWithFrame:CGRectMake(20, 5, self.webView.scrollView.width-40, 20)];
        _lblinkURL.textColor=[UIColor whiteColor];
        _lblinkURL.font=[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _lblinkURL.textAlignment=NSTextAlignmentCenter;
        [self.webView insertSubview:_lblinkURL belowSubview:self.webView.scrollView];
    }
    return _lblinkURL;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:@"333333"];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
    }
    return _titleLabel;
}

- (UIProgressView *)progressView{
    if (_progressView==nil) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [_progressView setTrackTintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
        [_progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        if (self.progressViewTintColor) {
            [_progressView setTintColor:self.progressViewTintColor];
        }
        [_progressView setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height-_progressView.frame.size.height, self.view.frame.size.width, _progressView.frame.size.height)];
    }
    return _progressView;
}

- (UIBarButtonItem *)backButton{
    if (_backButton==nil) {
        UIImage *backbuttonImage = [UIImage imageNamed:@"backbutton"];
        _backButton = [[UIBarButtonItem alloc] initWithImage:backbuttonImage style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed:)];
    }
    return _backButton;
}

- (UIBarButtonItem *)forwardButton{
    if (_forwardButton==nil) {
        UIImage *forwardbuttonImage = [UIImage imageNamed:@"forwardbutton"];
        _forwardButton = [[UIBarButtonItem alloc] initWithImage:forwardbuttonImage style:UIBarButtonItemStylePlain target:self action:@selector(forwardButtonPressed:)];
    }
    return _forwardButton;
}

- (UIBarButtonItem *)refreshButton{
    if (_refreshButton==nil) {
        _refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
    }
    return _refreshButton;
}

- (UIBarButtonItem *)stopButton{
    if (_stopButton==nil) {
        _stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopButtonPressed:)];
    }
    return _stopButton;
}

- (UIBarButtonItem *)actionButton{
    if (_actionButton==nil) {
        _actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
    }
    return _actionButton;
}

- (UIBarButtonItem *)fixedSeparator{
    if (_fixedSeparator==nil) {
        _fixedSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        _fixedSeparator.width = 50.0f;
    }
    return _fixedSeparator;
}

- (UIBarButtonItem *)flexibleSeparator{
    if (_flexibleSeparator==nil) {
        _flexibleSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    }
    return _flexibleSeparator;
}

- (UIButton *)gobackButton{
    if (!_gobackButton) {
        _gobackButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_gobackButton setImage:[[UIImage imageNamed:@"navigation_backOff"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        if (self.appliesTheme) {
            _gobackButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor];
        }
        [_gobackButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _gobackButton;
}

- (UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        if (self.appliesTheme) {
            _closeButton.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor];
        }
        [_closeButton setImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (void)loadRequest:(NSURLRequest *)request {
    [self.webView loadRequest:request];
}

- (void)loadURL:(NSURL *)URL {
    [self loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)loadURLString:(NSString *)URLString {
    NSURL *URL = [NSURL URLWithString:URLString];
    [self loadURL:URL];
}

- (void)loadHTMLString:(NSString *)HTMLString {
    [self.webView loadHTMLString:HTMLString baseURL:nil];
}

//- (void)setTitleString:(NSString *)titleString
//{
//    _titleString = titleString;
//    self.titleLabel.text = self.title;
//    [self.titleLabel sizeToFit];
//    self.titleLabel.leftTop = CGPointMake((self.webView.width - self.titleLabel.width) * 0.5, (44 - self.titleLabel.height) * 0.5);
//}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    self.titleLabel.leftTop = CGPointMake((self.webView.width - self.titleLabel.width) * 0.5, (44 - self.titleLabel.height) * 0.5);
}


#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if(webView == self.webView) {
        self.webViewCurrentURL = request.URL;
        if([self isJumpToExternalAppWithURL:request.URL]) {
            [[UIApplication sharedApplication] openURL:request.URL];
            return NO;
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    if(webView == self.webView) {
        [self updateNavTitle];
        [self updateToolbarState];
        [self fakeProgressViewStartLoading];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if(webView == self.webView) {
        if ([self.webView.request.URL host]!=nil && [self.webView.request.URL host].length!=0) {
            self.lblinkURL.text=[NSString stringWithFormat:@"网页由 %@ 提供",[self.webView.request.URL host]];
        }
        [self updateNavTitle];
        [self updateToolbarState];
        [self fakeProgressBarStopLoading];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if(webView == self.webView) {
        [self updateNavTitle];
        [self updateToolbarState];
        [self fakeProgressBarStopLoading];
        [CDAutoHideMessageHUD showMessage:@"出错了,请稍后再试"];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:self.webViewCurrentURL];//[NSURL URLWithString:@"http://www.apple.com/"]
    }
}

#pragma mark - UIBarButtonItem Target Action Methods
- (void)backButtonPressed:(id)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)forwardButtonPressed:(id)sender {
    [self.webView goForward];
}

- (void)refreshButtonPressed:(id)sender {
    [self.webView stopLoading];
    [self.webView reload];
}

- (void)stopButtonPressed:(id)sender {
    [self.webView stopLoading];
}

- (void)actionButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"在Safari中打开",
                                  nil];
    [actionSheet showInView:self.view];
}

- (void)closeButtonButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refresh{
    [self.webView stopLoading];
//    [self loadURL:self.url];
    [self.webView reload];
}

/**
 *  进度条开始加载
 */
- (void)fakeProgressViewStartLoading {
    [self.progressView setProgress:0.0f animated:NO];
    [self.progressView setAlpha:1.0f];
    
    if(!_fakeProgressTimer) {
        _fakeProgressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(fakeProgressTimerDidFire) userInfo:nil repeats:YES];
    }
}

/**
 *  进度条停止
 */
- (void)fakeProgressBarStopLoading {
    [self invalidateTimer];
    [self.progressView setProgress:1.0f animated:YES];
    [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.progressView setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self.progressView setProgress:0.0f animated:NO];
    }];
}

- (void)invalidateTimer{
    if(_fakeProgressTimer.isValid) {
        [_fakeProgressTimer invalidate];
        _fakeProgressTimer=nil;
    }
}

/**
 *  更新进度条状态
 */
- (void)fakeProgressTimerDidFire{
    CGFloat increment = 0.005/(self.progressView.progress + 0.2);
    if([self.webView isLoading]) {
        CGFloat progress = (self.progressView.progress < 0.75f) ? self.progressView.progress + increment : self.progressView.progress + 0.0005;
        if(self.progressView.progress < 0.95) {
            [self.progressView setProgress:progress animated:YES];
        }
    }
}

/**
 *  更新title
 */
- (void)updateNavTitle{
    if(self.webView.isLoading) {
        
        //如果说是公司文字则不要标题为空
        NSString *URLString = [self.webViewCurrentURL absoluteString];
        if ([URLString hasPrefix:@"http://jzcms.youyuwo.com/"]) {
            self.showPageTitleInNavigationBar = NO;
            self.navigationItem.title = @"";
            return;
        }
        if(self.showURLInNavigationBar) {
//            NSString *URLString = [self.webViewCurrentURL absoluteString];
            URLString = [URLString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
            URLString = [URLString stringByReplacingOccurrencesOfString:@"https://" withString:@""];
            URLString = [URLString substringToIndex:[URLString length]-1];
            self.navigationItem.title = URLString;
        }
    }else{
        if(self.showPageTitleInNavigationBar) {
            self.titleLabel.text = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
            [self.titleLabel sizeToFit];
            self.titleLabel.leftTop = CGPointMake((self.webView.width - self.titleLabel.width) * 0.5, (44 - self.titleLabel.height) * 0.5);
        }
    }
}

/**
 *  更新工具条Item状态
 */
- (void)updateToolbarState {
    if (self.toolBarHidden) {
        return;
    }
    [self.backButton setEnabled:self.webView.canGoBack];
    [self.forwardButton setEnabled:self.webView.canGoForward];
    NSArray *barButtonItems=nil;
    if(self.webView.isLoading) {
        barButtonItems = @[self.backButton, self.fixedSeparator, self.forwardButton, self.fixedSeparator, self.stopButton, self.flexibleSeparator,self.actionButton];
    } else {
        barButtonItems = @[self.backButton, self.fixedSeparator, self.forwardButton, self.fixedSeparator, self.refreshButton, self.flexibleSeparator,self.actionButton];
    }
    [self setToolbarItems:barButtonItems animated:YES];
}

/**
 *  url是否是跳转APP类型的
 *
 *  @param URL
 *
 *  @return BOOL
 */
- (BOOL)isJumpToExternalAppWithURL:(NSURL *)URL{
    NSSet *validSchemes = [NSSet setWithArray:@[@"http", @"https"]];
    return ![validSchemes containsObject:URL.scheme];
}


- (void)setUpNav {
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:self.gobackButton];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:self.closeButton];
    self.navigationItem.leftBarButtonItems = @[item1,item2];
}

@end

