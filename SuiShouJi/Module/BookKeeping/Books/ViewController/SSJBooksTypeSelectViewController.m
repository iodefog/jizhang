//
//  SSJBooksTypeSelectViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/5/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

static NSString * SSJBooksTypeCellIdentifier = @"booksTypeCell";
static NSString * SSJBooksTypeCellHeaderIdentifier = @"SSJBooksTypeCellHeaderIdentifier";


#import "SSJBooksTypeSelectViewController.h"
#import "SSJBooksMergeViewController.h"
#import "SSJBooksTypeStore.h"
#import "SSJBooksTypeItem.h"
#import "SSJBooksCollectionViewCell.h"
#import "UIViewController+MMDrawerController.h"
#import "SSJLoginVerifyPhoneViewController+SSJLoginCategory.h"
#import "SSJAdWebViewController.h"
#import "SSJAdWebViewController.h"
#import "SSJBooksHeaderView.h"
#import "SSJDataSynchronizer.h"

#import "SSJNewOrEditeBooksViewController.h"
#import "SSJEditableCollectionView.h"
#import "SSJSummaryBooksViewController.h"
#import "SSJInviteCodeJoinViewController.h"
#import "SSJDatabaseQueue.h"
#import "SSJSelectCreateShareBookType.h"
#import "SSJBannerNetworkService.h"
#import "SSJBooksTypeEditAlertView.h"
#import "SSJBooksTypeDeletionAuthCodeAlertView.h"
#import "SSJUserTableManager.h"
#import "SSJBooksHeadeCollectionrReusableView.h"
#import "SSJCreateOrDeleteBooksService.h"
#import "UIViewController+SSJPageFlow.h"
#import "SSJInviteCodeJoinSuccessView.h"

@interface SSJBooksTypeSelectViewController ()<SSJEditableCollectionViewDelegate,SSJEditableCollectionViewDataSource>

@property (nonatomic, strong) NSArray *headerTitleArray;

/**个人账本列表*/
@property(nonatomic, strong) NSMutableArray <SSJBooksTypeItem *>*privateBooksDataitems;

/**共享账本列表*/
@property (nonatomic, strong) NSMutableArray <SSJShareBookItem *>*shareBooksDataItems;

@property(nonatomic, strong) __kindof SSJBaseCellItem *editBooksItem;

@property(nonatomic, strong) SSJEditableCollectionView *collectionView;

@property(nonatomic, strong) SSJBooksHeaderView *header;

//@property(nonatomic, strong) SSJBooksParentSelectView *parentSelectView;

//@property(nonatomic, strong) SSJBooksAdView *adView;

@property (nonatomic, strong) SSJBooksTypeEditAlertView *editAlertView;

@property (nonatomic, strong) SSJBooksTypeDeletionAuthCodeAlertView *authCodeAlertView;

//@property(nonatomic, strong) SSJBannerNetworkService *adService;

@property (nonatomic, strong) NSString *currentBooksId;

@property(nonatomic, strong) UIButton *rightButton;

@property (nonatomic, strong) SSJSelectCreateShareBookType *createShareBookTypeView;

/**是否显示新建账本成功动画*/
@property (nonatomic, assign,getter=isShowCreateBookAnimation) BOOL showCreateBookAnimation;

@property (nonatomic, strong) SSJCreateOrDeleteBooksService *deleteBookService;

/**成功暗号加入后弹框*/
@property (nonatomic, strong) SSJInviteCodeJoinSuccessView *inviteCodeJoinSuccessView;
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
//    [self.view addSubview:self.adView];
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
//    [self.adService requestBannersList];
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
//    self.adView.leftBottom = CGPointMake(0, self.view.height);
//    self.adView.width = self.view.width;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isShowCreateBookAnimation) {
        //刷新动画
        //取出在数组中的位置
        self.showCreateBookAnimation = NO;
        for (SSJBooksTypeItem *item in self.privateBooksDataitems) {
            if ([item.booksId isEqualToString:self.currentBooksId]) {
                NSInteger index = [self.privateBooksDataitems indexOfObject:item];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                SSJBooksCollectionViewCell *cell1 = (SSJBooksCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                [cell1 animationAfterCreateBook];
                return ;
            }
        }
        
        for (SSJShareBookItem *sItem in self.shareBooksDataItems) {
            if ([sItem.booksId isEqualToString:self.currentBooksId]) {
                NSInteger index = [self.shareBooksDataItems indexOfObject:sItem];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:1];
                SSJBooksCollectionViewCell *cell1 = (SSJBooksCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                [cell1 animationAfterCreateBook];
            }
        }
    }
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
        if (!privateItem.booksId.length && [bookName isEqualToString:@"添加账本"]) {
            [SSJAnaliyticsManager event:@"add_account_book"];
            [self newAndEditeBooksWiteItem:privateItem];
            return;
        }
        SSJSaveBooksCategory(SSJBooksCategoryPersional);
        
    } else if(indexPath.section == 1) {//共享
        SSJShareBookItem *shareItem = (SSJShareBookItem *)[self.shareBooksDataItems ssj_safeObjectAtIndex:indexPath.row];
        bookName = shareItem.booksName;
        bookId = shareItem.booksId;
        if (!bookId.length && [bookName isEqualToString:@"添加账本"]) {
            if (SSJIsUserLogined()) {
                [SSJAnaliyticsManager event:@"sb_add_share_book"];
                [self.createShareBookTypeView show];
            } else {
                //去登录
//                SSJLoginVerifyPhoneViewController *loginVC = [[SSJLoginVerifyPhoneViewController alloc] init];
//                [self.navigationController pushViewController:loginVC animated:YES];
                [SSJLoginVerifyPhoneViewController reloginIfNeeded];
            }
            return;
        }
        SSJSaveBooksCategory(SSJBooksCategoryPublic);
    }
    if (bookId.length) {

        [SSJAnaliyticsManager event:@"change_account_book" extra:bookName
         ];
        //更新当前选中账本
        [self updateCurrentBookWithBookId:bookId];
    }
}

- (void)newAndEditeBooksWiteItem:(__kindof SSJBaseCellItem *)item {
    SSJNewOrEditeBooksViewController *booksEditeVc = [[SSJNewOrEditeBooksViewController alloc]init];
    @weakify(self);
    booksEditeVc.saveBooksBlock = ^(NSString *booksId) {
        @strongify(self);
        [self updateCurrentBookAfterCreateBooksWithBookId:booksId];
    };

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

    cell.editBookAction = ^(__kindof SSJBaseCellItem * _Nonnull booksTypeItem) {
        @strongify(self);
        self.editBooksItem = booksTypeItem;
        self.editAlertView.booksItem = booksTypeItem;
        if ([booksTypeItem isKindOfClass:[SSJBooksTypeItem class]]) {
            [self.editAlertView showWithBookCategory: SSJBooksCategoryPersional];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 5;
            style.alignment = NSTextAlignmentCenter;
            self.authCodeAlertView.message = [[NSAttributedString alloc] initWithString:@"删除后，此账本数据将难以恢复\n仍然删除，请输入下列验证码" attributes:@{NSParagraphStyleAttributeName:style}];
            self.authCodeAlertView.sureButtonTitle = @"删除";
        } else if ([booksTypeItem isKindOfClass:[SSJShareBookItem class]]) {
            [self.editAlertView showWithBookCategory: SSJBooksCategoryPublic];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 5;
            style.alignment = NSTextAlignmentCenter;
            self.authCodeAlertView.message = [[NSAttributedString alloc] initWithString:@"确认退出此共享账本，\n请输入下列验证码" attributes:@{NSParagraphStyleAttributeName:style}];
            self.authCodeAlertView.sureButtonTitle = @"退出";
        }
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
    if ((indexPath.row == self.privateBooksDataitems.count - 1 && indexPath.section == 0) || (indexPath.section == 1 && indexPath.row == self.shareBooksDataItems.count - 1)) {
        return NO;
    }
    return YES;
}

- (BOOL)collectionView:(SSJEditableCollectionView *)collectionView shouldMoveCellAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    if ((toIndexPath.row == self.privateBooksDataitems.count - 1 && toIndexPath.section == 0) || (toIndexPath.section == 1 && toIndexPath.row == self.shareBooksDataItems.count - 1)) {
        return NO;
    }
    
    if ((fromIndexPath.row == self.privateBooksDataitems.count - 1 && fromIndexPath.section == 0) || (fromIndexPath.section == 1 && fromIndexPath.row == self.shareBooksDataItems.count - 1)) {
        return NO;
    }
    
    if (fromIndexPath.section != toIndexPath.section) {
        return NO;
    }
    return YES;
}

- (void)collectionView:(SSJEditableCollectionView *)collectionView didBeginEditingWhenPressAtIndexPath:(NSIndexPath *)indexPath{
    self.rightButton.selected = NO;
    [self rightButtonClicked:self.rightButton];
}

- (void)collectionViewDidEndEditing:(SSJEditableCollectionView *)collectionView{

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
        [SSJBooksTypeStore saveBooksOrderWithItems:self.privateBooksDataitems sucess:^{
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        } failure:^(NSError *error) {
            SSJPRINT(@"%@",[error localizedDescription]);
        }];
    } else if (fromIndexPath.section == 1) {
        SSJShareBookItem *shareCurrentItem = [self.shareBooksDataItems ssj_safeObjectAtIndex:fromIndexPath.row];
        [self.shareBooksDataItems removeObjectAtIndex:fromIndexPath.row];
        [self.shareBooksDataItems insertObject:shareCurrentItem atIndex:toIndexPath.row];
        [SSJBooksTypeStore saveShareBooksOrderWithItems:self.shareBooksDataItems sucess:^{
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        } failure:^(NSError *error) {
            SSJPRINT(@"%@",[error localizedDescription]);
        }];
    }
}

- (BOOL)collectionView:(SSJEditableCollectionView *)collectionView shouldBeginMovingCellAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.row == self.privateBooksDataitems.count - 1 && indexPath.section == 0) || (indexPath.section == 1 && indexPath.row == self.shareBooksDataItems.count - 1)) {
        return NO;
    }
    return YES;
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service{
    if (service == self.deleteBookService) {
        if ([service.returnCode isEqualToString:@"1"]) {
            __weak __typeof(self)weakSelf = self;
            [SSJBooksTypeStore deleteShareBooksWithShareCharge:self.deleteBookService.shareChargeArray shareMember:self.deleteBookService.shareMemberArray bookId:((SSJShareBookItem *)self.editBooksItem).booksId  sucess:^(BOOL bookstypeHasChange){
                //更新当前选中账本
                if (bookstypeHasChange) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SSJBooksTypeDidChangeNotification object:nil];
                }
                weakSelf.rightButton.selected = NO;
                [weakSelf.collectionView endEditing];
                for (SSJBooksTypeItem *item in weakSelf.privateBooksDataitems) {
                    item.editeModel = NO;
                }
                [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
                [weakSelf getDateFromDB];
            } failure:^(NSError *error) {
                [SSJAlertViewAdapter showError:error];
            }];
        }
    }
}


#pragma mark - Event
- (void)rightButtonClicked:(id)sender{
    self.rightButton.selected = !self.rightButton.isSelected;
    if (self.rightButton.isSelected) {
//        self.adView.hidden = YES;
        [SSJAnaliyticsManager event:@"accountbook_manage"];
        [self.collectionView beginEditing];
    }else{
//        self.adView.hidden = NO;
        [self.collectionView endEditing];
    }
    for (SSJBooksTypeItem *item in self.privateBooksDataitems) {
        if (item.booksId.length) {
            item.editeModel = self.rightButton.isSelected;
        }
    }
    
    for (SSJShareBookItem *shareItem in self.shareBooksDataItems) {
        if (shareItem.booksId.length) {
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

//- (SSJBooksAdView *)adView{
//    if (!_adView) {
//        _adView = [[SSJBooksAdView alloc]init];
//        __weak typeof(self) weakSelf = self;
//        _adView.imageClickBlock = ^(){
//            SSJAdWebViewController *webVc = [SSJAdWebViewController webViewVCWithURL:[NSURL URLWithString:weakSelf.adService.item.booksAdItem.adUrl]];
//            [weakSelf.navigationController pushViewController:webVc animated:YES];
//        };
//        _adView.closeButtonClickBlock = ^(){
//            kNeedBannerDisplay = NO;
//            weakSelf.adView.hidden = YES;
//        };
//        _adView.hidden = YES;
//    }
//    return _adView;
//}

- (SSJBooksTypeEditAlertView *)editAlertView {
    if (!_editAlertView) {
        @weakify(self);
        _editAlertView = [[SSJBooksTypeEditAlertView alloc] init];
        _editAlertView.editHandler = ^{
            @strongify(self);
            [self enterBooksTypeEditController];
        };
        _editAlertView.deleteHandler = ^{
            @strongify(self);
            SSJBooksTypeItem *persionalBook = self.editBooksItem;
            if ([persionalBook.booksId isEqualToString:SSJUSERID()]) {
                [CDAutoHideMessageHUD showMessage:@"日常账本无法删除"];
            } else {
                [self.authCodeAlertView show];
            }
        };
        _editAlertView.transferHandler = ^{
            @strongify(self);
            SSJBooksMergeViewController *mergeVc = [[SSJBooksMergeViewController alloc] init];
            mergeVc.transferOutBooksItem = self.editAlertView.booksItem;
            [self.navigationController pushViewController:mergeVc animated:YES];
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

//- (SSJBannerNetworkService *)adService{
//    if (!_adService) {
//        _adService = [[SSJBannerNetworkService alloc]initWithDelegate:self];
//        _adService.httpMethod = SSJBaseNetworkServiceHttpMethodGET;
//    }
//    return _adService;
//}

- (SSJCreateOrDeleteBooksService *)deleteBookService {
    if (!_deleteBookService) {
        _deleteBookService = [[SSJCreateOrDeleteBooksService alloc] initWithDelegate:self];
    }
    return _deleteBookService;
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

- (SSJSelectCreateShareBookType *)createShareBookTypeView {
    if (!_createShareBookTypeView) {
        _createShareBookTypeView = [[SSJSelectCreateShareBookType alloc] init];
        __weak __typeof(self)weakSelf = self;
        _createShareBookTypeView.selectCreateShareBookBlock = ^(NSInteger selectParent) {
            if (selectParent == 0) {
                //新建共享
                [weakSelf newAndEditeBooksWiteItem:[[SSJShareBookItem alloc] init]];
                [SSJAnaliyticsManager event:@"sb_create_share_book"];
                
            } else if (selectParent == 1) {
                //暗号加入
                SSJInviteCodeJoinViewController *inviteVc = [[SSJInviteCodeJoinViewController alloc] init];
                [SSJAnaliyticsManager event:@"sb_anhao_join_share_book"];
                inviteVc.inviteCodeJoinBooksBlock = ^(NSString *bookName) {
                    //保存账本类型
                    SSJSaveBooksCategory(SSJBooksCategoryPublic);
                    weakSelf.showCreateBookAnimation = YES;
                    //弹出加入账本成功弹窗
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf.inviteCodeJoinSuccessView showWithDesc:[NSString stringWithFormat:@"你已成功加入共享账本【%@】，今后，将和ta一起，共同记账，祝你们记账愉快～",bookName]];
                    });
                };
                [weakSelf.navigationController pushViewController:inviteVc animated:YES];
            }
        };
    }
    return _createShareBookTypeView;
}

- (SSJInviteCodeJoinSuccessView *)inviteCodeJoinSuccessView {
    if (!_inviteCodeJoinSuccessView) {
        _inviteCodeJoinSuccessView = [[SSJInviteCodeJoinSuccessView alloc] initWithFrame:CGRectMake(0, 0, 280, 328)];
    }
    return _inviteCodeJoinSuccessView;
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
            //添加账本
            SSJBooksTypeItem *item = [[SSJBooksTypeItem alloc]init];
            item.booksName = @"添加账本";
            SSJFinancingGradientColorItem *colorItem = [[SSJFinancingGradientColorItem alloc] init];
            colorItem.startColor = colorItem.endColor = @"#FFFFFF";
            item.booksColor = colorItem;
            [result addObject:item];
            
            weakSelf.privateBooksDataitems = result;
            [weakSelf.collectionView reloadData];
        } failure:^(NSError *error) {
            [SSJAlertViewAdapter showError:error];
        }];
        
        //如果登录
        if (SSJIsUserLogined()) {
            //查询共享账本
            [SSJBooksTypeStore queryForShareBooksListWithSuccess:^(NSMutableArray<SSJShareBookItem *> *result) {
                //最后一个添加账本
                SSJShareBookItem *lastItem = [[SSJShareBookItem alloc]init];
                lastItem.booksName = @"添加账本";
                SSJFinancingGradientColorItem *colorItem = [[SSJFinancingGradientColorItem alloc] init];
                colorItem.startColor = colorItem.endColor = @"#FFFFFF";
                lastItem.booksColor = colorItem;
                [result addObject:lastItem];
                weakSelf.shareBooksDataItems = result;
                
                [weakSelf.collectionView reloadData];
            } failure:^(NSError *error) {
                [SSJAlertViewAdapter showError:error];
            }];
        } else {
            NSMutableArray *addArray = [NSMutableArray array];
            //添加账本
            SSJShareBookItem *lastItem = [[SSJShareBookItem alloc]init];
            lastItem.booksName = @"添加账本";
            SSJFinancingGradientColorItem *colorItem = [[SSJFinancingGradientColorItem alloc] init];
            colorItem.startColor = colorItem.endColor = @"#FFFFFF";
            lastItem.booksColor = colorItem;
            [addArray addObject:lastItem];
            weakSelf.shareBooksDataItems = addArray;
        }
        
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
}

- (void)deleteBooksWithType:(BOOL)type{
    NSString *bookId;
    if ([self.editBooksItem isKindOfClass:[SSJBooksTypeItem class]]) {
        bookId = ((SSJBooksTypeItem *)self.editBooksItem).booksId;
    } else if ([self.editBooksItem isKindOfClass:[SSJShareBookItem class]]) {
        bookId = ((SSJShareBookItem *)self.editBooksItem).booksId;
    }

    @weakify(self);
    if ([self.editBooksItem isKindOfClass:[SSJBooksTypeItem class]]) {//个人账本
        [SSJBooksTypeStore deleteBooksTypeWithbooksItems:@[self.editBooksItem] deleteType:type Success:^(BOOL bookstypeHasChange){
            @strongify(self);
            self.rightButton.selected = NO;
            [self.collectionView endEditing];
            for (SSJBooksTypeItem *item in self.privateBooksDataitems) {
                item.editeModel = NO;
            }
            
            if (bookstypeHasChange) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SSJBooksTypeDidChangeNotification object:nil];
            }
            
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
            [self getDateFromDB];
            
        } failure:^(NSError *error) {
            [SSJAlertViewAdapter showError:error];
        }];
    } else if ([self.editBooksItem isKindOfClass:[SSJShareBookItem class]]) {//共享账本
        @strongify(self);
        [self.deleteBookService deleteShareBookWithBookId:bookId memberId:SSJUSERID() memberState:SSJShareBooksMemberStateQuitted];
    }
    
    [self.collectionView endEditing];
    
}

- (void)updateCurrentBookWithBookId:(NSString *)bookId {
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

- (void)updateCurrentBookAfterCreateBooksWithBookId:(NSString *)bookId {
    @weakify(self);
    [SSJUserTableManager updateCurrentBooksId:bookId success:^{
        @strongify(self);
        self.currentBooksId = bookId;
        [self.collectionView reloadData];
        self.showCreateBookAnimation = YES;
        //更新当前账本
//        [[NSNotificationCenter defaultCenter] postNotificationName:SSJBooksTypeDidChangeNotification object:nil];
        //同步
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:nil failure:nil];
        
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showError:error];
    }];
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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.summaryBooksHeaderColor alpha:SSJ_CURRENT_THEME.summaryBooksHeaderAlpha] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    [self.header updateAfterThemeChange];
}

@end
