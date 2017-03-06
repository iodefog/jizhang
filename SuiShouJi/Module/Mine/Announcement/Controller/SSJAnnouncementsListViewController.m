//
//  SSJAnnouncementsListViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/3/2.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJAnnouncementsListViewController.h"
#import "SSJAnnouncementDetailCell.h"
#import "SSJAnnoucementService.h"
#import "SSJAnnouncementWebViewController.h"

static NSString *const kAnnouncementCellIdentifier = @"kAnnouncementCellIdentifier";


@interface SSJAnnouncementsListViewController ()

@property(nonatomic, strong) SSJAnnoucementService *service;

@end

@implementation SSJAnnouncementsListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"消息";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[SSJAnnouncementDetailCell class] forCellReuseIdentifier:kAnnouncementCellIdentifier];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self startPullRefresh];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self startLoadMore];
    }];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.items.count > 0) {
        SSJAnnoucementItem *item = [self.items firstObject];
        [[NSUserDefaults standardUserDefaults] setObject:item.announcementId forKey:kLastAnnoucementIdKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectZero];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SSJAnnoucementItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    SSJAnnouncementWebViewController *webVc = [SSJAnnouncementWebViewController webViewVCWithURL:[NSURL URLWithString:item.announcementUrl]];
    webVc.item = item;
    [self.navigationController pushViewController:webVc animated:YES];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJAnnouncementDetailCell *announcementCell  = [tableView dequeueReusableCellWithIdentifier:kAnnouncementCellIdentifier];
    [announcementCell setCellItem:[self.items objectAtIndex:indexPath.row]];
    return announcementCell;
}

#pragma mark - SSJBaseNetworkService
-(void)serverDidFinished:(SSJBaseNetworkService *)service {
    [self.tableView.mj_header endRefreshing];
    if ([service.returnCode isEqualToString:@"1"]) {
        self.items = self.service.annoucements;
        [self.tableView reloadData];
    }
}

- (void)server:(SSJBaseNetworkService *)service didFailLoadWithError:(NSError *)error {
    [self.tableView.mj_header endRefreshing];
}

#pragma mark - Getter
- (SSJAnnoucementService *)service {
    if (!_service) {
        _service = [[SSJAnnoucementService alloc] initWithDelegate:self];
    }
    return _service;
}

#pragma mark - Private
- (void)startPullRefresh {
    [self.service requestAnnoucementsWithPage:1];
}

- (void)startLoadMore {
    
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
