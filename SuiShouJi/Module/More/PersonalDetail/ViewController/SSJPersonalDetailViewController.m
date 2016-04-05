//
//  SSJPersonalDetailViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/4/5.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJPersonalDetailViewController.h"
#import "SSJMineHomeTabelviewCell.h"
#import "SSJPersonalDetailItem.h"
#import "SSJDatabaseQueue.h"
#import "SSJPersonalDetailHelper.h"

static NSString *const kTitle1 = @"更换头像";
static NSString *const kTitle2 = @"昵称";
static NSString *const kTitle3 = @"个性签名";
static NSString *const kTitle4 = @"手机号";
static NSString *const kTitle5 = @"修改密码";

@interface SSJPersonalDetailViewController ()
@property (nonatomic, strong) NSArray *titles;
@property(nonatomic, strong) SSJPersonalDetailItem *item;
@end

@implementation SSJPersonalDetailViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [SSJPersonalDetailHelper queryUserDetailWithsuccess:^(SSJPersonalDetailItem *data) {
        self.item = data;
    } failure:^(NSError *error) {
        
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (SSJUserLoginTypeKey != SSJLoginTypeNormal) {
        self.titles = @[@[kTitle1], @[kTitle2], @[kTitle3]];
    }else{
        self.titles = @[@[kTitle1], @[kTitle2], @[kTitle3],@[kTitle4],@[kTitle5]];
    }
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 80;
    }
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectZero];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
}
#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.titles[section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJMineHomeCell";
    NSString *title = [self.titles ssj_objectAtIndexPath:indexPath];
    SSJMineHomeTabelviewCell *mineHomeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!mineHomeCell) {
        mineHomeCell = [[SSJMineHomeTabelviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        mineHomeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    mineHomeCell.cellTitle = title;
    if ([title isEqualToString:kTitle1]) {
        
    }else if ([title isEqualToString:kTitle2]){
        if ([self.item.nickName isEqualToString:@""] || self.item.nickName == nil) {
            mineHomeCell.cellDetail = @"起个名字吧~";
        }else{
            mineHomeCell.cellDetail = self.item.nickName;
        }
    }else if ([title isEqualToString:kTitle3]){
        if ([self.item.signature isEqualToString:@""] || self.item.signature == nil) {
            mineHomeCell.cellDetail = @"啥也不留~";
        }else{
            mineHomeCell.cellDetail = self.item.nickName;
        }
    }else if ([title isEqualToString:kTitle4]){
        mineHomeCell.cellDetail = self.item.mobileNo;
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
