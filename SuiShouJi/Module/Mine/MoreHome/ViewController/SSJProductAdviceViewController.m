//
//  SSJProductAdviceViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2016/12/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJProductAdviceViewController.h"
#import "SSJProductAdviceTableHeaderView.h"
#import "SSJUserItem.h"
#import "SSJUserInfoItem.h"
#import "SSJUserTableManager.h"
#import <YWFeedbackFMWK/YWFeedbackKit.h>
#import "SSJProductAdviceNetWorkService.h"
@interface SSJProductAdviceViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SSJProductAdviceTableHeaderView *productAdviceTableHeaderView;
//@property (nonatomic, strong) YWFeedbackKit *feedbackKit;
/**
 <#注释#>
 */
@property (nonatomic, strong) SSJProductAdviceNetWorkService *adviceService;
@end

@implementation SSJProductAdviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self setUpNav];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //type	int	是	0:查询 1：添加
    [self.adviceService requestAdviceMessageListWithType:0];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableView.frame = CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM);
}

- (void)setUpNav
{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"产品建议";
    titleLabel.font = [UIFont systemFontOfSize:19];
    titleLabel.textColor = [UIColor ssj_colorWithHex:@"333333"];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
      [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:23.0f]}];
    UIButton *navRightButton = [[UIButton alloc] init];
    [navRightButton setTitle:@"在线客服" forState:UIControlStateNormal];
    navRightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [navRightButton setTitleColor:[UIColor ssj_colorWithHex:@"eb4a64"] forState:UIControlStateNormal];
    [navRightButton addTarget:self action:@selector(navRightButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [navRightButton sizeToFit];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
}



#pragma mark -Action
- (void)navRightButtonClicked
{
    SSJUserItem *userItem = [SSJUserTableManager queryUserItemForID:SSJUSERID()];
    NSDictionary* clientCustomizedAttrs = @{@"userid": userItem.userId ?: @"",
                                            @"openid": userItem.openId ?: @"",
                                            @"nickname": userItem.realName ?: @"",
                                            @"tel": userItem.mobileNo ?: @"",
                                            @"登录方式": userItem.loginType ?: @"",
                                            @"注册状态": userItem.registerState ?: @"",
                                            @"应用名称": SSJAppName(),
                                            @"应用版本号": SSJAppVersion(),
                                            @"手机型号" : SSJPhoneModel()
                                            };
    [MQManager setClientInfo:clientCustomizedAttrs completion:^(BOOL success , NSError *error) {
        
    }];
    MQChatViewManager *chatViewManager = [[MQChatViewManager alloc] init];
    [chatViewManager pushMQChatViewControllerInViewController:self];
}

#pragma mark - SSJBaseNetworkService
-(void)serverDidFinished:(SSJBaseNetworkService *)service
{
//    self.adviceService.messageItem
}


#pragma mark -Lazy
#pragma mark -Getter
- (SSJProductAdviceNetWorkService *)adviceService{
    if (!_adviceService) {
        _adviceService = [[SSJProductAdviceNetWorkService alloc]initWithDelegate:self];
        _adviceService.httpMethod = SSJBaseNetworkServiceHttpMethodPOST;
    }
    return _adviceService;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (SSJProductAdviceTableHeaderView *)productAdviceTableHeaderView
{
    if (!_productAdviceTableHeaderView) {
        _productAdviceTableHeaderView = [[SSJProductAdviceTableHeaderView alloc] init];
    }
    return _productAdviceTableHeaderView;
}

#pragma mark -UITableDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return nil;
   static NSString *cellId = @"cellForRowAtIndexPath";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.productAdviceTableHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return self.productAdviceTableHeaderView.headerHeight;
}

@end
