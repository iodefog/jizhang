//
//  SSJAnnouncementsListViewController.m
//  SuiShouJi
//
//  Created by ricky on 2017/3/2.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJAnnouncementsListViewController.h"
#import "SSJAnnouncementDetailCell.h"

static NSString *const kAnnouncementCellIdentifier = @"kAnnouncementCellIdentifier";


@interface SSJAnnouncementsListViewController ()

@end

@implementation SSJAnnouncementsListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"消息";
        self.hidesBottomBarWhenPushed = YES;
        self.showDragView = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[SSJAnnouncementDetailCell class] forCellReuseIdentifier:kAnnouncementCellIdentifier];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectZero];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {

    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJAnnouncementDetailCell *announcementCell  = [tableView dequeueReusableCellWithIdentifier:kAnnouncementCellIdentifier];
    [announcementCell setCellItem:[self.items objectAtIndex:indexPath.row]];
    return announcementCell;
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
