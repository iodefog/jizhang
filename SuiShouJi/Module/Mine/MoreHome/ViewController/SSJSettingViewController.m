//
//  SSJSettingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSettingViewController.h"
#import "SSJStartChecker.h"
#import "SSJMineHomeTabelviewCell.h"
#import "SSJUserTableManager.h"
#import "SSJUserDefaultDataCreater.h"
#import "SSJSyncSettingViewController.h"
#import "SSJNormalWebViewController.h"
#import "SSJMagicExportViewController.h"
#import "SSJAboutusViewController.h"
#import "SSJStartChecker.h"
#import "SSJStartUpgradeAlertView.h"
#import "SSJDataClearHelper.h"
#import "SSJWeixinFooter.h"
#import "WXApi.h"
#import "SSJStartUpgradeAlertView.h"
#import "SSJNetworkReachabilityManager.h"

static NSString *const kTitle1 = @"自动同步设置";
static NSString *const kTitle2 = @"数据重新拉取";
static NSString *const kTitle3 = @"数据格式化";
static NSString *const kTitle4 = @"分享APP";
static NSString *const kTitle6 = @"关于我们";
static NSString *const kTitle5 = @"检查更新";
static NSString *const kTitle7 = @"微信公众号";
static NSString *const kTitle8 = @"点击上方微信号即可复制并在微信查找即可";


@interface SSJSettingViewController ()
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic,strong) SSJWeixinFooter *weixinFooter;
@end

@implementation SSJSettingViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"设置";
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([SSJStartChecker sharedInstance].isInReview) {
        if ([WXApi isWXAppInstalled]) {
            self.titles = @[@[kTitle1], @[kTitle2 , kTitle3], @[kTitle4], @[kTitle6] ,@[kTitle7,kTitle8]];
        }else{
            self.titles = @[@[kTitle1], @[kTitle2 , kTitle3], @[kTitle4], @[kTitle6]];
        }
    } else {
        if ([WXApi isWXAppInstalled]) {
            self.titles = @[@[kTitle1], @[kTitle2 , kTitle3] , @[kTitle4 , kTitle5], @[kTitle6],@[kTitle7,kTitle8]];
        }else{
            self.titles = @[@[kTitle1], @[kTitle2 , kTitle3] , @[kTitle4 , kTitle5], @[kTitle6]];
        }
    }
    
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle8]) {
        return 35;
    }
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == [self.tableView numberOfSections] - 1) {
        return self.weixinFooter;
    }
    return nil;
//    UIView *footerView = [[UIView alloc]initWithFrame:CGRectZero];
//    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == [self.tableView numberOfSections] - 1) {
        return 150;
    }
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    
    //  同步设置
    if ([title isEqualToString:kTitle1]) {
        SSJSyncSettingViewController *syncSettingVC = [[SSJSyncSettingViewController alloc]init];
        [self.navigationController pushViewController:syncSettingVC animated:YES];
    }
    
    //  重新拉去
    if ([title isEqualToString:kTitle2]) {
//        NSAttributedString *massage = [[NSAttributedString alloc] initWithString:@"手机上的记账数据将重新从云端获取，若您多个手机使用APP且数据不一致时可重新拉取，请在WIFi下操作。" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]}];
//        SSJStartUpgradeAlertView *alert = [[SSJStartUpgradeAlertView alloc]initWithTitle:@"温馨提示" message:massage cancelButtonTitle:@"取消" sureButtonTitle:@"立即拉取" cancelButtonClickHandler:^(SSJStartUpgradeAlertView * _Nonnull alert) {
//            [alert dismiss];
//        } sureButtonClickHandler:^(SSJStartUpgradeAlertView * _Nonnull alert) {
//            [alert dismiss];
//            
//            if ([SSJNetworkReachabilityManager networkReachabilityStatus] == SSJNetworkReachabilityStatusNotReachable) {
//                [CDAutoHideMessageHUD showMessage:@"请连接网络后重试"];
//                return;
//            }
//            
//            [SSJDataClearHelper clearLocalDataWithSuccess:^{
//                [CDAutoHideMessageHUD showMessage:@"重新拉取数据成功"];
//            } failure:^(NSError *error) {
//                [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
//            }];
//        }];
//        [alert show];
        
        [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"手机上的记账数据将重新从云端获取，若您多个手机使用APP且数据不一致时可重新拉取，请在WIFi下操作。" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:NULL], [SSJAlertViewAction actionWithTitle:@"立即拉取" handler:^(SSJAlertViewAction * _Nonnull action) {
            if ([SSJNetworkReachabilityManager networkReachabilityStatus] == SSJNetworkReachabilityStatusNotReachable) {
                [CDAutoHideMessageHUD showMessage:@"请连接网络后重试"];
                return;
            }
            
            [SSJDataClearHelper clearLocalDataWithSuccess:^{
                [CDAutoHideMessageHUD showMessage:@"重新拉取数据成功"];
            } failure:^(NSError *error) {
                [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
            }];
        }], nil];
    }
    
    
//    //  用户协议与隐私说明
//    if ([title isEqualToString:kTitle4]) {
//        SSJNormalWebViewController *webVc = [SSJNormalWebViewController webViewVCWithURL:[NSURL URLWithString:SSJUserProtocolUrl]];
//        webVc.title = @"用户协议与隐私说明";
//        [self.navigationController pushViewController:webVc animated:YES];
//    }
//    
    //  检查更新
    if ([title isEqualToString:kTitle6]) {
        [[SSJStartChecker sharedInstance] checkWithSuccess:^(BOOL isInReview, SSJAppUpdateType type) {
            if (type == SSJAppUpdateTypeNone) {
                [CDAutoHideMessageHUD showMessage:@"当前已经是最新版本,不需要更新"];
            }
        } failure:^(NSString *message) {
            [CDAutoHideMessageHUD showMessage:message];
        }];
    }
    
    //  关于我们
    if ([title isEqualToString:kTitle5]) {
        SSJAboutusViewController *aboutUsVc = [[SSJAboutusViewController alloc] init];
        [self.navigationController pushViewController:aboutUsVc animated:YES];
    }
    
    //  把APP推荐给好友
    if ([title isEqualToString:kTitle4]) {
        if ([SSJDefaultSource() isEqualToString:@"11501"]) {
            [UMSocialSnsService presentSnsIconSheetView:self
                                                 appKey:SSJDetailSettingForSource(@"UMAppKey")
                                              shareText:@"财务管理第一步，从记录消费生活开始!"
                                             shareImage:[UIImage imageNamed:SSJDetailSettingForSource(@"ShareIcon")]
                                        shareToSnsNames:[NSArray arrayWithObjects:UMShareToQQ,UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,nil]
                                               delegate:self];
        }else{
            [UMSocialSnsService presentSnsIconSheetView:self
                                                 appKey:SSJDetailSettingForSource(@"UMAppKey")
                                              shareText:@"在这里，记录消费生活是件有趣简单的事儿，管家更有窍门。"
                                             shareImage:[UIImage imageNamed:SSJDetailSettingForSource(@"ShareIcon")]
                                        shareToSnsNames:[NSArray arrayWithObjects:UMShareToQQ,UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,nil]
                                               delegate:self];
        }
    }
    
    //数据格式化
    if ([title isEqualToString:kTitle3]) {
        SSJAlertViewAction *comfirmAction = [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction * _Nonnull action) {
            [SSJDataClearHelper clearAllDataWithSuccess:^{
                [CDAutoHideMessageHUD showMessage:@"数据初始化成功"];
            } failure:^(NSError *error) {
                [CDAutoHideMessageHUD showMessage:@"数据初始化失败"];
            }];
        }];
        SSJAlertViewAction *cancelAction = [SSJAlertViewAction actionWithTitle:@"取消" handler:NULL];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:@"云端和本地的数据将被彻底清除且不可恢复，确定要执行此操作？" action:cancelAction,comfirmAction,nil];
    }
    
    
    if ([title isEqualToString:kTitle7]) {
        SSJAlertViewAction *comfirmAction = [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction * _Nonnull action) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = @"youyuwjr";
            [WXApi openWXApp];
        }];
        SSJAlertViewAction *cancelAction = [SSJAlertViewAction actionWithTitle:@"取消" handler:NULL];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"复制微信号成功啦，现在就跳转到微信在搜索栏粘贴，即刻关注我们吧！" action:comfirmAction,cancelAction,nil];
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.titles[section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJMineHomeCell";
    SSJMineHomeTabelviewCell *mineHomeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!mineHomeCell) {
        mineHomeCell = [[SSJMineHomeTabelviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        mineHomeCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle8]) {
        mineHomeCell.customAccessoryType = UITableViewCellAccessoryNone;
        mineHomeCell.cellSubTitle = title;
    }else{
        mineHomeCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        mineHomeCell.cellTitle = title;
        if ([[self.titles ssj_objectAtIndexPath:indexPath] isEqualToString:@"检查更新"]) {
            mineHomeCell.cellDetail = [NSString stringWithFormat:@"v%@",SSJAppVersion()];
        }else if([mineHomeCell.cellTitle isEqualToString:kTitle7]){
            mineHomeCell.cellDetail = @"youyuwjr";
        }
    }
    return mineHomeCell;
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


#pragma mark - Getter
-(SSJWeixinFooter *)weixinFooter{
    if (_weixinFooter == nil) {
        _weixinFooter = [[SSJWeixinFooter alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 150)];
    }
    return _weixinFooter;
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
