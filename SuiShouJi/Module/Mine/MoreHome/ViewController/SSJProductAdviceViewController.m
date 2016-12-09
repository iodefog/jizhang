//
//  SSJProductAdviceViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2016/12/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJProductAdviceViewController.h"
#import "SSJProductAdviceTableHeaderView.h"
@interface SSJProductAdviceViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SSJProductAdviceTableHeaderView *productAdviceTableHeaderView;
@end

@implementation SSJProductAdviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"产品建议";
    [self.view addSubview:self.tableView];
//    self.tableView.tableHeaderView = self.productAdviceTableHeaderView;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableView.frame = CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM);
//    SSJPRINT(@"%@===%@",NSStringFromCGRect(self.view.frame),NSStringFromCGRect(self.tableView.frame));
}

#pragma mark -Lazy
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
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
