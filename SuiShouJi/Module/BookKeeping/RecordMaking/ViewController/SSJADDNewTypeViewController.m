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
#import "FMDB.h"

@interface SSJADDNewTypeViewController ()
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) UIView *rightbuttonView;
@end

@implementation SSJADDNewTypeViewController{
    NSIndexPath *_selectedIndex;
    NSString *_selectedID;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"添加新类别";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ssj_showBackButtonWithImage:[UIImage imageNamed:@"close"] target:self selector:@selector(closeButtonClicked:)];
    self.view.backgroundColor = [UIColor ssj_colorWithHex:@"F6F6F6"];
    _selectedIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    self.items = [[NSMutableArray alloc]init];
    [self getDateFromDb];
    [self.view addSubview:self.collectionView];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:self.rightbuttonView];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    _selectedID = ((SSJRecordMakingCategoryItem*)[self.items firstObject]).categoryID;
}

-(void)viewDidLayoutSubviews{
    self.collectionView.frame = CGRectMake(0, 10, self.view.width, self.view.height - 10);
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
    if ([indexPath compare:_selectedIndex] == NSOrderedSame) {
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
    _selectedIndex = indexPath;
    _selectedID = ((SSJCategoryCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath]).item.categoryID;
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
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        NSLog(@"Could not open db");
        return ;
    }
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM BK_BILL_TYPE WHERE ITYPE = ? AND ISTATE = 0",[NSNumber numberWithBool:self.incomeOrExpence]];
    while ([rs next]) {
        SSJRecordMakingCategoryItem *item = [[SSJRecordMakingCategoryItem alloc]init];
        item.categoryTitle = [rs stringForColumn:@"CNAME"];
        item.categoryImage = [rs stringForColumn:@"CCOIN"];
        item.categoryColor = [rs stringForColumn:@"CCOLOR"];
        item.categoryID = [rs stringForColumn:@"ID"];
        [self.items addObject:item];
    }
    [db close];
}

-(void)comfirmButtonClick:(id)sender{
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        NSLog(@"Could not open db");
        return ;
    }
    NSInteger count = [db intForQuery:@"SELECT COUNT(*) FROM BK_BILL_TYPE WHERE ITYPE = ? AND ISTATE = 1",[NSNumber numberWithBool:self.incomeOrExpence]];
    if (count >= 20) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"首页类型已满,类别已满，请移除一些类别后再添加" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }else{
        [db executeUpdate:@"UPDATE BK_BILL_TYPE SET ISTATE = 1 WHERE ID = ? AND ITYPE = ?",_selectedID,[NSNumber numberWithBool:self.incomeOrExpence]];
        [self getDateFromDb];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"addNewTypeNotification" object:nil];
        [self.collectionView reloadData];
        [self.navigationController popViewControllerAnimated:YES];
    }
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
