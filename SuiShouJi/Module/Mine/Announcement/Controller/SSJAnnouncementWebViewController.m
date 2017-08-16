//
//  SSJAnnouncementWebView.m
//  SuiShouJi
//
//  Created by ricky on 2017/3/2.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJAnnouncementWebViewController.h"
#import "SSJShareManager.h"

@interface SSJAnnouncementWebViewController ()

@end

@implementation SSJAnnouncementWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    
    if (([SSJDefaultSource() isEqualToString:@"11501"] || [SSJDefaultSource() isEqualToString:@"11502"]) && self.item) {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"home_bill_note_share"] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
        
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    
    // Do any additional setup after loading the view.
}

- (void)rightButtonClicked:(id)sender {
    [SSJShareManager shareWithType:SSJShareTypeUrl image:nil UrlStr:self.item.announcementUrl title:self.item.announcementTitle content:self.item.announcementContent PlatformType:@[@(UMSocialPlatformType_Sina),@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ)] inController:self ShareSuccess:^(UMSocialShareResponse *response) {
        
    }];
}

-(void)goBackAction{
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
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
