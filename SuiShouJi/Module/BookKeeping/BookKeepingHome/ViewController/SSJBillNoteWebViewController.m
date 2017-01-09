//
//  SSJBillNoteWebViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/1/9.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJBillNoteWebViewController.h"
#import "UMSocial.h"
@interface SSJBillNoteWebViewController ()<UIWebViewDelegate,UMSocialUIDelegate>
/**
 截图的image
 */
@property (nonatomic, strong) UIImage *shareImage;

@property (nonatomic, strong) UIWebView *webView;
@end

@implementation SSJBillNoteWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webView];
    self.title = @"2016年——我的有鱼账单";
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:@"ffffff" alpha:0.5] size:CGSizeMake(self.view.width, 64)] forBarMetrics:UIBarMetricsDefault];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.jianshu.com/p/0ba467368180"]];
    [self.webView loadRequest:request];

    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_bill_note_share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareMyBill)];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_backOff"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked)];
}


- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.delegate = self;
        _webView.frame = self.view.bounds;
    }
    return _webView;
}


- (UIImage*)screenView:(UIView *)view {
    CGRect rect = view.frame;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
    
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    float oldHeight = webView.frame.size.height * [UIScreen mainScreen].scale;
    float height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    CGRect frame = webView.frame;
    frame.size.height = height * [UIScreen mainScreen].scale;
    webView.scrollView.contentSize = CGSizeMake(0, height);
    webView.frame = frame;
    self.shareImage = [self screenView:webView];
//    [self saveImageToPhotos:self.shareImage];
    frame.size.height = oldHeight;
    webView.frame = frame;
}

- (void)backButtonClicked
{
    __weak typeof(self)weakSelf = self;
    [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"再次查看2016年账单，可点击'更多'上方的广告栏哦！" action:[SSJAlertViewAction actionWithTitle:@"知道了" handler:^(SSJAlertViewAction *action) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
            }],nil];
}

- (void)shareMyBill
{
    // 微信分享  纯图片
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
    
    // QQ分享消息类型分为图文、纯图片，QQ空间分享只支持图文分享（图片文字缺一不可）
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:SSJDetailSettingForSource(@"UMAppKey")
                                      shareText:nil
                                     shareImage:self.shareImage
                                shareToSnsNames:@[UMShareToQQ, UMShareToWechatSession, UMShareToWechatTimeline, UMShareToSina]
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
    if (platformName == UMShareToSina) {
        socialData.shareText = [NSString stringWithFormat:@"%@ %@",SSJDetailSettingForSource(@"ShareTitle"),SSJDetailSettingForSource(@"ShareUrl")];
        socialData.shareImage = [UIImage imageNamed:SSJDetailSettingForSource(@"WeiboBanner")];
    }else{
        socialData.shareText = SSJDetailSettingForSource(@"ShareContent");
    }
}



@end
