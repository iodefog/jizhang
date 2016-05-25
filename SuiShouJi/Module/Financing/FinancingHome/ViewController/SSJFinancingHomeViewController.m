//
//  SSJFinancingHomeViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/11.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

static BOOL KHasEnterFinancingHome;

static NSString * SSJFinancingNormalCellIdentifier = @"financingHomeNormalCell";

static NSString * SSJFinancingAddCellIdentifier = @"financingHomeAddCell";


#import "SSJFinancingHomeViewController.h"
#import "SSJFinancingHomeCell.h"
#import "SSJFinancingHomeitem.h"
#import "SSJFundingDetailsViewController.h"
#import "SSJFundingTransferViewController.h"
#import "SSJNewFundingViewController.h"
#import "SSJFinancingHomePopView.h"
#import "SSJDatabaseQueue.h"
#import "SSJFinancingHomeHelper.h"
#import "SSJFinancingHomeHeader.h"
#import "SSJFinancingHomeAddCell.h"
#import "SSJDataSynchronizer.h"
#import "FMDB.h"

@interface SSJFinancingHomeViewController ()
@property (nonatomic,strong) SSJEditableCollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) SSJFinancingHomeHeader *headerView;
@property(nonatomic, strong) NSString *newlyAddFundId;
@end

@implementation SSJFinancingHomeViewController{
    BOOL _editeModel;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"我的资金";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _editeModel = NO;
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[SSJFinancingHomeCell class] forCellWithReuseIdentifier:SSJFinancingNormalCellIdentifier];
    [self.collectionView registerClass:[SSJFinancingHomeAddCell class] forCellWithReuseIdentifier:SSJFinancingAddCellIdentifier];
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
    self.headerView.size = CGSizeMake(self.view.width, 85);
    self.headerView.leftTop = CGPointMake(0, 10);
//    self.profitAmountLabel.left = self.profitLabel.right + 20;
//    self.transferButton.size = CGSizeMake(65, 30);
    [_headerView ssj_setBorderColor:[UIColor ssj_colorWithHex:@"a7a7a7"]];
    [_headerView ssj_setBorderStyle:SSJBorderStyleBottom];
    [_headerView ssj_setBorderWidth:1];
//    self.profitLabel.left = 10.0f;
//    self.profitLabel.centerY = self.headerView.height / 2;
//    self.profitAmountLabel.centerY = self.headerView.height / 2;
//    self.transferButton.right = self.view.width - 15;
//    self.transferButton.centerY = self.headerView.height / 2;
    self.collectionView.size = CGSizeMake(self.view.width, self.view.height - 141);
    self.collectionView.leftTop = CGPointMake(0, self.headerView.bottom);
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self collectionViewEndEditing];
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSJFinancingHomeitem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    if (![item.fundingName isEqualToString:@"添加资金账户"]) {
        SSJFundingDetailsViewController *fundingDetailVC = [[SSJFundingDetailsViewController alloc]init];
        fundingDetailVC.item = item;
        [self.navigationController pushViewController:fundingDetailVC animated:YES];
    }else{
        SSJNewFundingViewController *newFundingVC = [[SSJNewFundingViewController alloc]init];
        __weak typeof(self) weakSelf = self;
        newFundingVC.finishBlock = ^(SSJFundingItem *newFundingItem){
            weakSelf.newlyAddFundId = newFundingItem.fundingID;
        };
        [self.navigationController pushViewController:newFundingVC animated:YES];
    }

}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if (!KHasEnterFinancingHome) {
        SSJFinancingHomeCell * currentCell = (SSJFinancingHomeCell *)cell;
        currentCell.transform = CGAffineTransformMakeTranslation( - self.view.width , 0);
        [UIView animateWithDuration:0.2 delay:0.1 * indexPath.row options:UIViewAnimationOptionTransitionCurlUp animations:^{
            currentCell.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            KHasEnterFinancingHome = YES;
        }];
    }
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSJFinancingHomeitem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    if (![item.fundingName isEqualToString:@"添加资金账户"]) {
        __weak typeof(self) weakSelf = self;
        SSJFinancingHomeCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:SSJFinancingNormalCellIdentifier forIndexPath:indexPath];
        cell.item = item;
        cell.editeModel = _editeModel;
        cell.deleteButtonClickBlock = ^(SSJFinancingHomeCell *cell){
            NSIndexPath *deleteIndex = [self.collectionView indexPathForCell:cell];
            [weakSelf.items removeObjectAtIndex:deleteIndex.item];
            [weakSelf.collectionView deleteItemsAtIndexPaths:@[deleteIndex]];
        };
        return cell;
    }else{
        SSJFinancingHomeAddCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:SSJFinancingAddCellIdentifier forIndexPath:indexPath];
        return cell;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSJFinancingHomeitem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    if (![item.fundingName isEqualToString:@"添加资金账户"]) {
        return CGSizeMake(self.view.width - 20, 85);
    }else{
        return CGSizeMake(self.view.width - 20, 50);
    }
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(15, 10, 5, 10);
}

#pragma mark - SSJEditableCollectionViewDelegate
- (BOOL)collectionView:(SSJEditableCollectionView *)collectionView shouldBeginEditingWhenPressAtIndexPath:(NSIndexPath *)indexPath{
    [MobClick event:@"fund_sort"];
    if (indexPath.row != self.items.count - 1) {
        return YES;
    }else{
        return NO;
    }
}

- (BOOL)collectionView:(SSJEditableCollectionView *)collectionView shouldMoveCellAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    if (toIndexPath.row != self.items.count - 1) {
        return YES;
    }else{
        return NO;
    }
}

- (void)collectionView:(SSJEditableCollectionView *)collectionView didBeginEditingWhenPressAtIndexPath:(NSIndexPath *)indexPath{
    _editeModel = YES;
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(collectionViewEndEditing)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    [self.collectionView reloadData];
}

- (void)collectionViewDidEndEditing:(SSJEditableCollectionView *)collectionView{
    
}

- (BOOL)shouldCollectionViewEndEditingWhenUserTapped:(SSJEditableCollectionView *)collectionView{
    [self collectionViewEndEditing];
    return YES;
}

- (void)collectionView:(SSJEditableCollectionView *)collectionView didEndMovingCellFromIndexPath:(NSIndexPath *)fromIndexPath toTargetIndexPath:(NSIndexPath *)toIndexPath{
    SSJFinancingHomeitem *currentItem = [self.items objectAtIndex:fromIndexPath.row];
    [self.items removeObjectAtIndex:fromIndexPath.row];
    [self.items insertObject:currentItem atIndex:toIndexPath.row];
    for (int i = 0; i < self.items.count; i ++) {
        SSJFinancingHomeitem *tempItem = [self.items objectAtIndex:i];
        tempItem.fundingOrder = i + 1;
    }
}

#pragma mark - Getter
-(SSJEditableCollectionView *)collectionView{
    if (_collectionView==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 10;
        _collectionView=[[SSJEditableCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.movedCellScale = 1.08;
        _collectionView.editDelegate=self;
        _collectionView.editDataSource=self;
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    return _collectionView;
}

-(SSJFinancingHomeHeader *)headerView{
    if (!_headerView) {
        _headerView = [[SSJFinancingHomeHeader alloc]init];
        _headerView.backgroundColor = [UIColor whiteColor];
        [_headerView.transferButton addTarget:self action:@selector(transferButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _headerView;
}

#pragma mark - Private
-(void)getDateFromDateBase{
    __weak typeof(self) weakSelf = self;
    [self.collectionView ssj_showLoadingIndicator];
    [SSJFinancingHomeHelper queryForFundingSumMoney:^(double result) {
        weakSelf.headerView.balanceAmount = [NSString stringWithFormat:@"%.2f",result];
        [weakSelf.view setNeedsLayout];
    } failure:^(NSError *error) {
        
    }];
    [SSJFinancingHomeHelper queryForFundingListWithSuccess:^(NSArray<SSJFinancingHomeitem *> *result) {
        weakSelf.items = [[NSMutableArray alloc]initWithArray:result];
        if (weakSelf.newlyAddFundId) {
            [weakSelf.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:result.count - 2 inSection:0]]];
            [weakSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:result.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            weakSelf.newlyAddFundId = nil;

        }else{
            [weakSelf.collectionView reloadData];
        }
        [weakSelf.collectionView ssj_hideLoadingIndicator];
        
    } failure:^(NSError *error) {
        [weakSelf.collectionView ssj_hideLoadingIndicator];
    }];
}

-(void)collectionViewEndEditing{
    [self.collectionView endEditing];
    _editeModel = NO;
    self.navigationItem.rightBarButtonItem = nil;
    [SSJFinancingHomeHelper SaveFundingOderWithItems:self.items error:nil];
    [self.collectionView reloadData];
}

-(void)transferButtonClicked{
    SSJFundingTransferViewController *fundingTransferVC = [[SSJFundingTransferViewController alloc]init];
    [self.navigationController pushViewController:fundingTransferVC animated:YES];
    [MobClick event:@"fund_transform"];
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
