//
//  SSJBooksTypeSelectViewController.m
//  SuiShouJi
//
//  Created by ricky on 16/5/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

static NSString * SSJBooksTypeCellIdentifier = @"booksTypeCell";

#import "SSJBooksTypeSelectViewController.h"
#import "SSJBooksTypeStore.h"
#import "SSJBooksTypeItem.h"
#import "SSJBooksTypeCollectionViewCell.h"
#import "UIViewController+MMDrawerController.h"
#import "SSJBooksTypeEditeView.h"
#import "SSJDataSynchronizer.h"
#import "SSJBooksEditeOrNewViewController.h"

@interface SSJBooksTypeSelectViewController ()

@property(nonatomic, strong) UICollectionView *collectionView;

@property(nonatomic, strong) NSMutableArray *items;

@property(nonatomic, strong) UIButton *deleteButton;

@property(nonatomic, strong) UIButton *editeButton;

@property(nonatomic, strong) NSMutableArray *selectedBooks;

@property(nonatomic, strong) UIButton *rightButton;

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
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.editeButton];
    [self.view addSubview:self.deleteButton];
    self.selectedBooks = [NSMutableArray arrayWithCapacity:0];
    [self.collectionView registerClass:[SSJBooksTypeCollectionViewCell class] forCellWithReuseIdentifier:SSJBooksTypeCellIdentifier];
    [self.collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    _editeModel = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    self.mm_drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    [MobClick event:@"main_account_book"];
    [self getDateFromDB];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.selectedBooks removeAllObjects];
    _editeModel = NO;
    self.rightButton.selected = NO;
    self.editeButton.hidden = YES;
    self.deleteButton.hidden = YES;
    self.editeButton.enabled = NO;
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
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSJBooksTypeItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    if (_editeModel) {
        if (![item.booksName isEqualToString:@"添加账本"]) {
            if ([self.selectedBooks containsObject:item]) {
                [self.selectedBooks removeObject:item];
            }else{
                [self.selectedBooks addObject:item];
            }
            if (self.selectedBooks.count > 1) {
                self.editeButton.enabled = NO;
            }else{
                self.editeButton.enabled = YES;
            }
            [self.collectionView reloadData];
        }else{
            SSJBooksEditeOrNewViewController *booksEditeVc = [[SSJBooksEditeOrNewViewController alloc]init];
            [self.navigationController pushViewController:booksEditeVc animated:YES];
        }
    }else{
        if (![item.booksName isEqualToString:@"添加账本"]) {
            [MobClick event:@"change_account_book"];
            SSJSelectBooksType(item.booksId);
            [self.collectionView reloadData];
            [self.mm_drawerController closeDrawerAnimated:YES completion:NULL];
            [[NSNotificationCenter defaultCenter]postNotificationName:SSJBooksTypeDidChangeNotification object:nil];
        }else{
            SSJBooksEditeOrNewViewController *booksEditeVc = [[SSJBooksEditeOrNewViewController alloc]init];
            [self.navigationController pushViewController:booksEditeVc animated:YES];
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

#pragma mark - Event
- (void)rightButtonClicked:(id)sender{
    _editeModel = !_editeModel;
    self.rightButton.selected = !self.rightButton.isSelected;
    self.editeButton.hidden = !self.rightButton.isSelected;
    self.deleteButton.hidden = !self.rightButton.isSelected;
    if (self.rightButton.isSelected) {
        [self.selectedBooks removeAllObjects];
    }
    [self.collectionView reloadData];
}

- (void)editeButtonClicked:(id)sender{
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
            [weakSelf deleteBooks];
        }];
        SSJAlertViewAction *cancelAction = [SSJAlertViewAction actionWithTitle:@"取消" handler:NULL];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"删除后关于该账本的流水数据将会被彻底清除哦." action:cancelAction , comfirmAction, nil];

    }
}

#pragma mark - Getter
-(UICollectionView *)collectionView{
    if (_collectionView==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        if (SSJSCREENWITH == 320) {
            flowLayout.minimumInteritemSpacing = 10;
        }else{
            flowLayout.minimumInteritemSpacing = 15;
        }
        _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor ssj_colorWithHex:@"ffffff" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        _collectionView.delegate=self;
        _collectionView.dataSource=self;
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
        _editeButton.backgroundColor = [UIColor ssj_colorWithHex:@"#dddddd"];
        [_editeButton addTarget:self action:@selector(editeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _editeButton.hidden = YES;

    }
    return _editeButton;
}

-(UIButton *)deleteButton{
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc]init];
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor ssj_colorWithHex:@"#eb4a64"] forState:UIControlStateNormal];
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:20];
        _deleteButton.backgroundColor = [UIColor ssj_colorWithHex:@"#f6f6f6"];
        [_deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.hidden = YES;
    }
    return _deleteButton;
}

-(UIButton *)rightButton{
    if (!_rightButton) {
        _rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
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

#pragma mark - Private
-(void)getDateFromDB{
    __weak typeof(self) weakSelf = self;
    [SSJBooksTypeStore queryForBooksListWithSuccess:^(NSMutableArray<SSJBooksTypeItem *> *result) {
        weakSelf.items = [NSMutableArray arrayWithArray:result];
        [weakSelf.collectionView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

- (void)deleteBooks{
    for (SSJBooksTypeItem *booksItem in self.selectedBooks) {
        [SSJBooksTypeStore deleteBooksTypeWithBooksId:booksItem.booksId error:NULL];
    }
    [self.collectionView reloadData];
}

-(void)updateAppearanceAfterThemeChanged{
    [super updateAppearanceAfterThemeChanged];
    self.collectionView.backgroundColor = [UIColor ssj_colorWithHex:@"ffffff" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
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
