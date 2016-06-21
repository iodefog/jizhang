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

@interface SSJBooksTypeSelectViewController ()
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray *items;
@property(nonatomic, strong) SSJBooksTypeEditeView *booksEditeView;
@end

@implementation SSJBooksTypeSelectViewController{
    NSString *_selectBooksId;
    NSIndexPath *_editingIndex;
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
    [self.collectionView registerClass:[SSJBooksTypeCollectionViewCell class] forCellWithReuseIdentifier:SSJBooksTypeCellIdentifier];
    [self.collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    self.mm_drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    [MobClick event:@"main_account_book"];
    [self getDateFromDB];
    
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSJBooksTypeItem *item = [self.items ssj_safeObjectAtIndex:indexPath.row];
    if (![item.booksName isEqualToString:@"添加账本"]) {
        [MobClick event:@"change_account_book"];
        SSJSelectBooksType(item.booksId);
        [self.collectionView reloadData];
        [self.mm_drawerController closeDrawerAnimated:YES completion:NULL];
        [[NSNotificationCenter defaultCenter]postNotificationName:SSJBooksTypeDidChangeNotification object:nil];
    }else{
        [MobClick event:@"add_account_book"];
        self.booksEditeView.item = item;
        [self.booksEditeView show];
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
    if ([item.booksId isEqualToString:booksid]) {
        cell.isSelected = YES;
    }else{
        cell.isSelected = NO;
    }
    cell.isEditing = NO;
    __weak typeof(self) weakSelf = self;
    cell.longPressBlock = ^(){
        if ([indexPath compare:_editingIndex] != NSOrderedSame) {
            [MobClick event:@"edit_account_book"];
            weakSelf.booksEditeView.item = item;
            [weakSelf.booksEditeView show];
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
        _collectionView=[[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        _collectionView.delegate=self;
        _collectionView.dataSource=self;
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    return _collectionView;
}

-(SSJBooksTypeEditeView *)booksEditeView{
    if (!_booksEditeView) {
        _booksEditeView = [[SSJBooksTypeEditeView alloc]init];
        __weak typeof(self) weakSelf = self;
        _booksEditeView.comfirmButtonClickedBlock = ^(SSJBooksTypeItem *item){
            item.cwriteDate = [[NSDate date]ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
            item.userId = SSJUSERID();
            [SSJBooksTypeStore saveBooksTypeItem:item];
            [weakSelf getDateFromDB];
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        };
        __block NSString *booksid = SSJGetCurrentBooksType();
        _booksEditeView.deleteButtonClickedBlock = ^(SSJBooksTypeItem *item){
            if ([item.booksId isEqualToString:booksid]) {
                SSJSelectBooksType(SSJUSERID());
            }
            [weakSelf getDateFromDB];
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        };
        _booksEditeView.editeViewDismissBlock = ^(){
            _editingIndex = nil;
        };
    }
    return _booksEditeView;
}

-(void)getDateFromDB{
    __weak typeof(self) weakSelf = self;
    [SSJBooksTypeStore queryForBooksListWithSuccess:^(NSMutableArray<SSJBooksTypeItem *> *result) {
        weakSelf.items = [NSMutableArray arrayWithArray:result];
        [weakSelf.collectionView reloadData];
    } failure:^(NSError *error) {
        
    }];
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
