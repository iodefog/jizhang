//
//  SSJBalenceChangeDetailViewController.m
//  SuiShouJi
//
//  Created by ricky on 2016/12/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBalenceChangeDetailViewController.h"

#import "SSJFundingDetailCell.h"

static NSString *const kFundingDetailCellID = @"kFundingDetailCellID";

@interface SSJBalenceChangeDetailViewController ()

@end

@implementation SSJBalenceChangeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[SSJBaseTableViewCell class] forCellReuseIdentifier:kFundingDetailCellID];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFundingDetailCellID forIndexPath:indexPath];
    if (!cell) {
        cell = [[SSJBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kFundingDetailCellID];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    if (indexPath.section == 0) {
        cell.imageView.image = [[UIImage imageNamed:self.chargeItem.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.imageView.tintColor = [UIColor ssj_colorWithHex:self.chargeItem.colorValue];
        cell.textLabel.text = self.chargeItem.typeName;
        cell.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        cell.detailTextLabel.text = self.chargeItem.typeName;
        cell.detailTextLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:20];
        return cell;
    }
    if (indexPath.row == 0 && indexPath.section == 1) {
        cell.textLabel.text = @"时间";
        cell.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        cell.detailTextLabel.text = self.chargeItem.billDate;
        cell.detailTextLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        return cell;
    }
    if (indexPath.row == 1 && indexPath.section == 1) {
        cell.textLabel.text = @"资金类型";
        cell.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        cell.detailTextLabel.text = self.chargeItem.fundName;
        cell.detailTextLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        return cell;
    }
    return nil;
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 90;
    }
    return 55;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
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
