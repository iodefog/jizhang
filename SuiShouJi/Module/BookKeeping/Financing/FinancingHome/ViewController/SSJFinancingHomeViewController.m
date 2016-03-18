//
//  SSJFinancingHomeViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/11.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJFinancingHomeViewController.h"
#import "SSJFinancingHomeCollectionViewCell.h"
#import "SSJFinancingHomeitem.h"
#import "SSJFundingDetailsViewController.h"
#import "SSJFundingTransferViewController.h"
#import "SSJNewFundingViewController.h"
#import "SSJFinancingHomePopView.h"
#import "SSJDatabaseQueue.h"
#import "FMDB.h"

@interface SSJFinancingHomeViewController ()
@property (nonatomic,strong) UICollectionView *collectionView;
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
    [self getDateFromDateBase];
    [self.view addSubview:self.headerView];
    [self.headerView addSubview:self.profitLabel];
    [self.headerView addSubview:self.profitAmountLabel];
    [self.headerView addSubview:self.transferButton];
    [self.view addSubview:self.collectionView];
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
    self.headerView.size = CGSizeMake(self.view.width, 66);
    self.headerView.leftTop = CGPointMake(0, 10);
    [_headerView ssj_setBorderColor:[UIColor ssj_colorWithHex:@"a7a7a7"]];
    [_headerView ssj_setBorderStyle:SSJBorderStyleBottom];
    [_headerView ssj_setBorderWidth:1];
    self.profitLabel.left = 10.0f;
    self.profitLabel.centerY = self.headerView.height / 2;
    self.profitAmountLabel.left = self.profitLabel.right + 20;
    self.profitAmountLabel.centerY = self.headerView.height / 2;
    self.transferButton.size = CGSizeMake(65, 30);
    self.transferButton.right = self.view.width - 15;
    self.transferButton.centerY = self.headerView.height / 2;
    self.collectionView.size = CGSizeMake(self.view.width, self.view.height - 120);
    self.collectionView.leftTop = CGPointMake(0, self.headerView.bottom);
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.items.count;
}

- (NSInteger)numberOfSections{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJFinancingHomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FinancingHomeCollectionViewCell" forIndexPath:indexPath];
    cell.item = (SSJFinancingHomeitem*)[self.items objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.width - 20, 60);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SSJFinancingHomeCollectionViewCell *cell = (SSJFinancingHomeCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (![cell.item.fundingName isEqualToString:@"添加资金账户"]) {
        SSJFundingDetailsViewController *fundingDetailVC = [[SSJFundingDetailsViewController alloc]init];
        fundingDetailVC.item = cell.item;
        [self.navigationController pushViewController:fundingDetailVC animated:YES];
    }else{
        SSJNewFundingViewController *newFundingVC = [[SSJNewFundingViewController alloc]init];
        [self.navigationController pushViewController:newFundingVC animated:YES];
    }
}

#pragma mark - Getter
-(UICollectionView *)collectionView{
    if (_collectionView==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 10;
        _collectionView =[[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.dataSource=self;
        _collectionView.delegate=self;
        [_collectionView registerClass:[SSJFinancingHomeCollectionViewCell class] forCellWithReuseIdentifier:@"FinancingHomeCollectionViewCell"];
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    return _collectionView;
}

-(UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc]init];
        _headerView.backgroundColor = [UIColor whiteColor];
        _profitLabel = [[UILabel alloc]init];
        _profitLabel.text = @"结余";
        _profitLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        _profitLabel.font = [UIFont systemFontOfSize:15];
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
    __block double profitAmount;
    [[SSJDatabaseQueue sharedInstance]asyncInTransaction:^(FMDatabase *db , BOOL *rollback){
        NSString *userid = SSJUSERID();
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        FMResultSet * rs = [db executeQuery:@"SELECT A.* , B.IBALANCE FROM BK_FUND_INFO  A , BK_FUNS_ACCT B WHERE A.CPARENT != 'root' AND A.CFUNDID = B.CFUNDID AND A.OPERATORTYPE <> 2 AND A.CUSERID = ? ORDER BY A.CPARENT ASC , A.CWRITEDATE DESC",userid];
        while ([rs next]) {
            SSJFinancingHomeitem *item = [[SSJFinancingHomeitem alloc]init];
            item.fundingColor = [rs stringForColumn:@"CCOLOR"];
            item.fundingIcon = [rs stringForColumn:@"CICOIN"];
            item.fundingID = [rs stringForColumn:@"CFUNDID"];
            item.fundingName = [rs stringForColumn:@"CACCTNAME"];
            item.fundingParent = [rs stringForColumn:@"CPARENT"];
            item.fundingAmount = [rs doubleForColumn:@"IBALANCE"];
            item.fundingMemo = [rs stringForColumn:@"CMEMO"];
            item.isAddOrNot = NO;
            [tempArray addObject:item];
        }
        SSJFinancingHomeitem *item = [[SSJFinancingHomeitem alloc]init];
        item.fundingName = @"添加资金账户";
        item.fundingColor = @"cccccc";
        item.fundingIcon = @"add";
        item.isAddOrNot = YES;
        [tempArray addObject:item];
        profitAmount = [db doubleForQuery:@"SELECT SUM(A.IBALANCE) FROM BK_FUNS_ACCT A , BK_FUND_INFO B WHERE A.CFUNDID = B.CFUNDID AND A.CUSERID = ? AND B.OPERATORTYPE <> 2",SSJUSERID()];
        dispatch_async(dispatch_get_main_queue(), ^(){
            weakSelf.items = [[NSMutableArray alloc]initWithArray:tempArray];
            weakSelf.profitAmountLabel.text = [NSString stringWithFormat:@"%.2f",profitAmount];
            [weakSelf.profitAmountLabel sizeToFit];
            [weakSelf.view setNeedsLayout];
            [weakSelf.collectionView reloadData];
        });
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
