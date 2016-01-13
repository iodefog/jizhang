
//
//  SSJFundingTypeSelectViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingTypeSelectViewController.h"
#import "SSJFundingTypeTableViewCell.h"
#import "SSJFundingItem.h"
#import "FMDB.h"

@interface SSJFundingTypeSelectViewController ()

@end

@implementation SSJFundingTypeSelectViewController{
    NSMutableArray *_items;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _items = [[NSMutableArray alloc]init];
    [self getDateFromDb];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.typeSelectedBlock) {
        self.typeSelectedBlock(((SSJFundingItem*)[_items objectAtIndex:indexPath.section]).fundingID);
    };
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJFundingTypeCell";
    SSJFundingTypeTableViewCell *FundingTypeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!FundingTypeCell) {
        FundingTypeCell = [[SSJFundingTypeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    FundingTypeCell.item = [_items objectAtIndex:indexPath.section];
    FundingTypeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return FundingTypeCell;
}

#pragma mark - Private
-(void)getDateFromDb{
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        NSLog(@"Could not open db");
        return;
    }
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM BK_FUND_INFO WHERE CPARENT = 'root' ORDER BY CFUNDID ASC"];
    while ([rs next]) {
        SSJFundingItem *item = [[SSJFundingItem alloc]init];
        item.fundingID = [rs stringForColumn:@"CFUNDID"];
        item.fundingName = [rs stringForColumn:@"CACCTNAME"];
        item.fundingIcon = [rs stringForColumn:@"CICOIN"];
        item.fundingMemo = [rs stringForColumn:@"CMEMO"];
        [_items addObject:item];
    }
    [db close];
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
