//
//  SSJBillNoteWebViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/1/9.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBillNoteWebViewController.h"
#import "UMSocial.h"
#import "SSJViewAddition.h"
@interface SSJBillNoteWebViewController ()<UIWebViewDelegate,UMSocialUIDelegate,UIScrollViewDelegate>
//
/**
 截图的image
 */
@property (nonatomic, strong) UIImage *shareImage;

@property (nonatomic, strong) UIWebView *webView;
/**
 webView的高度
 */
@property (nonatomic, assign) CGFloat totalWebViewHeight;
/**
 提示标签
 */
@property (nonatomic, strong) UILabel *noticeLabel;

@end

@implementation SSJBillNoteWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.noticeLabel];
    self.title = @"2016年——我的有鱼账单";
//    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor whiteColor]}];
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://shemei0515.com"]];
//    [self.webView loadRequest:request];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:@"ffffff" alpha:0.5] size:CGSizeZero] forBarMetrics:UIBarMetricsDefault];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_bill_note_share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareMyBill)];
//    self.view.backgroundColor = [UIColor whiteColor];
//    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_backOff"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked)];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.2.192:3000"]];
    [self.webView loadRequest:request];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    [self performSelector:@selector(shareMyBill) withObject:nil afterDelay:5];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.noticeLabel.frame = CGRectMake(0, 44, self.view.width, 34);
}

#pragma mark - Lazy
- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.delegate = self;
        _webView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    }
    return _webView;
}


- (UILabel *)noticeLabel
{
    if (!_noticeLabel) {
        _noticeLabel = [[UILabel alloc] init];
        _noticeLabel.backgroundColor = [UIColor ssj_colorWithHex:@"0394e0"];
        _noticeLabel.textColor = [UIColor ssj_colorWithHex:@"c5e8ff"];
        _noticeLabel.font = [UIFont systemFontOfSize:13];
        _noticeLabel.text = @"   再次查看2016年账单，可点击'更多'上方的广告栏哦！";
        _noticeLabel.alpha = 0;
    }
    return _noticeLabel;
}


- (UIImage*)screenView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.width, view.height - SSJ_NAVIBAR_BOTTOM), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
    
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    float oldHeight = webView.frame.size.height;
   
//    CGRect frame = webView.frame;
//    frame.size.height = height;
//    webView.scrollView.contentSize = CGSizeMake(0, height);
//    webView.frame = frame;
////    self.shareImage = [self screenView:webView];
//    self.shareImage = [webView ssj_takeScreenShotWithSize:webView.size opaque:YES scale:0];
//    [self saveImageToPhotos:self.shareImage];
//    frame.size.height = oldHeight;
//    webView.frame = frame;
    
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString containsString:@"backtolast"]) {//返回
        [self backButtonClicked];
        return NO;
    }
    if ([request.URL.absoluteString containsString:@"sharemybill"]) {//分享
        [self shareMyBill];//分享
        return NO;
    }
    return YES;
}



#pragma mark - Event
- (void)backButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Private
- (void)showNoticeLabel
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.noticeLabel.alpha = 1;
    }];
}

//截图
- (void)screenImage
{
    float height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
//    self.totalWebViewHeight = height;
    float oldHeight = self.webView.frame.size.height;
//    float height = self.totalWebViewHeight;
    CGRect frame = self.webView.frame;
    frame.size.height = height;
    self.webView.scrollView.contentSize = CGSizeMake(0, height);
    self.webView.frame = frame;
//    self.shareImage = [self screenView:self.webView];
    self.shareImage = [self.webView ssj_takeScreenShotWithSize:self.webView.size opaque:YES scale:0];
    [self saveImageToPhotos:self.shareImage];
    frame.size.height = oldHeight;
    self.webView.frame = frame;
    
    //截图完毕回复动图oc调用js方法
//    [self.webView stringByEvaluatingJavaScriptFromString:@"alert();"];

}

- (void)hiddenNoticeLabel
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.noticeLabel.alpha = 0;
    }];
}

- (UIImage *)newImageWithOldImage:(UIImage *)oldImage OtherImage:(UIImage *)otherImage
{
    
    return nil;
}

- (void)shareMyBill
{
    [self screenImage];//截图
    if (!self.shareImage) return;
    // 微信分享  纯图片
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
    
    // QQ分享消息类型分为图文、纯图片，QQ空间分享只支持图文分享（图片文字缺一不可）
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:SSJDetailSettingForSource(@"UMAppKey")
                                      shareText:nil
                                     shareImage:self.shareImage
                                shareToSnsNames:@[ UMShareToWechatSession, UMShareToWechatTimeline,UMShareToQQ, UMShareToSina]
                                       delegate:self];
}
- (void)saveImageToPhotos:(UIImage *)image{
    //用C语言
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSLog(@"success");
}

#pragma mark - UMSocialUIDelegate
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据responseCode得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"分享成功" action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL],nil];
    }else{
        [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"分享失败" action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL],nil];
    }
}

-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
{
    if (platformName == UMShareToWechatSession) {
        socialData.shareImage = self.shareImage;
    }else{
        
    }
}



@end
