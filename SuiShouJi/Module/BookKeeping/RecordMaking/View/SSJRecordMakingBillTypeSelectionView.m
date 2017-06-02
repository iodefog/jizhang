//
//  SSJRecordMakingBillTypeSelectionView.m
//  SSRecordMakingDemo
//
//  Created by old lang on 16/4/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJRecordMakingBillTypeSelectionView.h"
#import "SSJRecordMakingBillTypeSelectionCell.h"
#import "SSJRecordMakingBillTypeSelectionCellItem.h"
#import "SSJEditableCollectionView.h"

static const UIEdgeInsets kSectionInset = {0, 14, 0, 14};
#define kCellWidth (CGRectGetWidth(self.bounds) - kSectionInset.left - kSectionInset.right) / 5
#define kCellHeight 75

static NSString *const kCellId = @"SSJRecordMakingBillTypeSelectionCell";

@interface SSJRecordMakingBillTypeSelectionView () <SSJEditableCollectionViewDataSource, SSJEditableCollectionViewDelegate>

@property (nonatomic, strong) SSJEditableCollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *internalItems;

@property (nonatomic, strong) SSJRecordMakingBillTypeSelectionCellItem *lastSelectedItem;

@end

@implementation SSJRecordMakingBillTypeSelectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _internalItems = [NSMutableArray array];
        [self addSubview:self.collectionView];
    }
    return self;
}

- (void)layoutSubviews {
    self.collectionView.frame = self.bounds;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.itemSize = CGSizeMake(kCellWidth, kCellHeight);
    
    CGFloat top = 24;
    CGFloat left, right;
    left = right = (kCellWidth - 22) * 0.5;
    CGFloat bottom = kCellHeight - top - 22;
    self.collectionView.exchangeCellRegion = UIEdgeInsetsMake(top, left, bottom, right);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _internalItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SSJRecordMakingBillTypeSelectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    cell.item = _internalItems[indexPath.row];
    __weak typeof(self) wself = self;
    cell.shouldDeleteAction = ^BOOL(SSJRecordMakingBillTypeSelectionCell *cell) {
        if (wself.shouldDeleteAction) {
            return wself.shouldDeleteAction(wself, cell.item);
        }
        return YES;
    };
    cell.deleteAction = ^(SSJRecordMakingBillTypeSelectionCell *cell) {
        if ([wself deleteItem:cell.item]) {
            if (cell.item == self.lastSelectedItem && [self.internalItems count] > 1) {
                self.lastSelectedItem = [self.internalItems firstObject];
            }
            if (wself.deleteAction) {
                wself.deleteAction(wself, cell.item);
            }
        }
    };
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == _internalItems.count - 1) {
        if (_addAction) {
            _addAction(self);
        }
        return;
    }
    
    SSJRecordMakingBillTypeSelectionCellItem *selectedItem = [_internalItems ssj_safeObjectAtIndex:indexPath.item];
    if (selectedItem.state == SSJRecordMakingBillTypeSelectionCellStateSelected) {
        return;
    }
    
    for (SSJRecordMakingBillTypeSelectionCellItem *item in _internalItems) {
        if ([item.ID isEqualToString:selectedItem.ID]) {
            item.state = SSJRecordMakingBillTypeSelectionCellStateSelected;
        } else {
            item.state = SSJRecordMakingBillTypeSelectionCellStateNormal;
        }
    }
    [self scrollToSelectedItem];
    
    if (_selectAction) {
        _selectAction(self, selectedItem);
    }
}

#pragma mark - SSJEditableCollectionViewDelegate
- (BOOL)collectionView:(SSJEditableCollectionView *)collectionView shouldBeginEditingWhenPressAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.item != _internalItems.count - 1;
}

- (void)collectionView:(SSJEditableCollectionView *)collectionView didBeginEditingWhenPressAtIndexPath:(NSIndexPath *)indexPath {
    for (SSJRecordMakingBillTypeSelectionCellItem *item in _internalItems) {
        if (item != [_internalItems lastObject]) {
            if (item.state == SSJRecordMakingBillTypeSelectionCellStateSelected) {
                self.lastSelectedItem = item;
            }
            item.state = SSJRecordMakingBillTypeSelectionCellStateEditing;
        }
    }
    _editing = YES;
    if (_beginEditingAction) {
        _beginEditingAction(self);
    }
}

- (BOOL)collectionView:(SSJEditableCollectionView *)collectionView shouldBeginMovingCellAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.item != _internalItems.count - 1;
}

- (void)collectionView:(SSJEditableCollectionView *)collectionView willMoveCellAtIndexPath:(NSIndexPath *)indexPath {
    SSJRecordMakingBillTypeSelectionCellItem *item = _internalItems[indexPath.item];
    item.state = SSJRecordMakingBillTypeSelectionCellStateEditing;
}

- (BOOL)collectionView:(SSJEditableCollectionView *)collectionView shouldMoveCellAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    if (fromIndexPath.item != _internalItems.count - 1
        && toIndexPath.item != _internalItems.count - 1) {
        return YES;
    }
    return NO;
}

- (void)collectionView:(SSJEditableCollectionView *)collectionView didEndMovingCellFromIndexPath:(NSIndexPath *)fromIndexPath toTargetIndexPath:(NSIndexPath *)toIndexPath {
    SSJRecordMakingBillTypeSelectionCellItem *moveItem = _internalItems[fromIndexPath.item];
    [_internalItems removeObject:moveItem];
    [_internalItems insertObject:moveItem atIndex:toIndexPath.item];
}

- (void)collectionView:(SSJEditableCollectionView *)collectionView didExchangeCellsWithIndexPath:(NSIndexPath *)indexPath anotherIndexPath:(NSIndexPath *)anotherIndexPath {
    [_internalItems exchangeObjectAtIndex:indexPath.item withObjectAtIndex:anotherIndexPath.item];
}

- (BOOL)shouldCollectionViewEndEditingWhenUserTapped:(SSJEditableCollectionView *)collectionView {
    return NO;
}

- (void)collectionViewDidEndEditing:(SSJEditableCollectionView *)collectionView {
    for (SSJRecordMakingBillTypeSelectionCellItem *item in _internalItems) {
        item.state = (item == self.lastSelectedItem) ? SSJRecordMakingBillTypeSelectionCellStateSelected : SSJRecordMakingBillTypeSelectionCellStateNormal;
    }
    
    if (_endEditingAction) {
        _endEditingAction(self);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_collectionView keepCurrentMovedCellVisible];
    [_collectionView checkIfHasIntersectantCells];
    
    if (scrollView.panGestureRecognizer && scrollView.dragging && !scrollView.decelerating) {
        CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:scrollView];
        if (_dragAction) {
            _dragAction(self, velocity.y < 0);
        }
    }
}

#pragma mark - Public
- (void)setItems:(NSArray<SSJRecordMakingBillTypeSelectionCellItem *> *)items {
    [_internalItems removeAllObjects];
    if (items) {
        [_internalItems addObjectsFromArray:items];
    }
    [_internalItems addObject:[SSJRecordMakingBillTypeSelectionCellItem itemWithTitle:@"添加" imageName:@"add" colorValue:SSJ_CURRENT_THEME.mainColor ID:@"" order:0]];
    [_collectionView reloadData];
    [self scrollToSelectedItem];
}

- (NSArray *)items {
    NSMutableArray *tempItems = [_internalItems mutableCopy];
    [tempItems removeLastObject];
    return tempItems;
}

- (SSJRecordMakingBillTypeSelectionCellItem *)selectedItem {
    __block SSJRecordMakingBillTypeSelectionCellItem *tmpItem = nil;
    [self.items enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(SSJRecordMakingBillTypeSelectionCellItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (item.state == SSJRecordMakingBillTypeSelectionCellStateSelected) {
            tmpItem = item;
            *stop = YES;
        }
    }];
    return tmpItem;
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    _collectionView.contentInset = contentInsets;
}

- (void)setEditing:(BOOL)editing {
    if (_editing == editing) {
        return;
    }
    
    _editing = editing;
    
    if (_editing) {
        [_collectionView beginEditing];
    } else {
        [_collectionView endEditing];
        [self scrollToSelectedItem];
    }
}

- (BOOL)deleteItem:(SSJRecordMakingBillTypeSelectionCellItem *)item {
    NSUInteger index = [_internalItems indexOfObject:item];
    if (index != NSNotFound) {
        [_internalItems removeObjectAtIndex:index];
        [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
        
        if (item.state == SSJRecordMakingBillTypeSelectionCellStateSelected && _internalItems.count > 1) {
            SSJRecordMakingBillTypeSelectionCellItem *item = [_internalItems firstObject];
            item.state = SSJRecordMakingBillTypeSelectionCellStateSelected;
        }
        return YES;
    }
    
    return NO;
}

- (void)scrollToSelectedItem {
    for (int idx = 0; idx < _internalItems.count; idx ++) {
        SSJRecordMakingBillTypeSelectionCellItem *item = _internalItems[idx];
        if (item.state == SSJRecordMakingBillTypeSelectionCellStateSelected) {
            [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:idx inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        }
    }
}

#pragma mark - Getter
- (SSJEditableCollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[SSJEditableCollectionView alloc] initWithFrame:self.frame collectionViewLayout:self.layout];
        _collectionView.editDelegate = self;
        _collectionView.editDataSource = self;
        _collectionView.movedCellScale = 1.3;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [_collectionView registerClass:[SSJRecordMakingBillTypeSelectionCell class] forCellWithReuseIdentifier:kCellId];
        _collectionView.exchangeCellRegion = UIEdgeInsetsMake(11, (kCellWidth - 52) * 0.5, 25, (kCellWidth - 52) * 0.5);
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)layout {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = kSectionInset;
    return layout;
}

@end
