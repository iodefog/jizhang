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

@interface SSJBooksTypeSelectViewController ()<SSJEditableCollectionViewDelegate,SSJEditableCollectionViewDataSource>

@property(nonatomic, strong) SSJEditableCollectionView *collectionView;

@property(nonatomic, strong) NSMutableArray *items;

@property(nonatomic, strong) UIButton *deleteButton;

@property(nonatomic, strong) UIButton *editeButton;

@property(nonatomic, strong) NSMutableArray *selectedBooks;

@property(nonatomic, strong) UIButton *rightButton;

@property(nonatomic, strong) SSJBooksHeaderView *header;

@property(nonatomic, strong) SSJBooksParentSelectView *parentSelectView;

@property(nonatomic, strong) SSJBooksAdView *adView;

@property(nonatomic, strong) SSJBannerNetworkService *adService;

@end

@implementation SSJBooksTypeSelectViewController{
    NSString *_selectBooksId;
    NSIndexPath *_editingIndex;
    BOOL _editeModel;
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
    [self.view addSubview:self.editeButton];
    [self.view addSubview:self.deleteButton];
    [self.view addSubview:self.adView];
    self.selectedBooks = [NSMutableArray arrayWithCapacity:0];
    [self.collectionView registerClass:[SSJBooksTypeCollectionViewCell class] forCellWithReuseIdentifier:SSJBooksTypeCellIdentifier];
    [self.collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    _editeModel = NO;
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
    [self.selectedBooks removeAllObjects];
    _editeModel = NO;
    self.rightButton.selected = NO;
    self.editeButton.hidden = YES;
    self.deleteButton.hidden = YES;
    self.editeButton.enabled = NO;
    [self.collectionView endEditing];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.editeButton.size = CGSizeMake(self.view.width * 0.58, 55);
    self.editeButton.leftBottom = CGPointMake(0, self.view.height);
    self.deleteButton.size = CGSizeMake(self.view.width * 0.42, 55);
    self.deleteButton.leftBottom = CGPointMake(self.editeButton.right, self.view.height);
    self.header.width = self.view.width;
    self.adView.leftBottom = CGPointMake(0, self.view.height);
    self.adView.width = self.view.width;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSJBooksTypeItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    if (_editeModel) {
        if (![item.booksName isEqualToString:@"添加账本"]) {
            if ([self.selectedBooks containsObject:item]) {
                [self.selectedBooks removeObject:item];
                item.selectToEdite = NO;
            }else{
                [self.selectedBooks addObject:item];
                item.selectToEdite = YES;
            }
            if (self.selectedBooks.count > 1  || !self.selectedBooks.count) {
                self.editeButton.enabled = NO;
            }else{
                self.editeButton.enabled = YES;
            }
        }else{
            SSJBooksEditeOrNewViewController *booksEditeVc = [[SSJBooksEditeOrNewViewController alloc]init];
            [self.navigationController pushViewController:booksEditeVc animated:YES];
        }
    }else{
        if (![item.booksName isEqualToString:@"添加账本"]) {
            [SSJAnaliyticsManager event:@"change_account_book" extra:item.booksName
             ];
            SSJSelectBooksType(item.booksId);
            [self.collectionView reloadData];
            [self.mm_drawerController closeDrawerAnimated:YES completion:NULL];
        } else {
            [self.parentSelectView show];

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
    NSString *booksid = SSJGetCurrentBooksType();
    SSJBooksTypeItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
//    __weak typeof(self) weakSelf = self;
    SSJBooksTypeCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:SSJBooksTypeCellIdentifier forIndexPath:indexPath];
    cell.editeModel = _editeModel;
    if ([self.selectedBooks containsObject:item]) {
        cell.selectToEdite = YES;
    }else{
        cell.selectToEdite = NO;
    }
    if ([item.booksId isEqualToString:booksid]) {
        cell.isSelected = YES;
    }else{
        cell.isSelected = NO;
    }
    __weak typeof(self) weakSelf = self;
    cell.selectButtonClickedBlock = ^(SSJBooksTypeItem *item){
        if ([weakSelf.selectedBooks containsObject:item]) {
            [weakSelf.selectedBooks removeObject:item];
            item.selectToEdite = NO;
        }else{
            [weakSelf.selectedBooks addObject:item];
            item.selectToEdite = YES;
        }
        if (self.selectedBooks.count > 1  || !self.selectedBooks.count) {
            self.editeButton.enabled = NO;
        }else{
            self.editeButton.enabled = YES;
        }
    };
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
    return CGSizeMake(itemWidth, 100);
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
    _editeModel = YES;
    self.rightButton.selected = YES;
    self.editeButton.hidden = NO;
    self.deleteButton.hidden = NO;
    self.adView.hidden = YES;
    for (SSJBooksTypeItem *item in self.items) {
        item.editeModel = self.rightButton.isSelected;
    }
}

- (void)collectionViewDidEndEditing:(SSJEditableCollectionView *)collectionView{
    [SSJBooksTypeStore saveBooksOrderWithItems:self.items sucess:^{
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
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
    _editeModel = !_editeModel;
    self.rightButton.selected = !self.rightButton.isSelected;
    self.editeButton.hidden = !self.rightButton.isSelected;
    self.deleteButton.hidden = !self.rightButton.isSelected;
    if (self.rightButton.isSelected) {
        self.adView.hidden = YES;
        [SSJAnaliyticsManager event:@"accountbook_manage"];
    }else{
        self.adView.hidden = NO;
        [self.collectionView endEditing];
        [self.selectedBooks removeAllObjects];
    }
    for (SSJBooksTypeItem *item in self.items) {
        item.editeModel = self.rightButton.isSelected;
        item.selectToEdite = NO;
    }
}

- (void)editeButtonClicked:(id)sender{
    [SSJAnaliyticsManager event:@"accountbook_edit"];

    SSJBooksEditeOrNewViewController *booksEditeVc = [[SSJBooksEditeOrNewViewController alloc]init];
    booksEditeVc.item = [self.selectedBooks firstObject];
    [self.navigationController pushViewController:booksEditeVc animated:YES];
}

- (void)deleteButtonClicked:(id)sender{
    if (self.selectedBooks.count) {
        __weak typeof(self) weakSelf = self;
        SSJBooksTypeItem *defualtItem = [[SSJBooksTypeItem alloc]init];
        defualtItem.booksId = SSJUSERID();
        if ([self.selectedBooks containsObject:defualtItem]) {
            [CDAutoHideMessageHUD showMessage:@"日常账本不能删除哦"];
            return;
        }
        SSJAlertViewAction *comfirmAction = [SSJAlertViewAction actionWithTitle:@"删除" handler:^(SSJAlertViewAction * _Nonnull action) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"删除该账本后，是否将涉及相关资金账户的流水一并删除？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *reserve = [UIAlertAction actionWithTitle:@"保留资金流水" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf deleteBooksWithType:0];
            }];
            UIAlertAction *destructive = [UIAlertAction actionWithTitle:@"一并删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf deleteBooksWithType:1];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:reserve];
            [alert addAction:destructive];
            [alert addAction:cancel];
            [weakSelf presentViewController:alert animated:YES completion:NULL];
        }];
        SSJAlertViewAction *cancelAction = [SSJAlertViewAction actionWithTitle:@"取消" handler:NULL];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"你确定要删除该账本吗?" action:cancelAction , comfirmAction, nil];

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
        _collectionView=[[SSJEditableCollectionView alloc] initWithFrame:CGRectMake(0, self.header.bottom, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM - 169) collectionViewLayout:flowLayout];
        _collectionView.movedCellScale = 1.08;
        _collectionView.editDelegate=self;
        _collectionView.editDataSource=self;
        _collectionView.exchangeCellRegion = UIEdgeInsetsMake(5, 0, 5, 0);
        _collectionView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return _collectionView;
}

-(UIButton *)editeButton{
    if (!_editeButton) {
        _editeButton = [[UIButton alloc]init];
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc]initWithString:@"编辑 (单选)"];
        [attributedTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, 2)];
        [attributedTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(3, 4)];
        [attributedTitle addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:NSMakeRange(0, attributedTitle.length)];
        NSMutableAttributedString *attributedDisableTitle = [[NSMutableAttributedString alloc]initWithString:@"编辑 (单选)"];
        [attributedDisableTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, 2)];
        [attributedDisableTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(3, 4)];
        [attributedDisableTitle addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] range:NSMakeRange(0, attributedTitle.length)];
        [_editeButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
        [_editeButton setAttributedTitle:attributedDisableTitle forState:UIControlStateDisabled];
        _editeButton.enabled = NO;
        _editeButton.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];                                                                                                                                                                                                                                                                                                                                                                                       
        [_editeButton addTarget:self action:@selector(editeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _editeButton.hidden = YES;

    }
    return _editeButton;
}

-(UIButton *)deleteButton{
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc]init];
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:20];
        _deleteButton.backgroundColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:0.2];
        [_deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.hidden = YES;
    }
    return _deleteButton;
}

-(UIButton *)rightButton{
    if (!_rightButton) {
        _rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
        [_rightButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor] forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor] forState:UIControlStateSelected];
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

//-(SSJBooksTypeEditeView *)booksEditeView{
//    if (!_booksEditeView) {
//        _booksEditeView = [[SSJBooksTypeEditeView alloc]init];
//        __weak typeof(self) weakSelf = self;
//        _booksEditeView.comfirmButtonClickedBlock = ^(SSJBooksTypeItem *item){
//            item.cwriteDate = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
//            item.userId = SSJUSERID();
//            [SSJBooksTypeStore saveBooksTypeItem:item];
//            [weakSelf getDateFromDB];
//            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
//        };
//        __block NSString *booksid = SSJGetCurrentBooksType();
//        _booksEditeView.deleteButtonClickedBlock = ^(SSJBooksTypeItem *item){
//            if ([item.booksId isEqualToString:booksid]) {
//                SSJSelectBooksType(SSJUSERID());
//            }
//            [weakSelf getDateFromDB];
//            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
//        };
//        _booksEditeView.editeViewDismissBlock = ^(){
//            _editingIndex = nil;
//        };
//    }
//    return _booksEditeView;
//}

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
        
    }];
    
    [SSJBooksTypeStore queryForBooksListWithSuccess:^(NSMutableArray<SSJBooksTypeItem *> *result) {
        weakSelf.items = [NSMutableArray arrayWithArray:result];
        [weakSelf.collectionView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

- (void)deleteBooksWithType:(BOOL)type{
    for (SSJBooksTypeItem *booksItem in self.selectedBooks) {
            if ([booksItem.booksId isEqualToString:SSJGetCurrentBooksType()]) {
                SSJSelectBooksType(SSJUSERID());
        };
    }
    __weak typeof(self) weakSelf = self;
    [SSJBooksTypeStore deleteBooksTypeWithbooksItems:self.selectedBooks deleteType:type Success:^{
        weakSelf.rightButton.selected = NO;
        weakSelf.deleteButton.hidden = YES;
        weakSelf.editeButton.hidden = YES;
        [weakSelf.collectionView endEditing];
        for (SSJBooksTypeItem *item in self.items) {
            item.editeModel = NO;
        }
        self.adView.hidden = NO;
        _editeModel = NO;
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        [self.selectedBooks removeAllObjects];
        [weakSelf getDateFromDB];
    } failure:^(NSError *error) {
        
    }];
}

-(void)updateAppearanceAfterThemeChanged{
    [super updateAppearanceAfterThemeChanged];
    self.collectionView.backgroundColor = [UIColor ssj_colorWithHex:@"ffffff" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    [self.rightButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor] forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.naviBarTintColor] forState:UIControlStateSelected];
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc]initWithString:@"编辑 (单选)"];
    [attributedTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, 2)];
    [attributedTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(3, 4)];
    [attributedTitle addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] range:NSMakeRange(0, attributedTitle.length)];
    NSMutableAttributedString *attributedDisableTitle = [[NSMutableAttributedString alloc]initWithString:@"编辑 (单选)"];
    [attributedDisableTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, 2)];
    [attributedDisableTitle addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(3, 4)];
    [attributedDisableTitle addAttribute:NSForegroundColorAttributeName value:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] range:NSMakeRange(0, attributedTitle.length)];
    [self.editeButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    [self.editeButton setAttributedTitle:attributedDisableTitle forState:UIControlStateDisabled];
    self.editeButton.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
    self.deleteButton.backgroundColor = [UIColor ssj_colorWithHex:@"#ffffff" alpha:0.2];
    [self.deleteButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage ssj_imageWithColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.summaryBooksHeaderColor alpha:SSJ_CURRENT_THEME.summaryBooksHeaderAlpha] size:CGSizeMake(10, 64)] forBarMetrics:UIBarMetricsDefault];
    [self.header updateAfterThemeChange];
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
