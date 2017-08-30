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
#import "SSJFundingTypeSelectViewController.h"
#import "SSJLoanListViewController.h"
#import "SSJFundingDetailsViewController.h"
#import "SSJFundingTransferViewController.h"
#import "SSJFixedFinanceProductListViewController.h"

#import "SSJEditableCollectionView.h"
#import "SSJFinancingHomeCell.h"
#import "SSJFinancingHomePopView.h"
#import "SSJFinancingHomeHeader.h"
#import "SSJFinancingHomeSelectView.h"

#import "SSJCreditCardItem.h"
#import "SSJCreditCardStore.h"
#import "SSJLoanHelper.h"
#import "SSJFinancingHomeitem.h"
#import "SSJFundingItem.h"
#import "SSJDataSynchronizer.h"
#import "SSJFinancingHomeHelper.h"
#import "SSJDatabaseQueue.h"
#import "SSJUserTableManager.h"

#import "FMDB.h"

@interface SSJFinancingHomeViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,SSJEditableCollectionViewDelegate,SSJEditableCollectionViewDataSource>

@property (nonatomic,strong) SSJEditableCollectionView *collectionView;

@property (nonatomic,strong) NSMutableArray *items;

@property (nonatomic,strong) SSJFinancingHomeHeader *headerView;

@property(nonatomic, strong) NSString *newlyAddFundId;

@property(nonatomic, strong) SSJFinancingHomeSelectView *fundingSelectView;

@property(nonatomic, strong) NSString *selectedFundids;

@property(nonatomic, strong) NSArray *selectedFundidsArr;

@end

@implementation SSJFinancingHomeViewController{
//    BOOL _editeModel;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"我的资金";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    _editeModel = NO;
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[SSJFinancingHomeCell class] forCellWithReuseIdentifier:SSJFinancingNormalCellIdentifier];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"founds_jia"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor whiteColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
//    self.navigationItem.rightBarButtonItem.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    if (!self.selectedFundids) {
        @weakify(self);
        [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
            @strongify(self);
            self.selectedFundids = userItem.selectFundid;
            [self getDataFromDataBase];
        } failure:NULL];
    } else {
        [self getDataFromDataBase];
    }
    if (![[NSUserDefaults standardUserDefaults]boolForKey:SSJHaveEnterFundingHomeKey]) {
        SSJFinancingHomePopView *popView = [[[NSBundle mainBundle] loadNibNamed:@"SSJFinancingHomePopView" owner:nil options:nil] ssj_safeObjectAtIndex:0];
        popView.frame = [UIScreen mainScreen].bounds;
        [[UIApplication sharedApplication].keyWindow addSubview:popView];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:SSJHaveEnterFundingHomeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.headerView.size = CGSizeMake(self.view.width, 80);
    self.headerView.leftTop = CGPointMake(0, SSJ_NAVIBAR_BOTTOM);
    self.collectionView.size = CGSizeMake(self.view.width, self.view.height - self.headerView.bottom - self.tabBarController.tabBar.height);
    self.collectionView.leftTop = CGPointMake(0, self.headerView.bottom);
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    if (self.collectionView.editing) {
//        [self collectionViewEndEditing];
//    }
    SSJUserItem *item = [[SSJUserItem alloc] init];
    item.selectFundid = self.selectedFundids;
    item.userId = SSJUSERID();
    [SSJUserTableManager saveUserItem:item success:NULL failure:NULL];
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSJBaseCellItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    
    if ([item isKindOfClass:[SSJFinancingHomeitem class]]) {
        SSJFinancingHomeitem *financingItem = (SSJFinancingHomeitem *)item;
        if ([financingItem.fundingParent isEqualToString:@"10"]
            || [financingItem.fundingParent isEqualToString:@"11"]) {
            // 借贷
            SSJLoanListViewController *loanListVC = [[SSJLoanListViewController alloc] init];
            loanListVC.item = financingItem;
            [self.navigationController pushViewController:loanListVC animated:YES];
        } else if ([financingItem.fundingParent isEqualToString:@"17"]) {
            SSJFixedFinanceProductListViewController *fixedFinancevc = [[SSJFixedFinanceProductListViewController alloc] init];
            fixedFinancevc.item = financingItem;
            [self.navigationController pushViewController:fixedFinancevc animated:YES];
        } else {
            SSJFundingDetailsViewController *fundingDetailVC = [[SSJFundingDetailsViewController alloc]init];
                fundingDetailVC.item = financingItem;
            [self.navigationController pushViewController:fundingDetailVC animated:YES];
        }
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
    
    SSJBaseCellItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    __weak typeof(self) weakSelf = self;
    SSJFinancingHomeCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:SSJFinancingNormalCellIdentifier forIndexPath:indexPath];
    cell.item = item;
//    cell.editeModel = _editeModel;
    cell.deleteButtonClickBlock = ^(SSJFinancingHomeCell *cell,NSInteger chargeCount){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"确定要删除该资金账户吗?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
        UIAlertAction *comfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (chargeCount) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"删除该资金后，是否将展示在首页和报表的流水及相关借贷数据一并删除" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *reserve = [UIAlertAction actionWithTitle:@"仅删除资金" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf deleteFundingItem:cell.item type:0];
                }];
                UIAlertAction *destructive = [UIAlertAction actionWithTitle:@"一并删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf deleteFundingItem:cell.item type:1];
                }];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alert addAction:reserve];
                [alert addAction:destructive];
                [alert addAction:cancel];
                [weakSelf presentViewController:alert animated:YES completion:NULL];
            }else{
                [weakSelf deleteFundingItem:cell.item type:0];
            }
        }];
        [alert addAction:cancel];
        [alert addAction:comfirm];
        [self presentViewController:alert animated:YES completion:NULL];
    };
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
        return CGSizeMake(self.view.width - 30, 80);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 10, 5, 10);
}

#pragma mark - SSJEditableCollectionViewDelegate
- (BOOL)collectionView:(SSJEditableCollectionView *)collectionView shouldBeginMovingCellAtIndexPath:(NSIndexPath *)indexPath {
    [SSJAnaliyticsManager event:@"fund_sort"];
    return YES;
}

- (BOOL)collectionView:(SSJEditableCollectionView *)collectionView shouldMoveCellAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    return YES;
}

- (void)collectionView:(SSJEditableCollectionView *)collectionView didEndMovingCellFromIndexPath:(NSIndexPath *)fromIndexPath toTargetIndexPath:(NSIndexPath *)toIndexPath{
    SSJFinancingHomeitem *currentItem = [self.items ssj_safeObjectAtIndex:fromIndexPath.row];
    [self.items removeObjectAtIndex:fromIndexPath.row];
    [self.items insertObject:currentItem atIndex:toIndexPath.row];
    for (int i = 0; i < self.items.count; i ++) {
        SSJBaseCellItem *tempItem = [self.items ssj_safeObjectAtIndex:i];
        if ([tempItem isKindOfClass:[SSJFinancingHomeitem class]]) {
            SSJFinancingHomeitem *fundingItem = (SSJFinancingHomeitem *)tempItem;
            fundingItem.fundingOrder = i + 1;
        }else if ([tempItem isKindOfClass:[SSJCreditCardItem class]]){
            SSJCreditCardItem *cardItem = (SSJCreditCardItem *)tempItem;
            cardItem.cardOder = i + 1;
        }
    }
    
    [SSJAnaliyticsManager event:@"account_book_sort"];
    [SSJFinancingHomeHelper SaveFundingOderWithItems:self.items error:nil];
}

#pragma mark - Getter
-(SSJEditableCollectionView *)collectionView{
    if (_collectionView==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 10;
        _collectionView=[[SSJEditableCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.movedCellScale = 1.08;
        _collectionView.editDelegate=self;
        _collectionView.editDataSource=self;
        _collectionView.exchangeCellRegion = UIEdgeInsetsMake(20, 0, 20, 0);
        _collectionView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return _collectionView;
}

-(SSJFinancingHomeHeader *)headerView{
    if (!_headerView) {
        _headerView = [[SSJFinancingHomeHeader alloc] init];
        [_headerView.transferButton addTarget:self action:@selector(transferButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        @weakify(self);
        _headerView.hiddenButtonClickBlock = ^(){
            @strongify(self);
            [self hiddenButtonClicked];
        };
        
        _headerView.balanceButtonClickBlock = ^{
            @strongify(self);
            [self balanceSelectButtonClicked];
        };
    }
    return _headerView;
}

- (SSJFinancingHomeSelectView *)fundingSelectView {
    if (!_fundingSelectView) {
        _fundingSelectView = [[SSJFinancingHomeSelectView alloc] init];
        @weakify(self);
        _fundingSelectView.dismissBlock = ^(NSString *selectedFundid, NSArray *selectedFundids) {
            @strongify(self);
            self.selectedFundids = selectedFundid;
            self.selectedFundidsArr = selectedFundids;
            self.headerView.balanceButton.layer.transform = CATransform3DIdentity;
            [self getSumMoney];
        };
    }
    return _fundingSelectView;
}


#pragma mark - Event
-(void)hiddenButtonClicked{
    self.headerView.hiddenButton.selected = !self.headerView.hiddenButton.selected;
    if (self.headerView.hiddenButton.selected) {
        [self getSumMoney];
    }else{
        self.headerView.balanceAmount = @"******";
        [self .view setNeedsLayout];
    }
}

- (void)rightButtonClicked:(id)sender{
    SSJFundingTypeSelectViewController *fundingTypeSelectVC = [[SSJFundingTypeSelectViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
    fundingTypeSelectVC.needLoanOrNot = YES;
    __weak typeof(self) weakSelf = self;
    fundingTypeSelectVC.addNewFundingBlock = ^(SSJBaseCellItem *item){
        if ([item isKindOfClass:[SSJFundingItem class]]) {
            weakSelf.newlyAddFundId = ((SSJFundingItem *)item).fundingID;
        }else if ([item isKindOfClass:[SSJCreditCardItem class]]){
            weakSelf.newlyAddFundId = ((SSJCreditCardItem *)item).fundingID;
        }
    };
    [self.navigationController pushViewController:fundingTypeSelectVC animated:YES];
}

- (void)balanceSelectButtonClicked {
    if (!self.selectedFundids) {
        [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
            self.selectedFundids = userItem.selectFundid;
            [self.fundingSelectView setItems:self.items andSelectFundid:userItem.selectFundid];
            [self.fundingSelectView showInView:self.view atPoint:[self.headerView convertPoint:CGPointMake(self.headerView.balanceButton.frame.origin.x, self.headerView.balanceButton.frame.origin.y + 20)  toView:self.view]];
        } failure:NULL];
    } else {
        [self.fundingSelectView setItems:self.items andSelectFundid:self.selectedFundids];
        [self.fundingSelectView showInView:self.view atPoint:[self.headerView convertPoint:CGPointMake(self.headerView.balanceButton.frame.origin.x, self.headerView.balanceButton.frame.origin.y + 20)  toView:self.view]];
    }
}

#pragma mark - Private
-(void)getDataFromDataBase{
    @weakify(self);
    if (!self.items.count) {
        [self.collectionView ssj_showLoadingIndicator];
    }

    [SSJFinancingHomeHelper queryForFundingListWithSuccess:^(NSArray<SSJFinancingHomeitem *> *result) {
//        @strongify(self);
//        self.items = [[NSMutableArray alloc]initWithArray:result];
//        if (self.newlyAddFundId) {
//            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:result.count - 1 inSection:0]]];
//            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:result.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
//            self.newlyAddFundId = nil;
//        }else{
//            [self.collectionView reloadData];
//        }
//        [self.collectionView ssj_hideLoadingIndicator];
//        
//        [self getSumMoney];
    } failure:^(NSError *error) {
//        [self.collectionView ssj_hideLoadingIndicator];
    }];
}

- (void)deleteFundingItem:(SSJBaseCellItem *)item type:(BOOL)type{
    __weak typeof(self) weakSelf = self;
    [SSJFinancingHomeHelper deleteFundingWithFundingItem:item deleteType:type Success:^{
        [weakSelf getDataFromDataBase];
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError *error) {
        SSJPRINT(@"%@",[error localizedDescription]);
    }];
}

-(void)collectionViewEndEditing{
//    _editeModel = NO;
    [self.collectionView reloadData];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"founds_jia"] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

-(void)transferButtonClicked{
    SSJFundingTransferViewController *fundingTransferVC = [[SSJFundingTransferViewController alloc]init];
    [self.navigationController pushViewController:fundingTransferVC animated:YES];
    [SSJAnaliyticsManager event:@"fund_transform"];
}

-(void)reloadDataAfterSync{
    [self getDataFromDataBase];
}

-(void)updateAppearanceAfterThemeChanged{
    [super updateAppearanceAfterThemeChanged];
    [self.headerView updateAfterThemeChange];
    self.collectionView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    self.headerView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
//    self.navigationItem.rightBarButtonItem.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    [self.collectionView reloadData];
}

- (void)getSumMoney {
    __block double sumMoney = 0;
    [self.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[SSJFinancingHomeitem class]]) {
            SSJFinancingHomeitem *fundingItem = (SSJFinancingHomeitem *)obj;
            if ([self.selectedFundids isEqualToString:@"all"] || [self.selectedFundidsArr containsObject:fundingItem.fundingID]) {
                sumMoney += fundingItem.fundingAmount;
            }
        }else if([obj isKindOfClass:[SSJCreditCardItem class]]){
            SSJCreditCardItem *creditItem = (SSJCreditCardItem *)obj;
            if ([self.selectedFundids isEqualToString:@"all"] || [self.selectedFundidsArr containsObject:creditItem.fundingID]) {
                sumMoney += creditItem.fundingAmount;
            }
        }
    }];
    
    if (self.headerView.hiddenButton.selected) {
        self.headerView.balanceAmount = [NSString stringWithFormat:@"%.2f",sumMoney];
        [self.view setNeedsLayout];
    }else{
        self.headerView.balanceAmount = @"******";
    }

}

@end
