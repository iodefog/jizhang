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
#import "SSJDataSynchronizer.h"
#import "SSJLocalNotificationHelper.h"
#import "SSJLoginViewController.h"
#import "SSJMotionPasswordSettingViewController.h"
#import "SSJLoginViewController+SSJCategory.h"
#import "SSJGlobalServiceManager.h"
#import "ZipArchive.h"

static NSString *const kTitle0 = @"手势密码";
static NSString *const kTitle1 = @"自动同步设置";
static NSString *const kTitle2 = @"数据重新拉取";
static NSString *const kTitle3 = @"数据格式化";
static NSString *const kTitle5 = @"检查更新";
static NSString *const kTitle6 = @"关于我们";
static NSString *const kTitle7 = @"微信公众号";
static NSString *const kTitle8 = @"点击上方微信号复制，接着去微信查找即可";
static NSString *const kTitle9 = @"上传日志";


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
            self.titles = @[@[kTitle0,kTitle1, kTitle2 , kTitle3 , kTitle9] ,@[kTitle6,kTitle7,kTitle8]];
        }else{
            self.titles = @[@[kTitle0,kTitle1, kTitle2 , kTitle3 , kTitle9], @[kTitle6]];
        }
    } else {
        if ([WXApi isWXAppInstalled]) {
            self.titles = @[@[kTitle0,kTitle1, kTitle2 , kTitle3 , kTitle9] ,@[kTitle5,kTitle6,kTitle7,kTitle8]];
        }else{
            self.titles = @[@[kTitle0, kTitle1, kTitle2 , kTitle3 , kTitle9] ,@[kTitle5,kTitle6]];
        }
    }
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kTitle8]) {
        return 35;
    }
    if ([title isEqualToString:kTitle7]) {
        return 33;
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
    if ([title isEqualToString:kTitle0]) {
        if (!SSJIsUserLogined()) {
            [self login];
            return;
        }
        SSJMotionPasswordSettingViewController *motionPwdSettingVC = [[SSJMotionPasswordSettingViewController alloc] initWithTableViewStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:motionPwdSettingVC animated:YES];
        return;
    }
    
    //  同步设置
    if ([title isEqualToString:kTitle1]) {
        SSJSyncSettingViewController *syncSettingVC = [[SSJSyncSettingViewController alloc]init];
        [self.navigationController pushViewController:syncSettingVC animated:YES];
        return;
    }
    
    //  重新拉取
    if ([title isEqualToString:kTitle2]) {
        
        if (SSJIsUserLogined()) {
            [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"手机上的记账数据将重新从云端获取，若您多个手机使用APP且数据不一致时可重新拉取，请在WIFi下操作。" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:NULL], [SSJAlertViewAction actionWithTitle:@"立即拉取" handler:^(SSJAlertViewAction * _Nonnull action) {
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
        } else {
            __weak typeof(self) wself = self;
            [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"亲，登录后重新拉取数据哦" action:[SSJAlertViewAction actionWithTitle:@"暂不拉取" handler:NULL], [SSJAlertViewAction actionWithTitle:@"去登录" handler:^(SSJAlertViewAction * _Nonnull action) {
                SSJLoginViewController *loginVc = [[SSJLoginViewController alloc] init];
                loginVc.backController = wself;
                [self.navigationController pushViewController:loginVc animated:YES];
            }], nil];
        }
    }
    
    
//    //  用户协议与隐私说明
//    if ([title isEqualToString:kTitle4]) {
//        SSJNormalWebViewController *webVc = [SSJNormalWebViewController webViewVCWithURL:[NSURL URLWithString:SSJUserProtocolUrl]];
//        webVc.title = @"用户协议与隐私说明";
//        [self.navigationController pushViewController:webVc animated:YES];
//    }
//
    
    
    //  检查更新
    if ([title isEqualToString:kTitle5]) {
        [[SSJStartChecker sharedInstance] checkWithSuccess:^(BOOL isInReview, SSJAppUpdateType type) {
            if (type == SSJAppUpdateTypeNone) {
                [CDAutoHideMessageHUD showMessage:@"当前已经是最新版本,不需要更新"];
            }
        } failure:^(NSString *message) {
            [CDAutoHideMessageHUD showMessage:message];
        }];
    }
    
    //  关于我们
    if ([title isEqualToString:kTitle6]) {
        SSJAboutusViewController *aboutUsVc = [[SSJAboutusViewController alloc] init];
        [self.navigationController pushViewController:aboutUsVc animated:YES];
    }
    
     
    //数据格式化
    if ([title isEqualToString:kTitle3]) {
        SSJAlertViewAction *comfirmAction = [SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction * _Nonnull action) {
            [SSJDataClearHelper clearAllDataWithSuccess:^{
                [CDAutoHideMessageHUD showMessage:@"数据初始化成功"];
                if (SSJIsUserLogined()) {
                    [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:NULL failure:NULL];
                }
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
            pasteboard.string = @"youyujz";
            [WXApi openWXApp];
        }];
        SSJAlertViewAction *cancelAction = [SSJAlertViewAction actionWithTitle:@"取消" handler:NULL];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"复制微信号成功啦，现在就跳转到微信在搜索栏粘贴，即刻关注我们吧！" action:cancelAction,comfirmAction,nil];
    }
    
    if ([title isEqualToString:kTitle9]) {
        @weakify(self);
        [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"上传客户端错误日志，仅在您数据丢失或数据对账错误的情况下需手动点击上传，上传前可先联系用户QQ群552563622" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:NULL], [SSJAlertViewAction actionWithTitle:@"立即拉取" handler:^(SSJAlertViewAction * _Nonnull action) {
            @strongify(self);
            if ([SSJNetworkReachabilityManager networkReachabilityStatus] == SSJNetworkReachabilityStatusNotReachable) {
                [CDAutoHideMessageHUD showMessage:@"请连接网络后重试"];
                return;
            }
            NSError *tError = nil;
            NSData *zipData = [self zipDatabaseWithError:&tError];
            
            [self uploadData:zipData BaseWithcompletionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (!error) {
                    [CDAutoHideMessageHUD showMessage:@"上传成功"];
                }
            }];

        }], nil];
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
    
    if ([title isEqualToString:kTitle7]) {
        mineHomeCell.separatorInset = UIEdgeInsetsMake(0, 0, 0, MAXFLOAT);
    } else {
        mineHomeCell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    }
    if ([title isEqualToString:kTitle8]) {
        mineHomeCell.customAccessoryType = UITableViewCellAccessoryNone;
        mineHomeCell.cellSubTitle = title;
    } else {
        mineHomeCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        mineHomeCell.cellTitle = title;
        if ([[self.titles ssj_objectAtIndexPath:indexPath] isEqualToString:@"检查更新"]) {
            mineHomeCell.cellDetail = [NSString stringWithFormat:@"v%@",SSJAppVersion()];
        } else if([mineHomeCell.cellTitle isEqualToString:kTitle7]) {
            mineHomeCell.cellDetail = @"youyujz";
        }

    }
    return mineHomeCell;
}

#pragma mark - Getter
-(SSJWeixinFooter *)weixinFooter{
    if (_weixinFooter == nil) {
        _weixinFooter = [[SSJWeixinFooter alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 150)];
    }
    return _weixinFooter;
}

- (void)uploadData:(NSData *)data BaseWithcompletionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
#ifdef DEBUG
    [data writeToFile:@"/Users/ricky/Desktop/db_error.zip" atomically:YES];
#endif
    
    SSJGlobalServiceManager *sessionManager = [SSJGlobalServiceManager standardManager];
    
    NSError *tError = nil;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:SSJURLWithAPI(@"/admin/applog.go") parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSString *fileName = [NSString stringWithFormat:@"ios_error_db_%lld.zip", SSJMilliTimestamp()];
        [formData appendPartWithFileData:data name:@"zip" fileName:fileName mimeType:@"application/zip"];
    } error:&tError];
    
    //  封装参数，传入请求头
    NSString *userId = SSJUSERID();
    NSString *version = [UIDevice currentDevice].identifierForVendor.UUIDString;
    NSString *phoneOs = [NSString stringWithFormat:@"%f",SSJSystemVersion()];
    NSString *model = SSJPhoneModel();
    NSString *date = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSDictionary *parameters = @{@"cuserId":userId,
                                 @"releaseversion":version,
                                 @"cmodel":model,
                                 @"cphoneos":phoneOs,
                                 @"cdate":date,
                                 @"itype":@"2"};
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    
    request.timeoutInterval = 60;
    
    //  开始上传
    
    NSURLSessionUploadTask *task = [sessionManager uploadTaskWithStreamedRequest:request progress:nil completionHandler:completionHandler];
    
    [task resume];
}

//  将data进行zip压缩
- (NSData *)zipDatabaseWithError:(NSError **)error {
    NSString *zipPath = [SSJDocumentPath() stringByAppendingPathComponent:@"db_error.zip"];
    if (![SSZipArchive createZipFileAtPath:zipPath withFilesAtPaths:@[SSJSQLitePath()]]) {
        if (error) {
            *error = [NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"压缩文件发生错误"}];
        }
        return nil;
    }
    
    return [NSData dataWithContentsOfFile:zipPath];
}


#pragma mark - Action
- (void)login {
    SSJLoginViewController *loginVc = [[SSJLoginViewController alloc] init];
    loginVc.backController = self;
    [self.navigationController pushViewController:loginVc animated:YES];
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
