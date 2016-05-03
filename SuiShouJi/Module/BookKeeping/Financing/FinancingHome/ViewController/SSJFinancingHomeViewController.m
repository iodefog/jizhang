//
//  SSJFinancingHomeViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/11.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJFinancingHomeViewController.h"
#import "SSJFinancingHomeTableViewCell.h"
#import "SSJFinancingHomeitem.h"
#import "SSJFundingDetailsViewController.h"
#import "SSJFundingTransferViewController.h"
#import "SSJNewFundingViewController.h"
#import "SSJFinancingHomePopView.h"
#import "SSJDatabaseQueue.h"
#import "SSJFinancingHomeHelper.h"
#import "FMDB.h"

@interface SSJFinancingHomeViewController ()
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UILabel *profitAmountLabel;
@property (nonatomic,strong) UILabel *profitLabel;
@property (nonatomic,strong) UIButton *transferButton;
@end

@implementation SSJFinancingHomeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"我的资金";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.headerView];
    [self.headerView addSubview:self.profitLabel];
    [self.headerView addSubview:self.profitAmountLabel];
    [self.headerView addSubview:self.transferButton];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[SSJFinancingHomeTableViewCell class] forCellReuseIdentifier:@"FinancingHomeTableViewCell"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor whiteColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    [self getDateFromDateBase];
    if (![[NSUserDefaults standardUserDefaults]boolForKey:SSJHaveEnterFundingHomeKey]) {
        SSJFinancingHomePopView *popView = [[[NSBundle mainBundle] loadNibNamed:@"SSJFinancingHomePopView" owner:nil options:nil] objectAtIndex:0];
        popView.frame = [UIScreen mainScreen].bounds;
        [[UIApplication sharedApplication].keyWindow addSubview:popView];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:SSJHaveEnterFundingHomeKey];
    }
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.headerView.size = CGSizeMake(self.view.width, 90);
    self.headerView.leftTop = CGPointMake(0, 10);
    self.profitAmountLabel.left = self.profitLabel.right + 20;
    self.transferButton.size = CGSizeMake(65, 30);
    [_headerView ssj_setBorderColor:[UIColor ssj_colorWithHex:@"a7a7a7"]];
    [_headerView ssj_setBorderStyle:SSJBorderStyleBottom];
    [_headerView ssj_setBorderWidth:1];
    self.profitLabel.left = 10.0f;
    self.profitLabel.centerY = self.headerView.height / 2;
    self.profitAmountLabel.centerY = self.headerView.height / 2;
    self.transferButton.right = self.view.width - 15;
    self.transferButton.centerY = self.headerView.height / 2;
    self.tableView.size = CGSizeMake(self.view.width, self.view.height - 149);
    self.tableView.leftTop = CGPointMake(0, self.headerView.bottom);
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SSJFinancingHomeTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (![cell.item.fundingName isEqualToString:@"添加资金账户"]) {
        SSJFundingDetailsViewController *fundingDetailVC = [[SSJFundingDetailsViewController alloc]init];
        fundingDetailVC.item = cell.item;
        [self.navigationController pushViewController:fundingDetailVC animated:YES];
    }else{
        SSJNewFundingViewController *newFundingVC = [[SSJNewFundingViewController alloc]init];
        [self.navigationController pushViewController:newFundingVC animated:YES];
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SSJFinancingHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FinancingHomeTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - Getter
-(UITableView *)tableView{
    if (_tableView==nil) {
        _tableView =[[UITableView alloc]init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource=self;
        _tableView.delegate=self;
        _tableView.backgroundColor = [UIColor whiteColor];
    }
    return _tableView;
}

-(UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc]init];
        _headerView.backgroundColor = [UIColor whiteColor];
        _profitLabel = [[UILabel alloc]init];
        _profitLabel.text = @"结余";
        _profitLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _profitLabel.font = [UIFont systemFontOfSize:14];
        [_profitLabel sizeToFit];
    }
    return _headerView;
}

-(UIButton *)transferButton{
    if (!_transferButton) {
        _transferButton = [[UIButton alloc]init];
        [_transferButton setTitle:@"转账" forState:UIControlStateNormal];
        [_transferButton addTarget:self action:@selector(transferButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _transferButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_transferButton setTitleColor:[UIColor ssj_colorWithHex:@"47cfbe"] forState:UIControlStateNormal];
        _transferButton.layer.borderColor = [UIColor ssj_colorWithHex:@"47cfbe"].CGColor;
        _transferButton.layer.borderWidth = 1;
        _transferButton.layer.cornerRadius = 2;
    }
    return _transferButton;
}

-(UILabel *)profitAmountLabel{
    if (!_profitAmountLabel)
    {
        _profitAmountLabel = [[UILabel alloc]init];
        _profitAmountLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
        _profitAmountLabel.font = [UIFont systemFontOfSize:24];

    }
    return _profitAmountLabel;
}

#pragma mark - Private
-(void)getDateFromDateBase{
    __weak typeof(self) weakSelf = self;
    [self.tableView ssj_showLoadingIndicator];
    [SSJFinancingHomeHelper queryForFundingSumMoney:^(double result) {
        weakSelf.profitAmountLabel.text = [NSString stringWithFormat:@"%.2f",result];
        [weakSelf.profitAmountLabel sizeToFit];
        [weakSelf.view setNeedsLayout];
    } failure:^(NSError *error) {
        
    }];
    [SSJFinancingHomeHelper queryForFundingListWithSuccess:^(NSArray<SSJFinancingHomeitem *> *result) {
        if (![result isEqualToArray:weakSelf.items]) {
            weakSelf.items = [[NSMutableArray alloc]initWithArray:result];
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
        }
        [weakSelf.tableView ssj_hideLoadingIndicator];
    } failure:^(NSError *error) {
        
    }];
}

-(void)transferButtonClicked{
    SSJFundingTransferViewController *fundingTransferVC = [[SSJFundingTransferViewController alloc]init];
    [self.navigationController pushViewController:fundingTransferVC animated:YES];
}

-(void)reloadDataAfterSync{
    [self getDateFromDateBase];
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
