//
//  SSJMemberManagerViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/7/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMemberManagerViewController.h"
#import "SSJChargeMemberItem.h"
#import "SSJBaseTableViewCell.h"
#import "SSJDatabaseQueue.h"
#import "SSJNewMemberViewController.h"
#import "SSJMemberTableViewCell.h"
#import "SSJDataSynchronizer.h"

static NSString *const kMemberTableViewCellIdentifier = @"kMemberTableViewCellIdentifier";

@interface SSJMemberManagerViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIButton *editeButton;
@end

@implementation SSJMemberManagerViewController
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
//        self.extendedLayoutIncludesOpaqueBars = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"成员管理";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.editeButton];
    [self.view addSubview:self.tableView];
    self.tableView.size = CGSizeMake(self.view.width, self.view.height - 10 - SSJ_NAVIBAR_BOTTOM);
    self.tableView.leftTop = CGPointMake(0, SSJ_NAVIBAR_BOTTOM + 10);
    [self.tableView registerClass:[SSJMemberTableViewCell class] forCellReuseIdentifier:kMemberTableViewCellIdentifier];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getDataFromDb];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SSJChargeMemberItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    SSJNewMemberViewController *newMemberVc = [[SSJNewMemberViewController alloc]init];
    if (item.memberId.length) {
        newMemberVc.originalItem = item;
    }else{
        [SSJAnaliyticsManager event:@"dialog_add_member"];
    }
    [self.navigationController pushViewController:newMemberVc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    SSJChargeMemberItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    if (!item.memberId.length || [item.memberId isEqualToString:SSJDefaultMemberId()]) {
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJChargeMemberItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    [SSJAnaliyticsManager event:@"delete_member"];
    [self deleteMemberWithMemberId:item.memberId];
    [self.items removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{
    if (proposedDestinationIndexPath.row == self.items.count - 1) {
        return [NSIndexPath indexPathForRow:self.items.count - 2 inSection:0];
    }
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    SSJChargeMemberItem *currentItem = [self.items ssj_safeObjectAtIndex:sourceIndexPath.row];
    [self.items removeObjectAtIndex:sourceIndexPath.row];
    [self.items insertObject:currentItem atIndex:destinationIndexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.items.count - 1) {
        return NO;
    }
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJMemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMemberTableViewCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[SSJMemberTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMemberTableViewCellIdentifier];
    }
    cell.selectable = NO;
    SSJChargeMemberItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    cell.memberItem = item;
    return cell;
}

#pragma mark - Private
- (void)getDataFromDb{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        FMResultSet *result = [db executeQuery:@"select * from bk_member where cuserid = ? and istate <> 0 order by iorder asc , cadddate asc",userid];
        NSMutableArray *tempArr = [NSMutableArray array];
        int count = 1;
        while ([result next]) {
            SSJChargeMemberItem *item = [[SSJChargeMemberItem alloc]init];
            item.memberId = [result stringForColumn:@"CMEMBERID"];
            item.memberName = [result stringForColumn:@"CNAME"];
            item.memberColor = [result stringForColumn:@"CCOLOR"];
            item.memberOrder = [result intForColumn:@"IORDER"];
            if (!item.memberOrder) {
                item.memberOrder = count;
            }
            count ++;
            [tempArr addObject:item];
        }
        SSJChargeMemberItem *item = [[SSJChargeMemberItem alloc]init];
        item.memberName = @"添加新成员";
        [tempArr addObject:item];
        weakSelf.items = [NSMutableArray arrayWithArray:tempArr];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    }];
}

- (void)saveMemberOrder{
    __weak typeof(self) weakSelf = self;
    [SSJAnaliyticsManager event:@"account_book_sort"];
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userId = SSJUSERID();
        NSString *writeDate = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        for (SSJChargeMemberItem *item in weakSelf.items) {
            NSInteger order = [weakSelf.items indexOfObject:item];
            [db executeUpdate:@"update bk_member set iorder = ?, cwritedate = ?, iversion = ? where cmemberid = ? and cuserid = ?",@(order),writeDate,@(SSJSyncVersion()),item.memberId,userId];
        }
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    }];
}

- (void)deleteMemberWithMemberId:(NSString *)Id {
    if ([Id isEqualToString:SSJDefaultMemberId()]) {
        return;
    }
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"update bk_member set istate = 0, iversion = ?, cwritedate = ? where cmemberid = ?",@(SSJSyncVersion()),[[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],Id];
//        [db executeUpdate:@"update bk_member_charge set operatortype = 2 where cmemberid = ?",Id];
    }];
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.rowHeight = 44;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
        _tableView.separatorInset = UIEdgeInsetsZero;
        [_tableView ssj_clearExtendSeparator];
//        [_tableView ssj_setBorderWidth:2];
//        [_tableView ssj_setBorderStyle:SSJBorderStyleTop];
//        [_tableView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor]];
    }
    return _tableView;
}

- (UIButton *)editeButton{
    if (!_editeButton) {
        _editeButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
        _editeButton.contentHorizontalAlignment = NSTextAlignmentRight;
        [_editeButton setTitle:@"编辑" forState:UIControlStateNormal];
        [_editeButton setTitle:@"完成" forState:UIControlStateSelected];
        [_editeButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor] forState:UIControlStateNormal];
        [_editeButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor] forState:UIControlStateSelected];
        [_editeButton addTarget:self action:@selector(editeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editeButton;
}

- (void)editeButtonClicked:(id)sender{
    _editeButton.selected = !_editeButton.isSelected;
    [self saveMemberOrder];
    [self.tableView setEditing:_editeButton.isSelected animated:NO];
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
