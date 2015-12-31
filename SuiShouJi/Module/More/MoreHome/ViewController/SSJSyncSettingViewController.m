//
//  SSJSyncSettingViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJSyncSettingViewController.h"
#import "SSJMineHomeTabelviewCell.h"

@interface SSJSyncSettingViewController ()
@end

@implementation SSJSyncSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"同步设置";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectZero];
    return footerView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *titleArray = @[@"仅在Wi-FI下自动同步",@"有网络连接时自动同步"];
    static NSString *cellId = @"SSJMineHomeCell";
    SSJMineHomeTabelviewCell *mineHomeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!mineHomeCell) {
        mineHomeCell = [[SSJMineHomeTabelviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    mineHomeCell.cellTitle = [titleArray objectAtIndex:indexPath.row];
    UISwitch *switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 15, 10)];
    switchButton.tag = indexPath.row + 100;
    if (indexPath.row == 0) {
        switchButton.on = YES;
    }
    [switchButton addTarget:self action:@selector(switchButtonClicked:) forControlEvents:UIControlEventValueChanged];
    mineHomeCell.accessoryView = switchButton;
    mineHomeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return mineHomeCell;
}

-(void)switchButtonClicked:(UISwitch*)cellswitch{
    if (cellswitch.tag == 100) {
        ((UISwitch*)[self.view viewWithTag:101]).on = NO;
    }else{
        ((UISwitch*)[self.view viewWithTag:100]).on = NO;
    }
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
