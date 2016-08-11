//
//  SSJMemberManagerViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/7/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMemberManagerViewController.h"
#import "SSJChargeMemBerItem.h"
#import "SSJBaseTableViewCell.h"
#import "SSJDatabaseQueue.h"
#import "SSJNewMemberViewController.h"

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
        [MobClick event:@"dialog_add_member"];
    }
    [self.navigationController pushViewController:newMemberVc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    SSJChargeMemberItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    if (!item.memberId.length || [item.memberId isEqualToString:@"0"]) {
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJChargeMemberItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    [MobClick event:@"delete_member"];
    [self deleteMemberWithMemberId:item.memberId];
    [self.items removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJMemberCell";
    SSJBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SSJBaseTableViewCell alloc] initWithStyle :UITableViewCellStyleValue1 reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    SSJChargeMemberItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    NSString *title = item.memberName;
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.text = title;
    cell.imageView.image = [title isEqualToString:@"添加新成员"] ? [[UIImage imageNamed:@"border_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : nil;
    cell.imageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    cell.textLabel.textColor = [title isEqualToString:@"添加新成员"] ? [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] : [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:18];
    cell.detailTextLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    if ([item.memberId isEqualToString:[NSString stringWithFormat:@"%@-0",SSJUSERID()]]) {
        cell.detailTextLabel.text = @"默认";
    }else{
        cell.detailTextLabel.text = @"";
    }
    return cell;
}

#pragma mark - Private
- (void)getDataFromDb{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        NSString *userid = SSJUSERID();
        FMResultSet *result = [db executeQuery:@"select * from bk_member where cuserid = ? and istate <> 0 order by cadddate asc",userid];
        NSMutableArray *tempArr = [NSMutableArray array];
        while ([result next]) {
            SSJChargeMemberItem *item = [[SSJChargeMemberItem alloc]init];
            item.memberId = [result stringForColumn:@"CMEMBERID"];
            item.memberName = [result stringForColumn:@"CNAME"];
            item.memberColor = [result stringForColumn:@"CCOLOR"];
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

- (void)deleteMemberWithMemberId:(NSString *)Id{
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"update bk_member set istate = 0 where cmemberid = ?",Id];
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
        [_tableView ssj_setBorderWidth:2];
        [_tableView ssj_setBorderStyle:SSJBorderStyleTop];
        [_tableView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellIndicatorColor]];
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
