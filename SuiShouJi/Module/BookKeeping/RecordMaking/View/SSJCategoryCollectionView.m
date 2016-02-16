//
//  SSJCategoryCollectionView.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/18.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCategoryCollectionView.h"
#import "SSJCategoryCollectionViewCell.h"
#import "SSJRecordMakingCategoryItem.h"
#import "SSJADDNewTypeViewController.h"
#import "FMDB.h"
#import "SSJRecordMakingCategoryItem.h"

@interface SSJCategoryCollectionView()
@property (nonatomic,strong) NSMutableArray *Items;
@end

@implementation SSJCategoryCollectionView{
    CGFloat _screenWidth;
    CGFloat _screenHeight;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _screenHeight = [UIScreen mainScreen].bounds.size.height;
        _screenWidth = [UIScreen mainScreen].bounds.size.width;
        [self getDateFromDB];
        [self addSubview:self.collectionView];
    }
    return self;
}

-(void)layoutSubviews{
    self.collectionView.frame = self.bounds;
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.Items.count;
}

- (NSInteger)numberOfSections{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJCategoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CategoryCollectionViewCellIdentifier" forIndexPath:indexPath];
    cell.item = (SSJRecordMakingCategoryItem*)[self.Items objectAtIndex:indexPath.row];
    if ([cell.item.categoryID isEqualToString:self.selectedId]) {
        cell.categorySelected = YES;
    }else{
        cell.categorySelected = NO;
    }
    __weak typeof(self) weakSelf = self;
    cell.removeCategoryBlock = ^(){
        if (weakSelf.removeFromCategoryListBlock) {
            weakSelf.removeFromCategoryListBlock();
        }
    };
    cell.EditeModel = NO;
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_screenWidth == 320) {
        if (_screenHeight == 568) {
            return CGSizeMake((self.width - 80)/4, (self.height - 20) / 2);
        }else{
            return CGSizeMake((self.width - 80)/4, self.height - 5);
        }
    }else if(_screenWidth == 375){
        return CGSizeMake((self.width - 80)/4, (self.height - 80) / 2);
    }
    return CGSizeMake((self.width - 80)/4, (self.height - 40) / 3);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    if (_screenWidth == 320) {
        return UIEdgeInsetsMake(5, 10, 15, 10);
    }else if (_screenWidth == 375){
        return UIEdgeInsetsMake(20, 10, 15, 10);
    }
    return UIEdgeInsetsMake(15, 10, 15, 10);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SSJCategoryCollectionViewCell *cell = (SSJCategoryCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (self.ItemClickedBlock) {
        self.ItemClickedBlock(cell.item);
    }
}

- (UICollectionView *)collectionView{
    if (_collectionView==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 15;
        if (_screenWidth == 320 && _screenHeight == 568) {
            flowLayout.minimumLineSpacing = 10;
        }else if(_screenWidth == 375){
            flowLayout.minimumLineSpacing = 30;
        }else if (_screenWidth == 414){
            flowLayout.minimumLineSpacing = 10;
        }
        _collectionView =[[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height) collectionViewLayout:flowLayout];
        _collectionView.dataSource=self;
        _collectionView.delegate=self;
        [_collectionView registerClass:[SSJCategoryCollectionViewCell class] forCellWithReuseIdentifier:@"CategoryCollectionViewCellIdentifier"];
        _collectionView.scrollEnabled = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.contentOffset = CGPointMake(0, 0);
    }
    return _collectionView;
}

-(void)getDateFromDB{
    FMDatabase *db = [FMDatabase databaseWithPath:SSJSQLitePath()];
    if (![db open]) {
        NSLog(@"Could not open db");
        return ;
    }
    self.Items = [[NSMutableArray alloc]init];
    FMResultSet *rs;
    if (self.page != self.totalPage - 1) {
        if (_screenWidth == 320) {
            if (_screenHeight == 568) {
                rs = [db executeQuery:@"SELECT A.CNAME , A.CCOLOR , A.CCOIN , A.ID FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE B.ISTATE = 1 AND A.ITYPE = ? AND A.ID = B.CBILLID AND B.CUSERID = ? LIMIT 8 OFFSET ?",[NSNumber numberWithBool:self.incomeOrExpence],SSJUSERID(),[NSNumber numberWithInt:self.page * 8]];
            }else{
                rs = [db executeQuery:@"SELECT A.CNAME , A.CCOLOR , A.CCOIN , A.ID FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE B.ISTATE = 1 AND A.ITYPE = ? AND A.ID = B.CBILLID AND B.CUSERID = ? LIMIT 4 OFFSET ?",[NSNumber numberWithBool:self.incomeOrExpence],SSJUSERID(),[NSNumber numberWithInt:self.page * 4]];
            }
        }else if(_screenWidth == 375){
            rs = [db executeQuery:@"SELECT A.CNAME , A.CCOLOR , A.CCOIN , A.ID FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE B.ISTATE = 1 AND A.ITYPE = ? AND A.ID = B.CBILLID AND B.CUSERID = ? LIMIT 8 OFFSET ?",[NSNumber numberWithBool:self.incomeOrExpence],SSJUSERID(),[NSNumber numberWithInt:self.page * 8]];
        }else{
            rs = [db executeQuery:@"SELECT A.CNAME , A.CCOLOR , A.CCOIN , A.ID FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE B.ISTATE = 1 AND A.ITYPE = ? AND A.ID = B.CBILLID AND B.CUSERID = ? LIMIT 12 OFFSET ?",[NSNumber numberWithBool:self.incomeOrExpence],SSJUSERID(),[NSNumber numberWithInt:self.page * 12]];
        }
        while ([rs next]) {
            SSJRecordMakingCategoryItem *item = [[SSJRecordMakingCategoryItem alloc]init];
            item.categoryTitle = [rs stringForColumn:@"CNAME"];
            item.categoryImage = [rs stringForColumn:@"CCOIN"];
            item.categoryColor = [rs stringForColumn:@"CCOLOR"];
            item.categoryID = [rs stringForColumn:@"ID"];
            [self.Items addObject:item];
        }

    }else{
        if (_screenWidth == 320) {
            if (_screenHeight == 568) {
                rs = [db executeQuery:@"SELECT A.CNAME , A.CCOLOR , A.CCOIN , A.ID FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE B.ISTATE = 1 AND A.ITYPE = ? AND A.ID = B.CBILLID AND B.CUSERID = ? LIMIT 7 OFFSET ?",[NSNumber numberWithBool:self.incomeOrExpence],SSJUSERID(),[NSNumber numberWithInt:self.page * 8]];
            }else{
                rs = [db executeQuery:@"SELECT A.CNAME , A.CCOLOR , A.CCOIN , A.ID FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE B.ISTATE = 1 AND A.ITYPE = ? AND A.ID = B.CBILLID AND B.CUSERID = ? LIMIT 3 OFFSET ?",[NSNumber numberWithBool:self.incomeOrExpence],SSJUSERID(),[NSNumber numberWithInt:self.page * 4]];
            }
        }else if(_screenWidth == 375){
            rs = [db executeQuery:@"SELECT A.CNAME , A.CCOLOR , A.CCOIN , A.ID FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE B.ISTATE = 1 AND A.ITYPE = ? AND A.ID = B.CBILLID AND B.CUSERID = ? LIMIT 7 OFFSET ?",[NSNumber numberWithBool:self.incomeOrExpence],SSJUSERID(),[NSNumber numberWithInt:self.page * 8]];
        }else{
            rs = [db executeQuery:@"SELECT A.CNAME , A.CCOLOR , A.CCOIN , A.ID FROM BK_BILL_TYPE A , BK_USER_BILL B WHERE B.ISTATE = 1 AND A.ITYPE = ? AND A.ID = B.CBILLID AND B.CUSERID = ? LIMIT 11 OFFSET ?",[NSNumber numberWithBool:self.incomeOrExpence],SSJUSERID(),[NSNumber numberWithInt:self.page * 12]];
        }
        while ([rs next]) {
            SSJRecordMakingCategoryItem *item = [[SSJRecordMakingCategoryItem alloc]init];
            item.categoryTitle = [rs stringForColumn:@"CNAME"];
            item.categoryImage = [rs stringForColumn:@"CCOIN"];
            item.categoryColor = [rs stringForColumn:@"CCOLOR"];
            item.categoryID = [rs stringForColumn:@"ID"];
            [self.Items addObject:item];
        }
        SSJRecordMakingCategoryItem *item = [[SSJRecordMakingCategoryItem alloc]init];
        item.categoryTitle = @"添加";
        item.categoryImage = @"add";
        [self.Items addObject:item];
    }
    [db close];
}

-(void)setIncomeOrExpence:(BOOL)incomeOrExpence{
    _incomeOrExpence = incomeOrExpence;
//    [self.Items removeAllObjects];
    [self getDateFromDB];
    [self.collectionView reloadData];
}

-(void)setPage:(int)page{
    _page = page;
//    [self.Items removeAllObjects];
    [self getDateFromDB];
    [self.collectionView reloadData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
