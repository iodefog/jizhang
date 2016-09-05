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
#import "SSJFundingTypeSelectViewController.h"
#import "SSJLoanListViewController.h"
#import "SSJCreditCardItem.h"
#import "SSJCreditCardStore.h"

#import "FMDB.h"

@interface SSJFinancingHomeViewController ()
@property (nonatomic,strong) SSJEditableCollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) SSJFinancingHomeHeader *headerView;
@property(nonatomic, strong) NSString *newlyAddFundId;
@property(nonatomic, strong) UIButton *hiddenButton;
@end

@implementation SSJFinancingHomeViewController{
    BOOL _editeModel;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"我的资金";
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _editeModel = NO;
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.hiddenButton];
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[SSJFinancingHomeCell class] forCellWithReuseIdentifier:SSJFinancingNormalCellIdentifier];
    [self.collectionView registerClass:[SSJFinancingHomeAddCell class] forCellWithReuseIdentifier:SSJFinancingAddCellIdentifier];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor whiteColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    [self getDateFromDateBase];
    if (![[NSUserDefaults standardUserDefaults]boolForKey:SSJHaveEnterFundingHomeKey]) {
        SSJFinancingHomePopView *popView = [[[NSBundle mainBundle] loadNibNamed:@"SSJFinancingHomePopView" owner:nil options:nil] ssj_safeObjectAtIndex:0];
        popView.frame = [UIScreen mainScreen].bounds;
        [[UIApplication sharedApplication].keyWindow addSubview:popView];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:SSJHaveEnterFundingHomeKey];
    }
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.headerView.size = CGSizeMake(self.view.width, 85);
    self.headerView.leftTop = CGPointMake(0, SSJ_NAVIBAR_BOTTOM);
    self.hiddenButton.right = self.view.width - 120;
    self.hiddenButton.centerY = self.headerView.centerY;
//    self.profitAmountLabel.left = self.profitLabel.right + 20;
//    self.transferButton.size = CGSizeMake(65, 30);
    [_headerView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    [_headerView ssj_setBorderStyle:SSJBorderStyleBottom | SSJBorderStyleTop];
    [_headerView ssj_setBorderWidth:1];
//    self.profitLabel.left = 10.0f;
//    self.profitLabel.centerY = self.headerView.height / 2;
//    self.profitAmountLabel.centerY = self.headerView.height / 2;
//    self.transferButton.right = self.view.width - 15;
//    self.transferButton.centerY = self.headerView.height / 2;
    self.collectionView.size = CGSizeMake(self.view.width, self.view.height - self.headerView.bottom - self.tabBarController.tabBar.height);
    self.collectionView.leftTop = CGPointMake(0, self.headerView.bottom);
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.collectionView.editing) {
        [self collectionViewEndEditing];
    }
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSJBaseItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    
    if ([item isKindOfClass:[SSJFinancingHomeitem class]]) {
        SSJFinancingHomeitem *financingItem = (SSJFinancingHomeitem *)item;
        if ([financingItem.fundingParent isEqualToString:@"10"]
            || [financingItem.fundingParent isEqualToString:@"11"]) {
            // 借贷
            SSJLoanListViewController *loanListVC = [[SSJLoanListViewController alloc] init];
            loanListVC.item = financingItem;
            [self.navigationController pushViewController:loanListVC animated:YES];
        } else {
            SSJFundingDetailsViewController *fundingDetailVC = [[SSJFundingDetailsViewController alloc]init];
                fundingDetailVC.item = financingItem;
            [self.navigationController pushViewController:fundingDetailVC animated:YES];
        }
    }else if([item isKindOfClass:[SSJCreditCardItem class]]){
        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
        SSJFundingDetailsViewController *fundingDetailVC = [[SSJFundingDetailsViewController alloc]init];
        fundingDetailVC.item = cardItem;
        [self.navigationController pushViewController:fundingDetailVC animated:YES];
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
    
    SSJBaseItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    __weak typeof(self) weakSelf = self;
    SSJFinancingHomeCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:SSJFinancingNormalCellIdentifier forIndexPath:indexPath];
    cell.item = item;
    cell.editeModel = _editeModel;
    cell.deleteButtonClickBlock = ^(SSJFinancingHomeCell *cell){
        SSJCreditCardItem *deleteItem = (SSJCreditCardItem *)cell.item;
        [SSJCreditCardStore deleteCreditCardWithCardItem:deleteItem Success:^{
//            [weakSelf.items removeObjectAtIndex:deleteIndex.item];
//            [weakSelf.collectionView deleteItemsAtIndexPaths:@[deleteIndex]];
            [weakSelf getDateFromDateBase];
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        } failure:^(NSError *error) {
            
        }];

    };
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
        return CGSizeMake(self.view.width - 20, 85);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(15, 10, 5, 10);
}

#pragma mark - SSJEditableCollectionViewDelegate
- (BOOL)collectionView:(SSJEditableCollectionView *)collectionView shouldBeginEditingWhenPressAtIndexPath:(NSIndexPath *)indexPath{
    [MobClick event:@"fund_sort"];
    return YES;
}

- (BOOL)collectionView:(SSJEditableCollectionView *)collectionView shouldMoveCellAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    return YES;
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
    SSJFinancingHomeitem *currentItem = [self.items ssj_safeObjectAtIndex:fromIndexPath.row];
    [self.items removeObjectAtIndex:fromIndexPath.row];
    [self.items insertObject:currentItem atIndex:toIndexPath.row];
    for (int i = 0; i < self.items.count; i ++) {
        SSJFinancingHomeitem *tempItem = [self.items ssj_safeObjectAtIndex:i];
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
        _collectionView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return _collectionView;
}

-(SSJFinancingHomeHeader *)headerView{
    if (!_headerView) {
        _headerView = [[SSJFinancingHomeHeader alloc]init];
        [_headerView.transferButton addTarget:self action:@selector(transferButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _headerView;
}

-(UIButton *)hiddenButton{
    if (!_hiddenButton) {
        _hiddenButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_hiddenButton setImage:[UIImage imageNamed:@"founds_yincang"] forState:UIControlStateNormal];
        [_hiddenButton setImage:[UIImage imageNamed:@"founds_xianshi"] forState:UIControlStateSelected];
        [_hiddenButton addTarget:self action:@selector(hiddenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hiddenButton;
}

#pragma mark - Event
-(void)hiddenButtonClicked:(id)sender{
    self.hiddenButton.selected = !self.hiddenButton.selected;
    if (self.hiddenButton.selected) {
        __weak typeof(self) weakSelf = self;
        [SSJFinancingHomeHelper queryForFundingSumMoney:^(double result) {
            weakSelf.headerView.balanceAmount = [NSString stringWithFormat:@"%.2f",result];
            [weakSelf.view setNeedsLayout];
        } failure:^(NSError *error) {
            
        }];
    }else{
        self.headerView.balanceAmount = @"******";
        [self .view setNeedsLayout];
    }
}

- (void)rightButtonClicked:(id)sender{
    SSJFundingTypeSelectViewController *fundingTypeSelectVC = [[SSJFundingTypeSelectViewController alloc]init];
    [self.navigationController pushViewController:fundingTypeSelectVC animated:YES];
}

#pragma mark - Private
-(void)getDateFromDateBase{
    __weak typeof(self) weakSelf = self;
    [self.collectionView ssj_showLoadingIndicator];
    [SSJFinancingHomeHelper queryForFundingSumMoney:^(double result) {
        if (weakSelf.hiddenButton.selected) {
            weakSelf.headerView.balanceAmount = [NSString stringWithFormat:@"%.2f",result];
            [weakSelf.view setNeedsLayout];
        }else{
            self.headerView.balanceAmount = @"******";
        }
    } failure:^(NSError *error) {
        
    }];
    [SSJFinancingHomeHelper queryForFundingListWithSuccess:^(NSArray<SSJFinancingHomeitem *> *result) {
        weakSelf.items = [[NSMutableArray alloc]initWithArray:result];
        for (int i = 0; i < weakSelf.items.count; i ++) {
            SSJFinancingHomeitem *fundItem = [weakSelf.items objectAtIndex:i];
            if ([fundItem.fundingParent isEqualToString:@"3"]) {
                SSJCreditCardItem *cardItem = [SSJCreditCardStore queryCreditCardDetailWithCardId:fundItem.fundingID];
                cardItem.cardOder = fundItem.fundingOrder;
                [weakSelf.items removeObject:fundItem];
                [weakSelf.items insertObject:cardItem atIndex:cardItem.cardOder - 1];
            }
        }
        [weakSelf.collectionView reloadData];
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

-(void)updateAppearanceAfterThemeChanged{
    [super updateAppearanceAfterThemeChanged];
    [self.headerView updateAfterThemeChange];
    self.collectionView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    self.headerView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    [self.collectionView reloadData];
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
