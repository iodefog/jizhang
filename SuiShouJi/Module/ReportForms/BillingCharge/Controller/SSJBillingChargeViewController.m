//
//  SSJBillingChargeViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBillingChargeViewController.h"
#import "SSJBillingChargeCell.h"

static NSString *const kBillingChargeCellID = @"kBillingChargeCellID";

@interface SSJBillingChargeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *datas;

@end

@implementation SSJBillingChargeViewController

#pragma mark - Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.navigationItem.title = @"流水";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[SSJBillingChargeCell class] forCellReuseIdentifier:kBillingChargeCellID];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.datas count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *sectionInfo = [self.datas ssj_safeObjectAtIndex:(NSUInteger)section];
    return [sectionInfo count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBillingChargeCell *cell = [tableView dequeueReusableCellWithIdentifier:kBillingChargeCellID forIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
        _tableView.separatorColor = SSJ_DEFAULT_SEPARATOR_COLOR;
        _tableView.rowHeight = 55;
        _tableView.sectionHeaderHeight = 40;
//        [_tableView ssj_clearExtendSeparator];
        [_tableView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
    }
    return _tableView;
}

@end
