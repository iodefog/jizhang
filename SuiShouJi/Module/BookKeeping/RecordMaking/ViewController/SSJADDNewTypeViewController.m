//
//  SSJADDNewTypeViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJADDNewTypeViewController.h"
#import "SSJCategoryCollectionViewCell.h"
#import "SSJRecordMakingCategoryItem.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "FMDB.h"

@interface SSJADDNewTypeViewController ()
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) UIView *rightbuttonView;
@end

@implementation SSJADDNewTypeViewController{
    NSIndexPath *_selectedIndex;
    NSString *_selectedID;
    SSJRecordMakingCategoryItem *_selectedItem;
    SSJRecordMakingCategoryItem *_defualtItem;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"添加新类别";
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ssj_showBackButtonWithImage:[UIImage imageNamed:@"close"] target:self selector:@selector(closeButtonClicked:)];
    self.view.backgroundColor = [UIColor ssj_colorWithHex:@"F6F6F6"];
    [self getdefualtItem];
    [self.view addSubview:self.collectionView];
    [self getDateFromDb];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:self.rightbuttonView];
    self.navigationItem.rightBarButtonItem = rightBarButton;

}

-(void)viewDidLayoutSubviews{
    self.collectionView.frame = CGRectMake(0, 10, self.view.width, self.view.height - 10);
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.items.count;
}

- (NSInteger)numberOfSections{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJCategoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCollectionViewCellIdentifier" forIndexPath:indexPath];
    cell.item = (SSJRecordMakingCategoryItem*)[self.items objectAtIndex:indexPath.row];
    if ([cell.item.categoryID isEqualToString:_selectedItem.categoryID]) {
        cell.categoryImage.tintColor = [UIColor whiteColor];
        cell.categoryImage.image = [cell.categoryImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.categoryImage.backgroundColor = [UIColor ssj_colorWithHex:cell.item.categoryColor];
    }else{
        cell.categoryImage.backgroundColor = [UIColor clearColor];
        [cell.categoryImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((self.view.width - 50) / 4, 80);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _selectedID = ((SSJCategoryCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath]).item.categoryID;
    _selectedItem = ((SSJCategoryCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath]).item;
    [collectionView reloadData];
}

#pragma mark - Getter
- (UICollectionView *)collectionView{
    if (_collectionView==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.minimumLineSpacing = 10;
        _collectionView =[[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) collectionViewLayout:flowLayout];
        _collectionView.dataSource=self;
        _collectionView.delegate=self;
        [_collectionView registerClass:[SSJCategoryCollectionViewCell class] forCellWithReuseIdentifier:@"CategoryCollectionViewCellIdentifier"];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.contentOffset = CGPointMake(0, 0);
    }
    return _collectionView;
}

-(UIView *)rightbuttonView{
    if (!_rightbuttonView) {
        _rightbuttonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        UIButton *comfirmButton = [[UIButton alloc]init];
        comfirmButton.frame = CGRectMake(0, 0, 44, 44);
        [comfirmButton setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateNormal];
        [comfirmButton addTarget:self action:@selector(comfirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_rightbuttonView addSubview:comfirmButton];
    }
    return _rightbuttonView;
}

#pragma mark - private
-(void)getDateFromDb{
    [self.collectionView ssj_showLoadingIndicator];
    
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance] asyncInDatabase:^(FMDatabase *db){
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE A.ITYPE = ? AND B.ISTATE = 0 AND B.CUSERID = ? AND A.ID = B.CBILLID",[NSNumber numberWithBool:self.incomeOrExpence],SSJUSERID()];
        while ([rs next]) {
            SSJRecordMakingCategoryItem *item = [[SSJRecordMakingCategoryItem alloc]init];
            item.categoryTitle = [rs stringForColumn:@"CNAME"];
            item.categoryImage = [rs stringForColumn:@"CCOIN"];
            item.categoryColor = [rs stringForColumn:@"CCOLOR"];
            item.categoryID = [rs stringForColumn:@"ID"];
            [tempArray addObject:item];
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            weakSelf.items = tempArray;
            [weakSelf.collectionView reloadData];
            _selectedID = ((SSJRecordMakingCategoryItem*)[weakSelf.items firstObject]).categoryID;
            [weakSelf.collectionView ssj_hideLoadingIndicator];
        });
    }];
}

-(void)comfirmButtonClick:(id)sender{
    __weak typeof(self) weakSelf = self;
    [[SSJDatabaseQueue sharedInstance]asyncInDatabase:^(FMDatabase *db){
        [db executeUpdate:@"UPDATE BK_USER_BILL SET ISTATE = 1 , CWRITEDATE = ? , IVERSION = ? , OPERATORTYPE = 1 WHERE CBILLID = ? AND CUSERID = ?",[[NSDate date] ssj_systemCurrentDateWithFormat:@"yyyy-MM-dd HH:mm:ss.SSS"],[NSNumber numberWithLongLong:SSJSyncVersion()],_selectedID,SSJUSERID()];
        [weakSelf getDateFromDb];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [[NSNotificationCenter defaultCenter]postNotificationName:@"addNewTypeNotification" object:nil];
            [weakSelf.collectionView reloadData];
            [weakSelf.navigationController popViewControllerAnimated:YES];
            if (weakSelf.NewCategorySelectedBlock) {
                weakSelf.NewCategorySelectedBlock(_selectedID,_selectedItem);
            }
        });
    }];
    if (SSJSyncSetting() == SSJSyncSettingTypeWIFI) {
        [[SSJDataSynchronizer shareInstance]startSyncWithSuccess:^(){
            
        }failure:^(NSError *error) {
            
        }];
    }
}

-(void)getdefualtItem{
    [[SSJDatabaseQueue sharedInstance] inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE A.ITYPE = ? AND B.ISTATE = 0 AND B.CUSERID = ? AND A.ID = B.CBILLID LIMIT 1 OFFSET 0",[NSNumber numberWithBool:self.incomeOrExpence],SSJUSERID()];
        while ([rs next]) {
            _defualtItem = [[SSJRecordMakingCategoryItem alloc]init];
            _defualtItem.categoryTitle = [rs stringForColumn:@"CNAME"];
            _defualtItem.categoryImage = [rs stringForColumn:@"CCOIN"];
            _defualtItem.categoryColor = [rs stringForColumn:@"CCOLOR"];
            _defualtItem.categoryID = [rs stringForColumn:@"ID"];
        }
        _selectedItem = _defualtItem;
    }];
}

-(void)closeButtonClicked:(id)sender{
    [self ssj_backOffAction];
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
