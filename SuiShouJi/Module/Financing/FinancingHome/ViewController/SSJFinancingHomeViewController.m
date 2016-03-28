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

#import "FMDB.h"

@interface SSJFinancingHomeViewController ()
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UILabel *profitAmountLabel;
@property (nonatomic,strong) UILabel *profitLabel;
@property (nonatomic,strong) UIButton *transferButton;
@end

@implementation SSJFinancingHomeViewController{
    double _profitAmount;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"资金账户";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getDateFromDateBase];
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
        _profitLabel = [[UILabel alloc]init];
        _profitLabel.text = @"盈余";
        [_profitLabel sizeToFit];
        _profitAmountLabel = [[UILabel alloc]init];
    }
    return _headerView;
}

-(UIButton *)transferButton{
    if (!_transferButton) {
        _transferButton = [[UIButton alloc]init];
        [_transferButton setTitle:@"转账" forState:UIControlStateNormal];
    }
    return _transferButton;
}
#pragma mark - Private
-(void)getDateFromDateBase{
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()] ;
    if (![db open]) {
        NSLog(@"Could not open db.");
        return ;
    }
    self.items = [[NSMutableArray alloc]init];
    FMResultSet * rs = [db executeQuery:@"SELECT A.* , B.IBALANCE FROM BK_FUND_INFO  A , BK_FUNS_ACCT B WHERE CPARENT != ? AND A.CFUNDID = B.CFUNDID",@"root"];
    while ([rs next]) {
        SSJFinancingHomeitem *item = [[SSJFinancingHomeitem alloc]init];
        item.fundingColor = [rs stringForColumn:@"CCOLOR"];
        item.fundingIcon = [rs stringForColumn:@"CICOIN"];
        item.fundingID = [rs stringForColumn:@"CFUNDID"];
        item.fundingName = [rs stringForColumn:@"CACCTNAME"];
        item.fundingParent = [rs stringForColumn:@"CPARENT"];
        item.fundingAmount = [rs doubleForColumn:@"IBALANCE"];
        [self.items addObject:item];
    }
    _profitAmount = [db doubleForQuery:@"SELECT SUM(IBALANCE) FROM BK_FUNS_ACCT"];
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
