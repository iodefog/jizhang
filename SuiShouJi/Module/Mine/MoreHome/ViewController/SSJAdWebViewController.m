//
//  SSJAdWebViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/7/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAdWebViewController.h"
#import "UIViewController+MMDrawerController.h"

@interface SSJAdWebViewController ()

@end

@implementation SSJAdWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showPageTitleInNavigationBar = YES;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
//    self.navigationItem.rightBarButtonItem = rightItem;
    [self.mm_drawerController setMaximumLeftDrawerWidth:SSJSCREENWITH];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
}

#pragma mark - Event
-(void)goBackAction{
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)rightButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        NSURL *url = [request URL];
        NSString *urlStr = [NSString stringWithFormat:@"%@",url];
        if ([urlStr hasPrefix:@"weixin"]) {
            if([[UIApplication sharedApplication]canOpenURL:url])
            {
                [[UIApplication sharedApplication]openURL:url];
            }
            return NO;
        }
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
