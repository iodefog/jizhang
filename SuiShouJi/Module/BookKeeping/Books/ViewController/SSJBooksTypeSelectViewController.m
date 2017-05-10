//
//  SSJBooksTypeSelectViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/5/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

static NSString * SSJBooksTypeCellIdentifier = @"booksTypeCell";

static BOOL kNeedBannerDisplay = YES;

#import "SSJBooksTypeSelectViewController.h"
#import "SSJBooksTypeStore.h"
#import "SSJBooksTypeItem.h"
#import "SSJBooksTypeCollectionViewCell.h"
#import "UIViewController+MMDrawerController.h"
#import "SSJAdWebViewController.h"
#import "SSJAdWebViewController.h"
#import "SSJBooksTypeEditeView.h"
#import "SSJBooksHeaderView.h"
#import "SSJDataSynchronizer.h"
#import "SSJBooksEditeOrNewViewController.h"
#import "SSJEditableCollectionView.h"
#import "SSJSummaryBooksViewController.h"
#import "SSJDatabaseQueue.h"
#import "SSJBooksParentSelectView.h"
#import "SSJBooksAdView.h"
#import "SSJBannerNetworkService.h"
#import "SSJBooksTypeEditAlertView.h"
#import "SSJBooksTypeDeletionAuthCodeAlertView.h"
#import "SSJUserTableManager.h"

@interface SSJBooksTypeSelectViewController ()<SSJEditableCollectionViewDelegate,SSJEditableCollectionViewDataSource>

@property(nonatomic, strong) SSJEditableCollectionView *collectionView;

@property(nonatomic, strong) NSMutableArray *items;

@property(nonatomic, strong) SSJBooksTypeItem *editBooksItem;

@property(nonatomic, strong) UIButton *rightButton;

@property(nonatomic, strong) SSJBooksHeaderView *header;

@property(nonatomic, strong) SSJBooksParentSelectView *parentSelectView;

@property(nonatomic, strong) SSJBooksAdView *adView;

@property(nonatomic, strong) SSJBannerNetworkService *adService;

@property (nonatomic, strong) SSJBooksTypeEditAlertView *editAlertView;

@property (nonatomic, strong) SSJBooksTypeDeletionAuthCodeAlertView *authCodeAlertView;

@property (nonatomic, strong) NSString *currentBooksId;

@end

@implementation SSJBooksTypeSelectViewController

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"账本";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.header];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.adView];
    [self.collectionView registerClass:[SSJBooksTypeCollectionViewCell class] forCellWithReuseIdentifier:SSJBooksTypeCellIdentifier];
    [self.collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor clearColor] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
//    self.mm_drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    [self.adService requestBannersList];
    [self.header startAnimating];
    [SSJAnaliyticsManager event:@"main_account_book"];
    [self getDateFromDB];
    [self.mm_drawerController setMaximumLeftDrawerWidth:SSJSCREENWITH * 0.8];
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.header stopLoading];
    self.rightButton.selected = NO;
    [self.collectionView endEditing];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.header.width = self.view.width;
    self.adView.leftBottom = CGPointMake(0, self.view.height);
    self.adView.width = self.view.width;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSJBooksTypeItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    if (item.editeModel) {
        self.editBooksItem = item;
        [self.editAlertView show];
    } else {
        if ([item.booksName isEqualToString:@"添加账本"]) {
            [self.parentSelectView show];
        } else {
            [SSJAnaliyticsManager event:@"change_account_book" extra:item.booksName
             ];
            SSJSelectBooksType(item.booksId);
            self.currentBooksId = item.booksId;
            [self.collectionView reloadData];
            [self.mm_drawerController closeDrawerAnimated:YES completion:NULL];
        }
    }
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *booksid = self.currentBooksId;
    SSJBooksTypeItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    SSJBooksTypeCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:SSJBooksTypeCellIdentifier forIndexPath:indexPath];
    if ([item.booksId isEqualToString:booksid]) {
        cell.isSelected = YES;
    }else{
        cell.isSelected = NO;
    }
    cell.item = item;
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float collectionViewWith = SSJSCREENWITH * 0.8;
    float itemWidth;
    if (SSJSCREENWITH == 320) {
        itemWidth = (collectionViewWith - 24 - 30) / 3;
    }else{
        itemWidth = (collectionViewWith - 24 - 45) / 3;
    }
    return CGSizeMake(itemWidth, itemWidth * 1.3);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(12, 18, 0, 12);
}

#pragma mark - SSJEditableCollectionViewDelegate
- (BOOL)collectionView:(SSJEditableCollectionView *)collectionView shouldBeginEditingWhenPressAtIndexPath:(NSIndexPath *)indexPath{
    [SSJAnaliyticsManager event:@"fund_sort"];
    if (indexPath.row == self.items.count - 1) {
        return NO;
    }
    return YES;
}

- (BOOL)collectionView:(SSJEditableCollectionView *)collectionView shouldMoveCellAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    if (toIndexPath.row == self.items.count - 1) {
        return NO;
    }
    return YES;
}

- (void)collectionView:(SSJEditableCollectionView *)collectionView didBeginEditingWhenPressAtIndexPath:(NSIndexPath *)indexPath{
    self.rightButton.selected = YES;
    self.adView.hidden = YES;
    for (SSJBooksTypeItem *item in self.items) {
        if (![item.booksName isEqualToString:@"添加账本"]) {
            item.editeModel = YES;
        }
    }
}

- (void)collectionViewDidEndEditing:(SSJEditableCollectionView *)collectionView{
    [SSJBooksTypeStore saveBooksOrderWithItems:self.items sucess:^{
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError *error) {
        SSJPRINT(@"%@",[error localizedDescription]);
    }];
}

//- (BOOL)shouldCollectionViewEndEditingWhenUserTapped:(SSJEditableCollectionView *)collectionView{
//    [self collectionViewEndEditing];
//    return YES;
//}

- (void)collectionView:(SSJEditableCollectionView *)collectionView didEndMovingCellFromIndexPath:(NSIndexPath *)fromIndexPath toTargetIndexPath:(NSIndexPath *)toIndexPath{
    SSJBooksTypeItem *currentItem = [self.items ssj_safeObjectAtIndex:fromIndexPath.row];
    [self.items removeObjectAtIndex:fromIndexPath.row];
    [self.items insertObject:currentItem atIndex:toIndexPath.row];
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service{
    if (kNeedBannerDisplay) {
        SSJBooksAdBanner *booksAdItem = self.adService.item.booksAdItem;
        if (booksAdItem.hidden) {
            self.adView.hidden = NO;
            [self.adView.adImageView sd_setImageWithURL:[NSURL URLWithString:booksAdItem.adImage] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    self.adView.height = self.view.width * image.size.height / image.size.width;
                }
            }];
        }
    }
}

#pragma mark - Event
- (void)rightButtonClicked:(id)sender{
    self.rightButton.selected = !self.rightButton.isSelected;
    if (self.rightButton.isSelected) {
        self.adView.hidden = YES;
        [SSJAnaliyticsManager event:@"accountbook_manage"];
    }else{
        self.adView.hidden = NO;
        [self.collectionView endEditing];
    }
    for (SSJBooksTypeItem *item in self.items) {
        if (![item.booksName isEqualToString:@"添加账本"]) {
            item.editeModel = self.rightButton.isSelected;
        }
    }
}

#pragma mark - Getter
-(SSJEditableCollectionView *)collectionView{
    if (_collectionView==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        if (SSJSCREENWITH == 320) {
            flowLayout.minimumInteritemSpacing = 10;
        }else{
            flowLayout.minimumInteritemSpacing = 15;
        }
        _collectionView=[[SSJEditableCollectionView alloc] initWithFrame:CGRectMake(0, self.header.bottom, self.view.width, self.view.height - self.header.bottom) collectionViewLayout:flowLayout];
        _collectionView.movedCellScale = 1.08;
        _collectionView.editDelegate=self;
        _collectionView.editDataSource=self;
        _collectionView.exchangeCellRegion = UIEdgeInsetsMake(30, 25, 30, 25);
        _collectionView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return _collectionView;
}

-(UIButton *)rightButton{
    if (!_rightButton) {
        _rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
        [_rightButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor] forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor] forState:UIControlStateSelected];
        _rightButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _rightButton.contentHorizontalAlignment = NSTextAlignmentRight;
        [_rightButton setTitle:@"管理" forState:UIControlStateNormal];
        [_rightButton setTitle:@"完成" forState:UIControlStateSelected];
        [_rightButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];    
        _rightButton.selected = NO;
    }
    return _rightButton;
}

- (SSJBooksHeaderView *)header{
    if (!_header) {
        _header = [[SSJBooksHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 178)];
        __weak typeof(self) weakSelf = self;
        _header.buttonClickBlock = ^(){
            [SSJAnaliyticsManager event:@"account_all_booksType"];
            SSJSummaryBooksViewController *summaryVc = [[SSJSummaryBooksViewController alloc]init];
            [weakSelf.navigationController pushViewController:summaryVc animated:YES];
        };
    }
    return _header;
}

- (SSJBooksParentSelectView *)parentSelectView{
    if (!_parentSelectView) {
        _parentSelectView = [[SSJBooksParentSelectView alloc]initWithFrame:self.view.frame];
        __weak typeof(self) weakSelf = self;
        _parentSelectView.parentSelectBlock = ^(NSInteger selectParent){
            SSJBooksEditeOrNewViewController *booksEditeVc = [[SSJBooksEditeOrNewViewController alloc]init];
            SSJBooksTypeItem *item = [[SSJBooksTypeItem alloc]init];
            item.booksParent = selectParent;
            booksEditeVc.item = item;
            [weakSelf.parentSelectView dismiss];
            [weakSelf.navigationController pushViewController:booksEditeVc animated:YES];
        };
    }
    return _parentSelectView;
}

- (SSJBooksAdView *)adView{
    if (!_adView) {
        _adView = [[SSJBooksAdView alloc]init];
        __weak typeof(self) weakSelf = self;
        _adView.imageClickBlock = ^(){
            SSJAdWebViewController *webVc = [SSJAdWebViewController webViewVCWithURL:[NSURL URLWithString:weakSelf.adService.item.booksAdItem.adUrl]];
            [weakSelf.navigationController pushViewController:webVc animated:YES];
        };
        _adView.closeButtonClickBlock = ^(){
            kNeedBannerDisplay = NO;
            weakSelf.adView.hidden = YES;
        };
        _adView.hidden = YES;
    }
    return _adView;
}

- (SSJBooksTypeEditAlertView *)editAlertView {
    if (!_editAlertView) {
        __weak typeof(self) wself = self;
        _editAlertView = [[SSJBooksTypeEditAlertView alloc] init];
        _editAlertView.editHandler = ^{
            [wself enterBooksTypeEditController];
        };
        _editAlertView.deleteHandler = ^{
            if ([wself.editBooksItem.booksId isEqualToString:SSJUSERID()]) {
                [CDAutoHideMessageHUD showMessage:@"日常账本无法删除"];
            } else {
                [wself.authCodeAlertView show];
            }
        };
    }
    return _editAlertView;
}

- (SSJBooksTypeDeletionAuthCodeAlertView *)authCodeAlertView {
    if (!_authCodeAlertView) {
        __weak typeof(self) wself = self;
        _authCodeAlertView = [[SSJBooksTypeDeletionAuthCodeAlertView alloc] init];
        _authCodeAlertView.finishVerification = ^{
            [wself deleteBooksWithType:1];
        };
    }
    return _authCodeAlertView;
}

- (SSJBannerNetworkService *)adService{
    if (!_adService) {
        _adService = [[SSJBannerNetworkService alloc]initWithDelegate:self];
        _adService.httpMethod = SSJBaseNetworkServiceHttpMethodGET;
    }
    return _adService;
}

#pragma mark - Private
-(void)getDateFromDB{
    __weak typeof(self) weakSelf = self;
    [SSJBooksTypeStore getTotalIncomeAndExpenceWithSuccess:^(double income, double expenture) {
        weakSelf.header.income = income;
        weakSelf.header.expenture = expenture;
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    }];
    
    [SSJUserTableManager currentBooksId:^(NSString * _Nonnull booksId) {
        weakSelf.currentBooksId = booksId;
        [SSJBooksTypeStore queryForBooksListWithSuccess:^(NSMutableArray<SSJBooksTypeItem *> *result) {
            weakSelf.items = [NSMutableArray arrayWithArray:result];
            [weakSelf.collectionView reloadData];
        } failure:^(NSError *error) {
            [SSJAlertViewAdapter showError:error];
        }];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

- (void)deleteBooksWithType:(BOOL)type{
    if ([self.editBooksItem.booksId isEqualToString:self.currentBooksId]) {
        SSJSelectBooksType(SSJUSERID());
    };
    __weak typeof(self) weakSelf = self;
    [SSJBooksTypeStore deleteBooksTypeWithbooksItems:@[self.editBooksItem] deleteType:type Success:^{
        weakSelf.rightButton.selected = NO;
        [weakSelf.collectionView endEditing];
        for (SSJBooksTypeItem *item in self.items) {
            item.editeModel = NO;
        }
        self.adView.hidden = NO;
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        [weakSelf getDateFromDB];
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

- (void)enterBooksTypeEditController {
    [SSJAnaliyticsManager event:@"accountbook_edit"];
    SSJBooksEditeOrNewViewController *booksEditeVc = [[SSJBooksEditeOrNewViewController alloc]init];
    booksEditeVc.item = self.editBooksItem;
    [self.navigationController pushViewController:booksEditeVc animated:YES];
}

-(void)updateAppearanceAfterThemeChanged{
    [super updateAppearanceAfterThemeChanged];
    self.collectionView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    [self.rightButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor] forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor] forState:UIControlStateSelected];
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc]initWithString:@"编辑 (单选)"];
    [attributedTitle addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1] range:NSMakeRange(0, 2)];
    [attributedTitle addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3] range:NSMakeRange(3, 4)];
    [attributedTitle addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:NSMakeRange(0, attributedTitle.length)];
    NSMutableAttributedString *attributedDisableTitle = [[NSMutableAttributedString alloc]initWithString:@"编辑 (单选)"];
    [attributedDisableTitle addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2] range:NSMakeRange(0, 2)];
    [attributedDisableTitle addAttribute:NSFontAttributeName value:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3] range:NSMakeRange(3, 4)];
    [attributedDisableTitle addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] range:NSMakeRange(0, attributedTitle.length)];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.summaryBooksHeaderColor alpha:SSJ_CURRENT_THEME.summaryBooksHeaderAlpha] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    [self.header updateAfterThemeChange];
}

@end
