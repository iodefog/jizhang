//
//  SSJAddNewTypeColorSelectionView.m
//  SuiShouJi
//
//  Created by old lang on 16/5/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAddNewTypeColorSelectionView.h"
#import "SSJColorSelectCollectionViewCell.h"

static NSString *const kCellId = @"SSJColorSelectCollectionViewCell";

@interface SSJAddNewTypeColorSelectionView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation SSJAddNewTypeColorSelectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.collectionView];
    }
    return self;
}

- (void)layoutSubviews {
    _collectionView.frame = self.bounds;
}

- (void)setColors:(NSArray *)colors {
    if (![_colors isEqualToArray:colors]) {
        _colors = colors;
        [_collectionView reloadData];
    }
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _colors.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJColorSelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    cell.itemColor = _colors[indexPath.item];
    cell.isSelected = _selectedIndex == indexPath.item;
    return cell;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_selectedIndex != indexPath.item) {
        _selectedIndex = indexPath.item;
        [collectionView reloadData];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (UICollectionView *)collectionView{
    if (_collectionView==nil) {
        _collectionView =[[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.dataSource=self;
        _collectionView.delegate=self;
        [_collectionView registerClass:[SSJColorSelectCollectionViewCell class] forCellWithReuseIdentifier:kCellId];
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.minimumLineSpacing = 10;
    CGFloat width = (self.width - 80) / 6;
    flowLayout.itemSize = CGSizeMake(width, width);
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    return flowLayout;
}

@end
