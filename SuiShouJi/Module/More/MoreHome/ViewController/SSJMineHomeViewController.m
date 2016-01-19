//
//  SSJMoreHomeViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJMineHomeViewController.h"
#import "SSJMineHomeTableViewHeader.h"
#import "SSJMineHomeTabelviewCell.h"
#import "SSJSyncSettingViewController.h"
#import "SSJNormalWebViewController.h"
#import "SSJLoginViewController.h"

@interface SSJMineHomeViewController ()
@property (nonatomic,strong) SSJMineHomeTableViewHeader *header;
@end

@implementation SSJMineHomeViewController{
    NSArray *_titleForSectionTwoArray;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"个人中心";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableHeaderView = self.header;
    _titleForSectionTwoArray = [[NSArray alloc]initWithObjects:@"同步设置",@"关于我们",@"用户协议与隐私说明", nil];
}

#pragma mark - Getter
-(SSJMineHomeTableViewHeader *)header{
    if (!_header) {
        _header = [SSJMineHomeTableViewHeader MineHomeHeader];
        _header.frame = CGRectMake(0, 0, self.view.width, 125);
        __weak typeof(self) weakSelf = self;
        _header.HeaderButtonClickedBlock = ^(){
            SSJLoginViewController *loginVC = [[SSJLoginViewController alloc]init];
            loginVC.backController = weakSelf;
            [weakSelf.navigationController pushViewController:loginVC animated:YES];
        };
    }
    return _header;
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
    if (indexPath.row == 0 && indexPath.section == 1) {
        SSJSyncSettingViewController *syncSettingVc = [[SSJSyncSettingViewController alloc]init];
        [self.navigationController pushViewController:syncSettingVc animated:YES];
    }else if (indexPath.section == 1 && indexPath.row == 1){
        NSURL *url = [[NSURL alloc]initWithString:@"http://1.9188.com/h5/about_shq/about.html"];
        SSJNormalWebViewController *webVC = [SSJNormalWebViewController webViewVCWithURL:url];
        webVC.title = @"关于我们";
        [self.navigationController pushViewController:webVC animated:YES];
    }else if (indexPath.section == 1 && indexPath.row == 2){
        NSURL *url = [[NSURL alloc]initWithString:@"http://1.9188.com/h5/about_shq/protocol.html"];
        SSJNormalWebViewController *webVC = [SSJNormalWebViewController webViewVCWithURL:url];
        webVC.title = @"用户协议";
        [self.navigationController pushViewController:webVC animated:YES];
    }
}
#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    return 3;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJMineHomeCell";
    SSJMineHomeTabelviewCell *mineHomeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!mineHomeCell) {
        mineHomeCell = [[SSJMineHomeTabelviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    if (indexPath.section == 0) {
        mineHomeCell.cellTitle = @"给个好评";
    }else{
        mineHomeCell.cellTitle = [_titleForSectionTwoArray objectAtIndex:indexPath.row];
    }
    return mineHomeCell;
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
