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
        [self addSubview:self.collectionView];
    }
    return self;
}

-(void)layoutSubviews{
    self.collectionView.frame = self.bounds;
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

-(void)setitems:(NSArray *)items{
    _items = items;
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
