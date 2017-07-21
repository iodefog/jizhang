//
//  SSJWishIngViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishIngViewController.h"
#import "SSJWishProgressViewController.h"

#import "SSJWishListTableViewCell.h"

#import "SSJBudgetNodataRemindView.h"

#import "SSJWishHelper.h"

#import "SSJWishModel.h"

@interface SSJWishIngViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray <SSJWishModel *> *dataArray;

@property (nonatomic, strong) SSJBudgetNodataRemindView *noDataRemindView;

@end

@implementation SSJWishIngViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.noDataRemindView];
    [self updateViewConstraints];
    [self updateAppearance];
//    [RACObserve(self, dataArray.count) subscribeNext:^(id x) {
    
//        NSInteger count = x.count;
//        if (count > 0) {
            self.noDataRemindView.hidden = YES;
//        } else {
//            self.noDataRemindView.hidden = NO;
//        }
//    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    @weakify(self);
    [SSJWishHelper queryIngWishWithState:SSJWishStateNormalIng success:^(NSMutableArray<SSJWishModel *> *resultArr) {
        @strongify(self);
        self.dataArray = resultArr;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

- (void)updateViewConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(44);
    }];
    
    [self.noDataRemindView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.tableView);
    }];
    [super updateViewConstraints];
}

#pragma mark - Theme
- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
        self.view.backgroundColor =[UIColor whiteColor];
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SSJWishModel *model = [self.dataArray ssj_safeObjectAtIndex:indexPath.row];
    SSJWishProgressViewController *wishProgressVC = [[SSJWishProgressViewController alloc] init];
    wishProgressVC.wishId = model.wishId;
    
    [SSJVisibalController().navigationController pushViewController:wishProgressVC animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJWishListTableViewCell *cell = [SSJWishListTableViewCell cellWithTableView:tableView];
    cell.cellItem = [self.dataArray ssj_safeObjectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - Lazy
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.estimatedRowHeight = 170;
        _tableView.rowHeight = UITableViewAutomaticDimension;
    }
    return _tableView;
}

- (NSMutableArray<SSJWishModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (SSJBudgetNodataRemindView *)noDataRemindView {
    if (!_noDataRemindView) {
        _noDataRemindView = [[SSJBudgetNodataRemindView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 260)];
        _noDataRemindView.image = @"wish_list_has_no_finish";
        _noDataRemindView.title = @"暂无已完成的心愿";
        _noDataRemindView.subTitle = @"不如和一百万人一起\n为心愿存钱\n一步步实现自己的小心愿吧";
    }
    return _noDataRemindView;
}
@end
