//
//  SSJCategoryCollectionView.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/18.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCategoryCollectionView.h"
#import "SSJCategoryCollectionViewCell.h"

@interface SSJCategoryCollectionView()
@property(nonatomic,strong)UICollectionView *collectionView;
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
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_screenWidth == 320) {
        return CGSizeMake((self.width - 80)/4, (self.height - 20) / 2);
    }else if(_screenWidth == 375){
        return CGSizeMake((self.width - 80)/4, (self.height - 20) / 3);
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
    __weak typeof(self) weakSelf = self;
    if (self.ItemClickedBlock != nil) {
        SSJCategoryCollectionViewCell *cell = (SSJCategoryCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        UIImage *image = cell.categoryImage.image;
        NSString *title = cell.categoryName.text;
        weakSelf.ItemClickedBlock(title,image);
    }
}

- (UICollectionView *)collectionView{
    if (_collectionView==nil) {
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumInteritemSpacing = 15;
        if (_screenWidth == 320 && _screenHeight == 568) {
            flowLayout.minimumLineSpacing = 5;
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
    }
    return _collectionView;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
