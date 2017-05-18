//
//  SSJBooksTypeSelectViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/5/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

static NSString * SSJBooksTypeCellIdentifier = @"booksTypeCell";
static NSString * SSJBooksTypeCellHeaderIdentifier = @"SSJBooksTypeCellHeaderIdentifier";
static BOOL kNeedBannerDisplay = YES;

#import "SSJBooksTypeSelectViewController.h"
#import "SSJBooksTypeStore.h"
#import "SSJBooksTypeItem.h"
#import "SSJBooksCollectionViewCell.h"
#import "UIViewController+MMDrawerController.h"
#import "SSJAdWebViewController.h"
#import "SSJAdWebViewController.h"
#import "SSJBooksTypeEditeView.h"
#import "SSJBooksHeaderView.h"
#import "SSJDataSynchronizer.h"

#import "SSJNewOrEditeBooksViewController.h"
#import "SSJEditableCollectionView.h"
#import "SSJSummaryBooksViewController.h"
#import "SSJDatabaseQueue.h"
//#import "SSJBooksParentSelectView.h"
#import "SSJBooksAdView.h"
#import "SSJBannerNetworkService.h"
#import "SSJBooksTypeEditAlertView.h"
#import "SSJBooksTypeDeletionAuthCodeAlertView.h"
#import "SSJUserTableManager.h"
#import "SSJBooksHeadeCollectionrReusableView.h"

@interface SSJBooksTypeSelectViewController ()<SSJEditableCollectionViewDelegate,SSJEditableCollectionViewDataSource>

@property (nonatomic, strong) NSArray *headerTitleArray;

/**个人账本列表*/
@property(nonatomic, strong) NSMutableArray <SSJBooksTypeItem *>*privateBooksDataitems;

/**共享账本列表*/
@property (nonatomic, strong) NSMutableArray <SSJShareBookItem *>*shareBooksDataItems;

@property(nonatomic, strong) SSJBooksTypeItem *editBooksItem;

@property(nonatomic, strong) SSJEditableCollectionView *collectionView;

@property(nonatomic, strong) SSJBooksHeaderView *header;

//@property(nonatomic, strong) SSJBooksParentSelectView *parentSelectView;

@property(nonatomic, strong) SSJBooksAdView *adView;

@property (nonatomic, strong) SSJBooksTypeEditAlertView *editAlertView;

@property (nonatomic, strong) SSJBooksTypeDeletionAuthCodeAlertView *authCodeAlertView;

@property(nonatomic, strong) SSJBannerNetworkService *adService;

@property (nonatomic, strong) NSString *currentBooksId;

@property(nonatomic, strong) UIButton *rightButton;

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
    [self.collectionView registerClass:[SSJBooksCollectionViewCell class] forCellWithReuseIdentifier:SSJBooksTypeCellIdentifier];
    [self.collectionView registerClass:[SSJBooksHeadeCollectionrReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SSJBooksTypeCellHeaderIdentifier];
    
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
    NSString *bookName;
    NSString *bookId;
    if (indexPath.section == 0) {//个人
       SSJBooksTypeItem *privateItem = (SSJBooksTypeItem *)[self.privateBooksDataitems ssj_safeObjectAtIndex:indexPath.row];
        bookName = privateItem.booksName;
        bookId = privateItem.booksId;
        if ([bookName isEqualToString:@"添加账本"]) {
            [self newAndEditeBooksWiteItem:privateItem];
        }
        
    } else if(indexPath.section == 1) {//共享
        SSJShareBookItem *shareItem = (SSJShareBookItem *)[self.shareBooksDataItems ssj_safeObjectAtIndex:indexPath.row];
        bookName = shareItem.booksName;
        bookId = shareItem.booksId;
        if ([bookName isEqualToString:@"添加账本"]) {
            [self newAndEditeBooksWiteItem:shareItem];
        }
    }
        if ([bookName isEqualToString:@"添加账本"]) {
        } else {
            [SSJAnaliyticsManager event:@"change_account_book" extra:bookName
             ];
            @weakify(self);
            [SSJUserTableManager updateCurrentBooksId:bookId success:^{
                @strongify(self);
                self.currentBooksId = bookId;
                [self.collectionView reloadData];
                [self.mm_drawerController closeDrawerAnimated:YES completion:NULL];
            } failure:^(NSError * _Nonnull error) {
                [SSJAlertViewAdapter showError:error];
            }];
        }
//    }
}

- (void)newAndEditeBooksWiteItem:(__kindof SSJBaseCellItem *)item {
    SSJNewOrEditeBooksViewController *booksEditeVc = [[SSJNewOrEditeBooksViewController alloc]init];
    booksEditeVc.bookItem = item;
    [self.navigationController pushViewController:booksEditeVc animated:YES];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.privateBooksDataitems.count;
    } else if (section == 1) {
        return self.shareBooksDataItems.count;
    }
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSJBooksCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:SSJBooksTypeCellIdentifier forIndexPath:indexPath];
    cell.curretSelectedBookId = self.currentBooksId;
    if (indexPath.section == 0) {
        SSJBooksTypeItem *privateItem = [self.privateBooksDataitems ssj_safeObjectAtIndex:indexPath.row];
        cell.booksTypeItem = privateItem;
    } else if (indexPath.section == 1) {
        SSJShareBookItem *shareItem = [self.shareBooksDataItems ssj_safeObjectAtIndex:indexPath.row];
        cell.booksTypeItem = shareItem;
    }
    @weakify(self);
    cell.editBookAction = ^{
        @strongify(self);
        [self.editAlertView show];
    };
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    //如果是头视图
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        SSJBooksHeadeCollectionrReusableView *resuableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:SSJBooksTypeCellHeaderIdentifier forIndexPath:indexPath];
        resuableView.titleStr = [self.headerTitleArray ssj_safeObjectAtIndex:indexPath.section];
        return resuableView;
    }
    return nil;
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return (CGSize){SSJSCREENWITH,65};
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(12, 18, 0, 12);
}

#pragma mark - SSJEditableCollectionViewDelegate
- (BOOL)collectionView:(SSJEditableCollectionView *)collectionView shouldBeginEditingWhenPressAtIndexPath:(NSIndexPath *)indexPath{
    [SSJAnaliyticsManager event:@"fund_sort"];
    if (indexPath.row == self.privateBooksDataitems.count - 1) {
        return NO;
    }
    return YES;
}

- (BOOL)collectionView:(SSJEditableCollectionView *)collectionView shouldMoveCellAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    if (toIndexPath.row == self.privateBooksDataitems.count - 1) {
        return NO;
    }
    return YES;
}

- (void)collectionView:(SSJEditableCollectionView *)collectionView didBeginEditingWhenPressAtIndexPath:(NSIndexPath *)indexPath{
    self.rightButton.selected = NO;
    [self rightButtonClicked:self.rightButton];
}

- (void)collectionViewDidEndEditing:(SSJEditableCollectionView *)collectionView{
    [SSJBooksTypeStore saveBooksOrderWithItems:self.privateBooksDataitems sucess:^{
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
    if (fromIndexPath.section == 0) {
        SSJBooksTypeItem *currentItem = [self.privateBooksDataitems ssj_safeObjectAtIndex:fromIndexPath.row];
        [self.privateBooksDataitems removeObjectAtIndex:fromIndexPath.row];
        [self.privateBooksDataitems insertObject:currentItem atIndex:toIndexPath.row];
    } else if (fromIndexPath.section == 1) {
        SSJShareBookItem *shareCurrentItem = [self.shareBooksDataItems ssj_safeObjectAtIndex:fromIndexPath.row];
        [self.shareBooksDataItems removeObjectAtIndex:fromIndexPath.row];
        [self.shareBooksDataItems insertObject:shareCurrentItem atIndex:toIndexPath.row];
    }
    
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
    for (SSJBooksTypeItem *item in self.privateBooksDataitems) {
        if (![item.booksName isEqualToString:@"添加账本"]) {
            item.editeModel = self.rightButton.isSelected;
        }
    }
    
    for (SSJShareBookItem *shareItem in self.shareBooksDataItems) {
        if (![shareItem.booksName isEqualToString:@"添加账本"]) {
            shareItem.editing = self.rightButton.isSelected;
        }
    }
    [self.collectionView reloadData];
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
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
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
        _header = [[SSJBooksHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 164)];
        __weak typeof(self) weakSelf = self;
        _header.buttonClickBlock = ^(){
            [SSJAnaliyticsManager event:@"account_all_booksType"];
            SSJSummaryBooksViewController *summaryVc = [[SSJSummaryBooksViewController alloc]init];
            [weakSelf.navigationController pushViewController:summaryVc animated:YES];
        };
    }
    return _header;
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

- (NSArray *)headerTitleArray {
    if (!_headerTitleArray) {
        _headerTitleArray = @[@"个人账本",@"共享账本"];
    }
    return _headerTitleArray;
}

- (NSMutableArray<SSJBooksTypeItem *> *)privateBooksDataitems {
    if (!_privateBooksDataitems) {
        _privateBooksDataitems = [NSMutableArray array];
    }
    return _privateBooksDataitems;
}

- (NSMutableArray<SSJShareBookItem *> *)shareBooksDataItems {
    if (!_shareBooksDataItems) {
        _shareBooksDataItems = [NSMutableArray array];
    }
    return _shareBooksDataItems;
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
        //查询个人账本
        [SSJBooksTypeStore queryForBooksListWithSuccess:^(NSMutableArray<SSJBooksTypeItem *> *result) {
            weakSelf.privateBooksDataitems = result;
//            [weakSelf.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            [weakSelf.collectionView reloadData];
        } failure:^(NSError *error) {
            [SSJAlertViewAdapter showError:error];
        }];
        
        //查询共享账本
        [SSJBooksTypeStore queryForShareBooksListWithSuccess:^(NSMutableArray<SSJShareBookItem *> *result) {
            weakSelf.shareBooksDataItems = result;
//            [weakSelf.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
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
        [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [SSJUserTableManager updateCurrentBooksId:SSJUSERID() success:^{
                [subscriber sendCompleted];
            } failure:^(NSError * _Nonnull error) {
                [subscriber sendError:error];
            }];
            return nil;
        }] then:^RACSignal *{
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [SSJBooksTypeStore deleteBooksTypeWithbooksItems:@[self.editBooksItem] deleteType:type Success:^{
                    [subscriber sendCompleted];
                } failure:^(NSError *error) {
                    [subscriber sendError:error];
                }];
                return nil;
            }];
        }] subscribeError:^(NSError *error) {
            [SSJAlertViewAdapter showError:error];
        } completed:^{
            self.rightButton.selected = NO;
            [self.collectionView endEditing];
            for (SSJBooksTypeItem *item in self.privateBooksDataitems) {
                item.editeModel = NO;
            }
            self.adView.hidden = NO;
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
            [self getDateFromDB];
        }];
    };
    
}

- (void)enterBooksTypeEditController {
    [SSJAnaliyticsManager event:@"accountbook_edit"];
    SSJNewOrEditeBooksViewController *booksEditeVc = [[SSJNewOrEditeBooksViewController alloc]init];
    booksEditeVc.bookItem = self.editBooksItem;
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
