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
#import <TencentOpenAPI/QQApiInterface.h>
@interface SSJBillNoteWebViewController ()<UIWebViewDelegate,UMSocialUIDelegate,UIScrollViewDelegate>
//
/**
 截图的image
 */
@property (nonatomic, strong) NSData *shareImage;

@property (nonatomic, strong) UIWebView *webView;
/**
 webView的高度
 */
@property (nonatomic, assign) CGFloat totalWebViewHeight;

@end

@implementation SSJBillNoteWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webView];
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
    
    if (!SSJUSERID().length) return;
//    NSString *urlStr = [NSString stringWithFormat:@"http://jz.youyuwo.com/5/zd?userid=%@",SSJUSERID()];
    NSString *urlStr = nil;
    if (self.urlStr.length) {
        urlStr = self.urlStr;
    }else{
        urlStr = [NSString stringWithFormat:@"http://jz.youyuwo.com/5/zd/?cuserId=%@",SSJUSERID()];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [self.webView loadRequest:request];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
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

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    SSJPRINT(@"finish");
    
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString containsString:@"backtolast"]) {//返回
        [self backButtonClicked];
        return NO;
    }
    if ([request.URL.absoluteString containsString:@"sharemybillok"]) {
        [self shareMyBill];//分享
        return NO;
    }
    if ([request.URL.absoluteString containsString:@"lastpage"]) {  
        return NO;
    }
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    SSJPRINT(@"error = %@",error.localizedDescription);
}



#pragma mark - Event
- (void)backButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.backButtonClickBlock) {
        self.backButtonClickBlock();
    }
}

#pragma mark - Private
//截图
- (void)screenImage
{
    //如果截图不存在
    if (!self.shareImage){
//        sleep(0.2);
        float height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('static')[0].offsetHeight;"] floatValue];
        float oldHeight = self.webView.frame.size.height;
        CGRect frame = self.webView.frame;
        frame.size.height = height;
        self.webView.scrollView.contentSize = CGSizeMake(0, height);
        self.webView.frame = frame;
        UIImage *origImage = [self.webView ssj_takeScreenShotWithSize:self.webView.size opaque:YES scale:0];
        self.shareImage = UIImageJPEGRepresentation(origImage, 0.9);
        //        [self saveImageToPhotos:origImage];
        frame.size.height = oldHeight;
        self.webView.frame = frame;
    }
    //截图完毕回复动图oc调用js方法
    [self.webView stringByEvaluatingJavaScriptFromString:@"staticToDynamic();"];
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
                                shareToSnsNames:@[UMShareToWechatTimeline, UMShareToWechatSession, UMShareToQQ, UMShareToSina]
                                       delegate:self];
//    NSData *imgData = self.shareImage;
//    QQApiImageObject *imgObj = [QQApiImageObject objectWithData:imgData
//                                               previewImageData:nil
//                                                          title:@"QQ互联测试"
//                                                    description:@"QQ互联测试分享"];
//    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
//
//    //将内容分享到qq
//    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
}
- (void)saveImageToPhotos:(UIImage *)image{
    //用C语言
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSLog(@"success");
}

- (UIImage*)screenView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.width, view.height - SSJ_NAVIBAR_BOTTOM), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
    
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
//    if (platformName == UMShareToWechatSession) {
        socialData.shareImage = self.shareImage;
//    }else{
//        
//    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
@end
