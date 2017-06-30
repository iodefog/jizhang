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
#import "SSJProductAdviceNetWorkService.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJMoreProductAdviceTableViewCell.h"
#import "SSJAdviceItem.h"
#import "SSJChatMessageItem.h"

@interface SSJProductAdviceViewController ()<UITableViewDelegate,UITableViewDataSource,SSJProductAdviceTableHeaderViewDelegate>
@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;
@property (nonatomic, strong) SSJProductAdviceTableHeaderView *productAdviceTableHeaderView;
/**
 <#注释#>
 */
@property (nonatomic, strong) SSJProductAdviceNetWorkService *adviceService;
/**
 请求类型
 */
@property (nonatomic, assign) NSInteger requestType;
@end

@implementation SSJProductAdviceViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appliesTheme = NO;
    [self.view addSubview:self.tableView];
    [self setUpNav];
    self.backgroundView.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    //type	int	是	0:查询 1：添加
    self.requestType = 0;
    [self.adviceService requestAdviceMessageListWithType:0 message:@"" additionalMessage:@""];
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

- (void)setUpNav
{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"产品建议";
    titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
    titleLabel.textColor = [UIColor ssj_colorWithHex:@"333333"];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
      [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2]}];
    UIButton *navRightButton = [[UIButton alloc] init];
    [navRightButton setTitle:@"在线客服" forState:UIControlStateNormal];
    navRightButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    [navRightButton setTitleColor:[UIColor ssj_colorWithHex:@"eb4a64"] forState:UIControlStateNormal];
    [navRightButton addTarget:self action:@selector(navRightButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [navRightButton sizeToFit];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightButton];
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

#pragma mark - SSJBaseNetworkService
-(void)serverDidFinished:(SSJBaseNetworkService *)service
{
    if ([service.returnCode isEqualToString:@"1"]) {
//        type	int	是	0:查询 1：添加
        if (self.requestType == 1) {
            //清空内容
            [self.productAdviceTableHeaderView clearAdviceContext];
            //提示语
             [CDAutoHideMessageHUD showMessage:service.desc];
            //刷新数据
            self.requestType = 0;
            [self.adviceService requestAdviceMessageListWithType:0 message:@"" additionalMessage:@""];
        }else if (self.requestType == 0){
            [self sortedArray];
        }
    }
}
/*
 数组排序等处理
 */
- (void)sortedArray
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    //处理数据
    //     self.chartMessageArray = self.adviceService.adviceItems.messageItems;
    NSMutableArray *tempArr = [NSMutableArray array];
    for (SSJChatMessageItem *item in self.adviceService.adviceItems.messageItems) {
        if (item.creplyContent.length) {//如果回复内容存在
            SSJChatMessageItem *chartMessageItem = [[SSJChatMessageItem alloc] init];
            chartMessageItem.isSystem = YES;
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            NSDate *tempDate = [formatter dateFromString:item.creplyDate];
            chartMessageItem.creplyDate = item.creplyDate;
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSString *string = [formatter stringFromDate:tempDate];
            chartMessageItem.dateStr = string;
            chartMessageItem.date = tempDate;
            chartMessageItem.content = item.creplyContent;
            [tempArr addObject:chartMessageItem];
        }
        if (item.cContent.length) {//如果建议内容存在
            SSJChatMessageItem *chartMessageItem = [[SSJChatMessageItem alloc] init];
            chartMessageItem.isSystem = NO;
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            NSDate *tempDate = [formatter dateFromString:item.caddDate];
            chartMessageItem.caddDate = item.caddDate;
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSString *string = [formatter stringFromDate:tempDate];
            chartMessageItem.dateStr = string;
            chartMessageItem.date = tempDate;
            chartMessageItem.content = item.cContent;
            [tempArr addObject:chartMessageItem];
        }
    }
    //对数组按照时间进行排序
    NSArray *arr = [tempArr sortedArrayUsingComparator:^NSComparisonResult(SSJChatMessageItem * _Nonnull obj1, SSJChatMessageItem *  _Nonnull obj2) {
        NSDate *date1 = obj1.date;
        NSDate *date2 = obj2.date;
        NSComparisonResult result = [date1 compare:date2];
        return result == NSOrderedAscending;
    }];
    
    //遍历排序后的数组判断是否显示时间同一天的不显示，否则显示
    SSJChatMessageItem *lastItem;
    BOOL isStop = NO;
    for (SSJChatMessageItem *item in arr) {
        //得到最新一条回复的时间并存储到数据库中
        if (item.isSystem == YES && isStop == NO) {//是系统
            SSJUserItem *userItem = [[SSJUserItem alloc] init];
            userItem.userId = SSJUSERID();
            userItem.adviceTime = item.creplyDate;
            //存储
            [SSJUserTableManager saveUserItem:userItem success:NULL failure:NULL];
            isStop = YES;
        }
        if ([lastItem.date isSameDay:item.date]) {
            item.isHiddenTime = YES;
        }
        lastItem = item;
    }
//    self.chartMessageArray = [NSMutableArray arrayWithArray:arr];
    [self.tableView reloadData];
    
    
    
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

- (TPKeyboardAvoidingTableView *)tableView
{
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 15, 0);
    }
    return _tableView;
}

- (SSJProductAdviceTableHeaderView *)productAdviceTableHeaderView
{
    if (!_productAdviceTableHeaderView) {
        _productAdviceTableHeaderView = [[SSJProductAdviceTableHeaderView alloc] init];
        _productAdviceTableHeaderView.delegate = self;
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
   SSJMoreProductAdviceTableViewCell *cell =  [SSJMoreProductAdviceTableViewCell cellWithTableView:tableView];
//    cell.message = [self.chartMessageArray ssj_safeObjectAtIndex:indexPath.row];
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
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 436;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark -SSJProductAdviceTableHeaderViewDelegate
- (void)submitAdviceButtonClickedWithMessage:(NSString *)messageStr additionalMessage:(NSString *)addMessage
{
    self.requestType = 1;
    [self.adviceService requestAdviceMessageListWithType:1 message:messageStr additionalMessage:addMessage];//添加
    
}

@end
