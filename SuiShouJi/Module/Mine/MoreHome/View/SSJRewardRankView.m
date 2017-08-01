//
//  SSJRewardRankView.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/31.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJRewardRankView.h"
#import "SSJRewardRankViewCell.h"

#import "SSJRankListItem.h"
#import "SSJRewardRankService.h"

@interface SSJRewardRankView ()<UITableViewDelegate,UITableViewDataSource,SSJBaseNetworkServiceDelegate>

@property (nonatomic, strong) SSJRewardRankService *rankService;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;

/**<#注释#>*/
@property (nonatomic, strong) UIImageView *backgroundView;
@end

#import "SSJRewardRankService.h"

@implementation SSJRewardRankView

- (instancetype)initWithFrame:(CGRect)frame backgroundView:(UIImage *)bgImage {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.backgroundView];
        self.backgroundView.image = bgImage;
        [self addSubview:self.tableView];
        [self updateAppearance];
        [self.rankService requestRankList];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
    self.backgroundView.frame = self.bounds;
}

#pragma mark - Theme
- (void)updateAppearance {
    self.tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
    {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.dataArray ssj_safeObjectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJRewardRankViewCell *cell = [SSJRewardRankViewCell cellWithTableView:tableView];
    cell.cellItem = [self.dataArray ssj_objectAtIndexPath:indexPath];
    
    return cell;
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    self.dataArray = self.rankService.listArray;
    [self.tableView reloadData];
}


#pragma mark - Lazy
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.rowHeight = 80;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView ssj_clearExtendSeparator];
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_tableView setLayoutMargins:UIEdgeInsetsZero];
        }
    }
    return _tableView;
}

- (UIImageView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIImageView alloc] init];
    }
    return _backgroundView;
}

- (SSJRewardRankService *)rankService {
    if (!_rankService) {
        _rankService = [[SSJRewardRankService alloc] initWithDelegate:self];
    }
    return _rankService;
}


@end
