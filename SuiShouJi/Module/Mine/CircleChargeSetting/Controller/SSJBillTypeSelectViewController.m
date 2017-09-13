//
//  SSJBillTypeSelectViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/6/3.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBillTypeSelectViewController.h"
#import "SSJCategoryListHelper.h"
#import "SSJBillTypeSelectCell.h"
#import "SSJCreateOrEditBillTypeViewController.h"
#import "SSJDatabaseQueue.h"
#import "SSJUserTableManager.h"

static NSString * SSJBillTypeSelectCellIdentifier = @"billTypeSelectCellIdentifier";

@interface SSJBillTypeSelectViewController ()

@property(nonatomic, strong) NSMutableArray *items;

@property(nonatomic, strong) SSJRecordMakingBillTypeSelectionCellItem *selectedItem;

@end

@implementation SSJBillTypeSelectViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"选择类别";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[SSJBillTypeSelectCell class] forCellReuseIdentifier:SSJBillTypeSelectCellIdentifier];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(comfirmButtonClicked:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getdataFromDb];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SSJRecordMakingBillTypeSelectionCellItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    if ([item.title isEqualToString:@"添加"]) {
        __weak typeof(self) wself = self;
        SSJCreateOrEditBillTypeViewController *addTypeVC = [[SSJCreateOrEditBillTypeViewController alloc] init];
        addTypeVC.created = YES;
        addTypeVC.booksId = self.booksId;
        addTypeVC.expended = self.incomeOrExpenture;
        addTypeVC.saveHandler = ^(NSString * _Nonnull billID) {
            wself.selectedId = billID;
            [wself getdataFromDb];
        };
        [self.navigationController pushViewController:addTypeVC animated:YES];
    }else{
        self.selectedId = item.ID;
        self.selectedItem = item;
        [self.tableView reloadData];
    }
}


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJRecordMakingBillTypeSelectionCellItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    SSJBillTypeSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:SSJBillTypeSelectCellIdentifier];
    if (!cell) {
        cell = [[SSJBillTypeSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SSJBillTypeSelectCellIdentifier];
    }
    if ([item.ID isEqualToString:self.selectedId]) {
        cell.isSelected = YES;
    }else{
        cell.isSelected = NO;
    }
    cell.item = item;
    return cell;
}

#pragma mark - Event
-(void)comfirmButtonClicked:(id)sender{
    if (!self.selectedItem.ID.length) {
        [[[self queryBooksID] flattenMap:^RACStream *(NSString *booksID) {
            return [self queryBillTypeDetailWithBooksID:booksID];
        }] subscribeNext:^(SSJRecordMakingBillTypeSelectionCellItem *item) {
            if (self.typeSelectBlock) {
                self.typeSelectBlock(item);
            }
            [self.navigationController popViewControllerAnimated:YES];
        } error:^(NSError *error) {
            [CDAutoHideMessageHUD showError:error];
        }];
    }else{
        if (self.typeSelectBlock) {
            self.typeSelectBlock(self.selectedItem);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (RACSignal *)queryBooksID {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SSJUserTableManager currentBooksId:^(NSString * _Nonnull booksId) {
            [subscriber sendNext:booksId];
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (RACSignal *)queryBillTypeDetailWithBooksID:(NSString *)booksID {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db) {
            SSJRecordMakingBillTypeSelectionCellItem *item = [[SSJRecordMakingBillTypeSelectionCellItem alloc]init];
            item.ID = self.selectedId;
            FMResultSet *rs = [db executeQuery:@"select cname, cicoin, ccolor from bk_user_bill_type where cbillid = ? and cbooksid = ? and cuserid = ?", item.ID, booksID, SSJUSERID()];
            while ([rs next]) {
                item.title = [rs stringForColumn:@"cname"];
                item.imageName = [rs stringForColumn:@"cicoin"];
                item.colorValue = [rs stringForColumn:@"ccolor"];
            }
            [rs close];
            SSJDispatchMainAsync(^{
                [subscriber sendNext:item];
                [subscriber sendCompleted];
            });
        }];
        return nil;
    }];
}

#pragma mark - Private
-(void)getdataFromDb{
    __weak typeof(self) weakSelf = self;
    [SSJCategoryListHelper queryForCategoryListWithIncomeOrExpenture:self.incomeOrExpenture booksId:self.booksId Success:^(NSMutableArray<SSJRecordMakingBillTypeSelectionCellItem *> *result) {
        SSJRecordMakingBillTypeSelectionCellItem *item = [SSJRecordMakingBillTypeSelectionCellItem itemWithTitle:@"添加" imageName:@"add" colorValue:SSJ_CURRENT_THEME.secondaryColor ID:@"" order:0];
        [result addObject:item];
        weakSelf.items = [[NSMutableArray alloc]initWithArray:result];
        [weakSelf.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
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
