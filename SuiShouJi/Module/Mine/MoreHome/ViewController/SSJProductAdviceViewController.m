//
//  SSJProductAdviceViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2016/12/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJProductAdviceViewController.h"
#import "SSJProductAdviceTableHeaderView.h"
#import "SSJMoreProductAdviceTableViewCell.h"
#import "TPKeyboardAvoidingTableView.h"

#import "SSJUserTableManager.h"

#import "SSJAdviceItem.h"
#import "SSJChatMessageItem.h"
#import "SSJUserItem.h"
#import "SSJUserInfoItem.h"

#import "SSJProductAdviceNetWorkService.h"

#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentApiInterface.h>

@interface SSJProductAdviceViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;
@property (nonatomic, strong) SSJProductAdviceTableHeaderView *productAdviceTableHeaderView;

@property (nonatomic, strong) SSJProductAdviceNetWorkService *service;

/**qq*/
@property (nonatomic, copy) NSString *qqNumStr;

/**qqKey*/
@property (nonatomic, copy) NSString *qqKeyStr;

@end

@implementation SSJProductAdviceViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
        self.appliesTheme = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"反馈意见";
    [self.view addSubview:self.tableView];
    self.backgroundView.hidden = YES;
    self.view.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
    [self.service requestQQDetail];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableView.frame = CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM + SSJ_TABBAR_HEIGHT);
}

#pragma mark -Action
- (void)navRightButtonClicked
{
    [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
        NSDictionary* clientCustomizedAttrs = @{@"userid": userItem.userId ?: @"",
                                                @"openid": userItem.openId ?: @"",
                                                @"nickname": userItem.nickName ?: @"",
                                                @"tel": userItem.mobileNo ?: @"",
                                                @"登录方式": userItem.loginType ?: @"",
                                                @"注册状态": userItem.registerState ?: @"",
                                                @"应用名称": SSJAppName(),
                                                @"应用版本号": SSJAppVersion(),
                                                @"手机型号" : SSJPhoneModel()
                                                };
        [MQManager setClientInfo:clientCustomizedAttrs completion:NULL];
        MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
        [chatViewManager pushMQChatViewControllerInViewController:self];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
}




- (TPKeyboardAvoidingTableView *)tableView
{
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 15, 0);
        [_tableView ssj_clearExtendSeparator];
    }
    return _tableView;
}

- (SSJProductAdviceTableHeaderView *)productAdviceTableHeaderView
{
    if (!_productAdviceTableHeaderView) {
        _productAdviceTableHeaderView = [[SSJProductAdviceTableHeaderView alloc] init];
        _productAdviceTableHeaderView.defaultAdviceType = self.defaultAdviceType;
    }
    return _productAdviceTableHeaderView;
}

#pragma mark -UITableDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"SSJProductAdviceViewControllerId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        cell.textLabel.font = cell.detailTextLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        cell.textLabel.textColor = cell.detailTextLabel.textColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].mainColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor whiteColor];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"QQ群";
        cell.detailTextLabel.text = self.qqNumStr;
    } else if(indexPath.row == 1) {
        cell.textLabel.text = @"在线客服";
        cell.detailTextLabel.text = @"";
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.productAdviceTableHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return self.productAdviceTableHeaderView.headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 417;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {//qq
        //打开加群界面
        if (![self joinGroup:self.qqNumStr key:self.qqKeyStr]) {
            [CDAutoHideMessageHUD showMessage:@"未安装QQ哦"];
        }
    } else if(indexPath.row == 1) {//在线客服
        [self navRightButtonClicked];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)joinGroup:(NSString *)groupUin key:(NSString *)key{
    NSString *urlStr = [NSString stringWithFormat:@"mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%@&key=%@&card_type=group&source=external", groupUin,key];
    NSURL *url = [NSURL URLWithString:urlStr];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    if ([service.returnCode isEqualToString:@"1"]) {
        self.qqNumStr = [[service.rootElement objectForKey:@"results"] objectForKey:@"qq_group"];
        self.qqKeyStr = [[service.rootElement objectForKey:@"results"] objectForKey:@"group_key"];
        [self.tableView reloadData];
    }
}


#pragma mark - Lazy
- (SSJProductAdviceNetWorkService *)service {
    if (!_service) {
        _service = [[SSJProductAdviceNetWorkService alloc] initWithDelegate:self];
    }
    return _service;
}

@end
