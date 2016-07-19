//
//  SSJBookkeepingTreeHelpViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/4/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookkeepingTreeHelpViewController.h"
#import "SSJBookkeepingTreeRuleDescView.h"
#import "SSJBookkeepingTreeHelpCell.h"
#import "SSJBookkeepingTreeHelpCellItem.h"

static NSString *const kHelpCellId = @"kHelpCellId";

@interface SSJBookkeepingTreeHelpViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *titleView;

@property (nonatomic, strong) UIView *sectionView;

@property (nonatomic, strong) SSJBookkeepingTreeRuleDescView *ruleDescView;

@property (nonatomic, strong) NSArray *items;

@end

@implementation SSJBookkeepingTreeHelpViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"帮助";
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.appliesTheme = NO;
        self.statisticsTitle = @"记账树帮助页面";
        [self organiseItems];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.sectionHeaderHeight = self.sectionView.height;
    self.tableView.tableHeaderView = self.titleView;
    self.tableView.tableFooterView = self.ruleDescView;
    self.tableView.rowHeight = 62;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBookkeepingTreeHelpCell *cell = [tableView dequeueReusableCellWithIdentifier:kHelpCellId forIndexPath:indexPath];
    cell.cellItem = [_items ssj_safeObjectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.sectionView;
}

- (void)organiseItems {
    _items = @[[SSJBookkeepingTreeHelpCellItem itemWithTreeLevel:SSJBookkeepingTreeLevelSeed],
               [SSJBookkeepingTreeHelpCellItem itemWithTreeLevel:SSJBookkeepingTreeLevelSapling],
               [SSJBookkeepingTreeHelpCellItem itemWithTreeLevel:SSJBookkeepingTreeLevelSmallTree],
               [SSJBookkeepingTreeHelpCellItem itemWithTreeLevel:SSJBookkeepingTreeLevelStrongTree],
               [SSJBookkeepingTreeHelpCellItem itemWithTreeLevel:SSJBookkeepingTreeLevelBigTree],
               [SSJBookkeepingTreeHelpCellItem itemWithTreeLevel:SSJBookkeepingTreeLevelSilveryTree],
               [SSJBookkeepingTreeHelpCellItem itemWithTreeLevel:SSJBookkeepingTreeLevelGoldTree],
               [SSJBookkeepingTreeHelpCellItem itemWithTreeLevel:SSJBookkeepingTreeLevelDiamondTree],
               [SSJBookkeepingTreeHelpCellItem itemWithTreeLevel:SSJBookkeepingTreeLevelCrownTree]];
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
        _tableView.separatorColor = SSJ_DEFAULT_SEPARATOR_COLOR;
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView setTableFooterView:[[UIView alloc] init]];
        [_tableView registerClass:[SSJBookkeepingTreeHelpCell class] forCellReuseIdentifier:kHelpCellId];
    }
    return _tableView;
}

- (UIView *)titleView {
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];
        [_titleView ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
        [_titleView ssj_setBorderStyle:(SSJBorderStyleTop)];
        [_titleView ssj_setBorderWidth:1];
        
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.textColor = [UIColor grayColor];
        titleLab.font = [UIFont systemFontOfSize:14];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.text = @"种子的茁壮成长之路";
        [titleLab sizeToFit];
        titleLab.center = CGPointMake(_titleView.width * 0.5, _titleView.height * 0.5);
        [_titleView addSubview:titleLab];
    }
    return _titleView;
}

- (UIView *)sectionView {
    if (!_sectionView) {
        _sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 34)];
        _sectionView.backgroundColor = [UIColor whiteColor];
        [_sectionView ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
        [_sectionView ssj_setBorderStyle:(SSJBorderStyleTop | SSJBorderStyleBottom)];
        [_sectionView ssj_setBorderWidth:1];
        
        UILabel *levelLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _sectionView.width * 0.5, _sectionView.height)];
        levelLab.backgroundColor = [UIColor clearColor];
        levelLab.textColor = [UIColor grayColor];
        levelLab.font = [UIFont systemFontOfSize:12];
        levelLab.textAlignment = NSTextAlignmentCenter;
        levelLab.text = @"树的等级";
        
        UILabel *daysLab = [[UILabel alloc] initWithFrame:CGRectMake(_sectionView.width * 0.5, 0, _sectionView.width * 0.5, _sectionView.height)];
        daysLab.backgroundColor = [UIColor clearColor];
        daysLab.textColor = [UIColor grayColor];
        daysLab.font = [UIFont systemFontOfSize:12];
        daysLab.textAlignment = NSTextAlignmentCenter;
        daysLab.text = @"累计登录天数";
        
        [_sectionView addSubview:levelLab];
        [_sectionView addSubview:daysLab];
    }
    return _sectionView;
}

- (SSJBookkeepingTreeRuleDescView *)ruleDescView {
    if (!_ruleDescView) {
        _ruleDescView = [[SSJBookkeepingTreeRuleDescView alloc] initWithWidth:self.view.width];
        [_ruleDescView ssj_setBorderColor:SSJ_DEFAULT_SEPARATOR_COLOR];
        [_ruleDescView ssj_setBorderStyle:(SSJBorderStyleTop | SSJBorderStyleBottom)];
        [_ruleDescView ssj_setBorderWidth:1];
    }
    return _ruleDescView;
}

@end
