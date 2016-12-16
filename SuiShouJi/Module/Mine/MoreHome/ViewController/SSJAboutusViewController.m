//
//  SSJAboutusVViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/5/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAboutusViewController.h"
#import "SSJAboutusTableViewCell.h"
#import "SSJNormalWebViewController.h"

#import "SSJStartChecker.h"

static NSString *const kTitle1 = @"团队介绍";
static NSString *const kTitle2 = @"用户协议";
static NSString *const kTitle3 = @"联系客服";

@interface SSJAboutusViewController ()
@property(nonatomic, strong) NSArray *titles;
@end

@implementation SSJAboutusViewController
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"关于我们";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.titles = @[kTitle1,kTitle2,kTitle3];
}


#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    //    if (SSJIsUserLogined() && section == [self.tableView numberOfSections] - 1) {
    //        return self.loggedFooterView;
    //    }
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectZero];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    //    if (SSJIsUserLogined() && section == [self.tableView numberOfSections] - 1) {
    //        return 80;
    //    }
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titles ssj_safeObjectAtIndex:indexPath.row];
    
    //  团队简介
    if ([title isEqualToString:kTitle1]) {
        SSJNormalWebViewController *webVc = [SSJNormalWebViewController webViewVCWithURL:[NSURL URLWithString:@"http://1.9188.com/h5/about_shq/about.html"]];
        webVc.title = @"关于我们";
        [self.navigationController pushViewController:webVc animated:YES];
    }
    
    
    //  用户协议
    if ([title isEqualToString:kTitle2]) {
        SSJNormalWebViewController *webVc = [SSJNormalWebViewController webViewVCWithURL:[NSURL URLWithString:SSJUserProtocolUrl]];
        webVc.title = @"用户协议与隐私说明";
        [self.navigationController pushViewController:webVc animated:YES];
    }
    
    //  联系客服
    if ([title isEqualToString:kTitle3]) {
        NSString *serviceNum;
        if ([SSJStartChecker sharedInstance].serviceNum.length) {
            serviceNum = [SSJStartChecker sharedInstance].serviceNum;
        } else {
            serviceNum = @"400-7676-298";
        }
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",serviceNum];
        UIWebView * callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebview];
    }
    
}
#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SSJAboutusTableViewCell";
    SSJAboutusTableViewCell *mineHomeCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!mineHomeCell) {
        mineHomeCell = [[SSJAboutusTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        mineHomeCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    mineHomeCell.cellTitle = [self.titles ssj_safeObjectAtIndex:indexPath.row];
    if ([mineHomeCell.cellTitle isEqualToString:kTitle3]) {
        if ([SSJStartChecker sharedInstance].serviceNum.length) {
            mineHomeCell.cellDetail = [SSJStartChecker sharedInstance].serviceNum;
        } else {
            mineHomeCell.cellDetail = @"400-7676-298";
        }
        mineHomeCell.cellSubTitle = @"(工作日: 9: 00--18: 00)";
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
