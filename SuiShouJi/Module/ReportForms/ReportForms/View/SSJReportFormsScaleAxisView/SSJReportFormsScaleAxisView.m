//
//  SSJReportFormsScaleAxisView.m
//  SSJReportFormsScaleAxisView
//
//  Created by old lang on 16/5/25.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsScaleAxisView.h"
#import "SSJReportFormsScaleAxisCell.h"

#define kHorizontalContentInset (self.width * 0.5 - 35)

static const CGFloat kItemWidth = 70;

static NSString *const kCellId = @"SSJReportFormsScaleAxisCell";
//static NSString *const kRedScaleColor = @"EB4A64";
//static NSString *const kGrayScaleColor = @"CCCCCC";

@interface SSJReportFormsScaleAxisView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic) NSUInteger axisCount;

@end

@implementation SSJReportFormsScaleAxisView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[SSJReportFormsScaleAxisCell class] forCellWithReuseIdentifier:kCellId];
        _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_collectionView];
    }
    return self;
}

- (void)layoutSubviews {
    _collectionView.frame = self.bounds;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(kItemWidth, CGRectGetHeight(self.bounds));
    layout.sectionInset = UIEdgeInsetsMake(0, kHorizontalContentInset, 0, kHorizontalContentInset);
}

- (void)reloadData {
    if (_delegate && [_delegate respondsToSelector:@selector(numberOfAxisInScaleAxisView:)]) {
        _axisCount = [_delegate numberOfAxisInScaleAxisView:self];
        [_collectionView reloadData];
        self.selectedIndex = 0;
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex >= _axisCount) {
        SSJPRINT(@"selectedIndex不能大于axisCount");
        return;
    }
    
    if (_selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        [_collectionView setContentOffset:CGPointMake(kItemWidth * (_selectedIndex + 0.5) - _collectionView.width * 0.5 + kHorizontalContentInset, 0) animated:NO];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _axisCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SSJReportFormsScaleAxisCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    if (_delegate && [_delegate respondsToSelector:@selector(scaleAxisView:titleForAxisAtIndex:)]) {
        cell.scaleValue = [_delegate scaleAxisView:self titleForAxisAtIndex:indexPath.item];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(scaleAxisView:heightForAxisAtIndex:)]) {
        cell.scaleHeight = [_delegate scaleAxisView:self heightForAxisAtIndex:indexPath.item];
    }
    cell.scaleColor = indexPath.item == _selectedIndex ? _selectedScaleColor : _scaleColor;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    _selectedIndex = indexPath.item;
    if (_delegate && [_delegate respondsToSelector:@selector(scaleAxisView:didSelectedScaleAxisAtIndex:)]) {
        [_delegate scaleAxisView:self didSelectedScaleAxisAtIndex:indexPath.item];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _collectionView) {
        NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:CGPointMake(scrollView.contentOffset.x + _collectionView.width * 0.5, 0)];
        SSJReportFormsScaleAxisCell *centerCell = (SSJReportFormsScaleAxisCell *)[_collectionView cellForItemAtIndexPath:indexPath];
        for (SSJReportFormsScaleAxisCell *cell in _collectionView.visibleCells) {
            cell.scaleColor = cell == centerCell ? _selectedScaleColor : _scaleColor;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == _collectionView) {
        if (!decelerate) {
            NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:CGPointMake(scrollView.contentOffset.x + _collectionView.width * 0.5, 0)];
            [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            _selectedIndex = indexPath.item;
            if (_delegate && [_delegate respondsToSelector:@selector(scaleAxisView:didSelectedScaleAxisAtIndex:)]) {
                [_delegate scaleAxisView:self didSelectedScaleAxisAtIndex:indexPath.item];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _collectionView) {
        NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:CGPointMake(scrollView.contentOffset.x + _collectionView.width * 0.5, 0)];
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        _selectedIndex = indexPath.item;
        if (_delegate && [_delegate respondsToSelector:@selector(scaleAxisView:didSelectedScaleAxisAtIndex:)]) {
            [_delegate scaleAxisView:self didSelectedScaleAxisAtIndex:indexPath.item];
        }
    }
}

@end
