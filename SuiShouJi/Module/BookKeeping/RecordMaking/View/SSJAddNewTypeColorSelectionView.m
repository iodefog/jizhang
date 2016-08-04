//
//  SSJAddNewTypeColorSelectionView.m
//  SuiShouJi
//
//  Created by old lang on 16/5/10.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAddNewTypeColorSelectionView.h"
#import "SSJColorSelectCollectionViewCell.h"

#define ITEM_SIZE_WIDTH (self.width - 80) / 6

static NSString *const kCellId = @"SSJColorSelectCollectionViewCell";

@interface SSJAddNewTypeColorSelectionView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation SSJAddNewTypeColorSelectionView

- (instancetype)initWithWidth:(CGFloat)width {
    if (self = [super initWithFrame:CGRectMake(0, 0, width, 0)]) {
        _displayRowCount = 2;
        [self addSubview:self.collectionView];
        self.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithWidth:CGRectGetWidth(frame)];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.width, 30 + ITEM_SIZE_WIDTH * _displayRowCount);
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

- (void)setDisplayRowCount:(CGFloat)displayRowCount {
    if (_displayRowCount != displayRowCount) {
        _displayRowCount = displayRowCount;
        [self sizeToFit];
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
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc]init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.minimumLineSpacing = 10;
    flowLayout.itemSize = CGSizeMake(ITEM_SIZE_WIDTH, ITEM_SIZE_WIDTH);
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    return flowLayout;
}

@end
