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
#import "SSJDataSynchronizer.h"
#import "SSJUserTableManager.h"
#import "SSJUserDefaultDataCreater.h"
#import "SSJSyncSettingViewController.h"
#import "SSJNormalWebViewController.h"
#import "SSJStartChecker.h"

static NSString *const kTitle1 = @"同步设置";
static NSString *const kTitle2 = @"用户协议与隐私说明";
static NSString *const kTitle3 = @"检查更新";
static NSString *const kTitle4 = @"关于我们";


@interface SSJSettingViewController ()
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic,strong) UIView *loggedFooterView;
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
        self.titles = @[@[kTitle1], @[kTitle2] , @[kTitle4]];
    } else {
        self.titles = @[@[kTitle1], @[kTitle2],@[kTitle3],@[kTitle4]];
    }
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (SSJIsUserLogined() && section == [self.tableView numberOfSections] - 1) {
        return self.loggedFooterView;
    }
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectZero];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (SSJIsUserLogined() && section == [self.tableView numberOfSections] - 1) {
        return 80;
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
    
    //  用户协议与隐私说明
    if ([title isEqualToString:kTitle2]) {
        SSJNormalWebViewController *webVc = [SSJNormalWebViewController webViewVCWithURL:[NSURL URLWithString:@"http://1.9188.com/h5/about_shq/protocol.html"]];
        webVc.title = @"用户协议与隐私说明";
        [self.navigationController pushViewController:webVc animated:YES];
    }
    
    //  检查更新
    if ([title isEqualToString:kTitle3]) {
        [[SSJStartChecker sharedInstance] checkWithSuccess:^(BOOL isInReview, SSJAppUpdateType type) {
            if (type == SSJAppUpdateTypeNone) {
                [CDAutoHideMessageHUD showMessage:@"当前已经是最新版本,不需要更新"];
            }
        } failure:^(NSString *message) {
            [CDAutoHideMessageHUD showMessage:message];
        }];
    }
    
    //  关于我们
    if ([title isEqualToString:kTitle4]) {
        SSJNormalWebViewController *webVc = [SSJNormalWebViewController webViewVCWithURL:[NSURL URLWithString:@"http://1.9188.com/h5/about_shq/about.html"]];
        webVc.title = @"关于我们";
        [self.navigationController pushViewController:webVc animated:YES];
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
        mineHomeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    mineHomeCell.cellTitle = [self.titles ssj_objectAtIndexPath:indexPath];
    if ([[self.titles ssj_objectAtIndexPath:indexPath] isEqualToString:@"检查更新"]) {
        mineHomeCell.cellDetail = SSJAppVersion();
    }
    
    return mineHomeCell;
}

#pragma mark - Getter
-(UIView *)loggedFooterView{
    if (_loggedFooterView == nil) {
        _loggedFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
        UIButton *quitLogButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _loggedFooterView.width - 20, 40)];
        [quitLogButton setTitle:@"退出登录" forState:UIControlStateNormal];
        quitLogButton.layer.cornerRadius = 3.f;
        quitLogButton.layer.masksToBounds = YES;
        [quitLogButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"47cfbe"] forState:UIControlStateNormal];
        [quitLogButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [quitLogButton addTarget:self action:@selector(quitLogButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        quitLogButton.center = CGPointMake(_loggedFooterView.width / 2, _loggedFooterView.height / 2);
        [_loggedFooterView addSubview:quitLogButton];
    }
    return _loggedFooterView;
}

-(void)quitLogButtonClicked:(id)sender {
    //  退出登陆后强制同步一次
    [[SSJDataSynchronizer shareInstance] startSyncWithSuccess:NULL failure:NULL];
    SSJClearLoginInfo();
    [SSJUserTableManager reloadUserIdWithError:nil];
    [SSJUserDefaultDataCreater asyncCreateAllDefaultDataWithSuccess:NULL failure:NULL];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:SSJLastSelectFundItemKey];
    [self.tableView reloadData];
//    self.header.headPotraitImage.image = [UIImage imageNamed:@"defualt_portrait"];
//    self.header.nicknameLabel.text = @"待君登录";
//    [self.tableView reloadData];
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
