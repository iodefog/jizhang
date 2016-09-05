//
//  SSJCategoryEditableCollectionView.m
//  SuiShouJi
//
//  Created by old lang on 16/8/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCategoryEditableCollectionView.h"
#import "SSJCategoryEditableCollectionViewCell.h"

#define DEFAULT_ITEM_SIZE CGSizeMake((self.width - 20) * 0.2, 90)

static NSString *const kCellId = @"SSJCategoryEditableCollectionViewCellId";

static NSString *const kAdditionalSelectedImage = @"record_making_selected";
static NSString *const kAdditionalUnselectedImage = @"record_making_unselected";

@interface SSJCategoryEditableCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@property (nonatomic, strong) NSMutableArray <SSJCategoryEditableCollectionViewCellItem *>*cellItems;

@property (nonatomic, strong) NSArray *observedKeyPath;

@property (nonatomic, strong) SSJRecordMakingCategoryItem *selectedItemForNormalState;

@end

@implementation SSJCategoryEditableCollectionView

- (void)dealloc {
    [self removeObserver];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _editable = YES;
        
        _contentInset = UIEdgeInsetsMake(0, 10, 94, 10);
        
        _cellItems = [NSMutableArray array];
        
        _selectedIndexs = @[@0];
        
        _observedKeyPath = @[@"categoryTitle", @"categoryImage", @"categoryColor"];
        
        [self addSubview:self.collectionView];
        
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(beginEditingWhenLongPressBegin)];
        _longPressGesture.delegate = self;
        [self addGestureRecognizer:_longPressGesture];
        
        _collectionView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return self;
}

- (void)layoutSubviews {
    _collectionView.frame = self.bounds;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    layout.itemSize = CGSizeEqualToSize(_itemSize, CGSizeZero) ? DEFAULT_ITEM_SIZE : _itemSize;
}

- (void)setItems:(NSArray<SSJRecordMakingCategoryItem *> *)items {
    [self removeObserver];
    _items = items;
    [self addObserver];
    
    _editing = NO;
    _collectionView.allowsMultipleSelection = NO;

    [_cellItems removeAllObjects];
    
    for (int i = 0; i < _items.count; i ++) {
        SSJRecordMakingCategoryItem *item = _items[i];
        SSJCategoryEditableCollectionViewCellItem *cellItem = [[SSJCategoryEditableCollectionViewCellItem alloc] init];
        cellItem.imageName = item.categoryImage;
        cellItem.title = item.categoryTitle;
        cellItem.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        if ([_selectedIndexs containsObject:@(i)]) {
            cellItem.imageTintColor = [UIColor whiteColor];
            cellItem.imageBackgroundColor = [UIColor ssj_colorWithHex:item.categoryColor];
            cellItem.additionImageName = @"";
            _selectedItemForNormalState = item;
            
        } else {
            cellItem.imageTintColor = [UIColor ssj_colorWithHex:item.categoryColor];
            cellItem.imageBackgroundColor = [UIColor clearColor];
            cellItem.additionImageName = @"";
        }
        
        [_cellItems addObject:cellItem];
    }
    
    [_collectionView reloadData];
    
    for (NSNumber *index in _selectedIndexs) {
        if ([_collectionView numberOfItemsInSection:0] > [index integerValue]) {
            [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:[index integerValue] inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredVertically];
        }
    }
}

- (void)setSelectedIndexs:(NSArray *)selectedIndexs {
    if (![_selectedIndexs isEqualToArray:selectedIndexs]) {
        _selectedIndexs = selectedIndexs;
        for (int i = 0; i < _cellItems.count; i ++) {
            if ([_selectedIndexs containsObject:@(i)]) {
                [self selectCellItemAtIndex:i];
                [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically];
                if (!_editing) {
                    _selectedItemForNormalState = [_items ssj_safeObjectAtIndex:i];
                }
            } else {
                [self deselectCellItemAtIndex:i];
                [_collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0] animated:NO];
            }
        }
    }
}

- (void)setEditing:(BOOL)editing {
    if (!_editable) {
        return;
    }
    
    _editing = editing;
    _collectionView.allowsMultipleSelection = _editing;
    
    for (NSIndexPath *path in [_collectionView indexPathsForSelectedItems]) {
        [_collectionView deselectItemAtIndexPath:path animated:NO];
    }
    
    for (int idx = 0; idx < _cellItems.count; idx ++) {
        [self deselectCellItemAtIndex:idx];
    }
    
    if (!_editing) {
        NSInteger selectedIndex = [_items indexOfObject:_selectedItemForNormalState];
        [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:selectedIndex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredVertically];
        [self selectCellItemAtIndex:selectedIndex];
    }
    
    [self updateSelectedIndexs];
    
    if (_selectedItemsChangeHandle) {
        _selectedItemsChangeHandle(self);
    }
    
    if (_editStateChangeHandle) {
        _editStateChangeHandle(self);
    }
}

- (void)setItemSize:(CGSize)itemSize {
    if (!CGSizeEqualToSize(_itemSize, itemSize)) {
        _itemSize = itemSize;
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
        layout.itemSize = CGSizeEqualToSize(_itemSize, CGSizeZero) ? DEFAULT_ITEM_SIZE : _itemSize;
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(_contentInset, contentInset)) {
        _contentInset = contentInset;
        _collectionView.contentInset = _contentInset;
    }
}

- (void)updateAppearance {
    _collectionView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    for (SSJCategoryEditableCollectionViewCellItem *cellItem in _cellItems) {
        cellItem.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
}

- (NSArray <SSJRecordMakingCategoryItem *>*)selectedItems {
    NSArray *selectedIndexPaths = [_collectionView indexPathsForSelectedItems];
    NSMutableArray *tmpItems = [NSMutableArray arrayWithCapacity:selectedIndexPaths.count];
    
    for (NSIndexPath *path in selectedIndexPaths) {
        SSJRecordMakingCategoryItem *item = [_items ssj_safeObjectAtIndex:path.item];
        if (item) {
            [tmpItems addObject:item];
        }
    }
    return [tmpItems copy];
}

- (void)deleteItems:(NSArray <SSJRecordMakingCategoryItem *>*)items {
    NSMutableArray *deleteIndexPaths = [NSMutableArray arrayWithCapacity:items.count];
    NSMutableArray *deleteCellItems = [NSMutableArray arrayWithCapacity:items.count];
    
    BOOL selectedItemsChanged = NO;
    
    for (SSJRecordMakingCategoryItem *item in items) {
        NSUInteger index = [_items indexOfObject:item];
        if (index == NSNotFound) {
            SSJPRINT(@"警告：删除的item不存在");
            continue;
        }
        
        [deleteIndexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
        SSJCategoryEditableCollectionViewCellItem *deleteCellItem = [_cellItems ssj_safeObjectAtIndex:index];
        if (deleteCellItem) {
            [deleteCellItems addObject:deleteCellItem];
        }
        
        for (NSString *keyPath in _observedKeyPath) {
            [item removeObserver:self forKeyPath:keyPath context:NULL];
        }
        
        if ([[_collectionView indexPathsForSelectedItems] containsObject:[NSIndexPath indexPathForItem:index inSection:0]]) {
            selectedItemsChanged = YES;
        }
    }
    
    NSMutableArray *tmpItems = [_items mutableCopy];
    [tmpItems removeObjectsInArray:items];
    [_cellItems removeObjectsInArray:deleteCellItems];
    
    _items = [tmpItems copy];
    
    if ([items containsObject:_selectedItemForNormalState]) {
        _selectedItemForNormalState = [_items firstObject];
    }
    
    [_collectionView deleteItemsAtIndexPaths:deleteIndexPaths];
    
    if (!_editing && [_collectionView indexPathsForSelectedItems].count == 0 && [_collectionView numberOfItemsInSection:0] > 0) {
        [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredVertically];
    }
    
    [self updateSelectedIndexs];
    
    if (selectedItemsChanged && _selectedItemsChangeHandle) {
        _selectedItemsChangeHandle(self);
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _cellItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SSJCategoryEditableCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    cell.item = [_cellItems ssj_safeObjectAtIndex:indexPath.item];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self selectCellItemAtIndex:indexPath.item];
    [self updateSelectedIndexs];
    
    if (_selectedItemsChangeHandle) {
        _selectedItemsChangeHandle(self);
    }
    
    if (!_editing) {
        _selectedItemForNormalState = [_items ssj_safeObjectAtIndex:indexPath.item];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self deselectCellItemAtIndex:indexPath.item];
    [self updateSelectedIndexs];
    
    if (_selectedItemsChangeHandle) {
        _selectedItemsChangeHandle(self);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _collectionView) {
        if (scrollView.dragging && !scrollView.decelerating) {
            CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:scrollView];
            if (_didScrollHandle) {
                _didScrollHandle(self, velocity);
            }
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return !_editing && _editable;
}

#pragma mark - Event
- (void)beginEditingWhenLongPressBegin {
    self.editing = YES;
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    if (object) {
        NSUInteger index = [_items indexOfObject:object];
        for (NSIndexPath *path in [_collectionView indexPathsForSelectedItems]) {
            if (path.item == index) {
                [self selectCellItemAtIndex:index];
                return;
            }
        }
        [self deselectCellItemAtIndex:index];
    }
}

#pragma mark - Private
- (void)selectCellItemAtIndex:(NSUInteger)index {
    SSJRecordMakingCategoryItem *item = [_items ssj_safeObjectAtIndex:index];
    SSJCategoryEditableCollectionViewCellItem *cellItem = [_cellItems ssj_safeObjectAtIndex:index];
    
    cellItem.imageName = item.categoryImage;
    cellItem.title = item.categoryTitle;
    cellItem.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    if (_editing) {
        cellItem.imageTintColor = [UIColor ssj_colorWithHex:item.categoryColor];
        cellItem.imageBackgroundColor = [UIColor clearColor];
        cellItem.additionImageName = kAdditionalSelectedImage;
    } else {
        cellItem.imageTintColor = [UIColor whiteColor];
        cellItem.imageBackgroundColor = [UIColor ssj_colorWithHex:item.categoryColor];
        cellItem.additionImageName = @"";
    }
}

- (void)deselectCellItemAtIndex:(NSUInteger)index {
    SSJRecordMakingCategoryItem *item = [_items ssj_safeObjectAtIndex:index];
    
    SSJCategoryEditableCollectionViewCellItem *cellItem = [_cellItems ssj_safeObjectAtIndex:index];
    cellItem.imageName = item.categoryImage;
    cellItem.title = item.categoryTitle;
    cellItem.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    if (_editing) {
        cellItem.imageTintColor = [UIColor ssj_colorWithHex:item.categoryColor];
        cellItem.imageBackgroundColor = [UIColor clearColor];
        cellItem.additionImageName = kAdditionalUnselectedImage;
    } else {
        cellItem.imageTintColor = [UIColor ssj_colorWithHex:item.categoryColor];
        cellItem.imageBackgroundColor = [UIColor clearColor];
        cellItem.additionImageName = @"";
    }
}

- (void)addObserver {
    for (NSString *keyPath in _observedKeyPath) {
        [_items addObserver:self toObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _items.count)] forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)removeObserver {
    for (NSString *keyPath in _observedKeyPath) {
        [_items removeObserver:self fromObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _items.count)] forKeyPath:keyPath context:NULL];
    }
}

- (void)updateSelectedIndexs {
    NSArray *selectedIndexPaths = [_collectionView indexPathsForSelectedItems];
    NSMutableArray *tmpSelectedIndexs = [NSMutableArray arrayWithCapacity:selectedIndexPaths.count];
    for (NSIndexPath *indexPath in selectedIndexPaths) {
        [tmpSelectedIndexs addObject:@(indexPath.item)];
    }
    _selectedIndexs = tmpSelectedIndexs;
}

#pragma mark - Getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.bounces = YES;
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[SSJCategoryEditableCollectionViewCell class] forCellWithReuseIdentifier:kCellId];
        _collectionView.contentInset = _contentInset;
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)layout {
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.minimumInteritemSpacing = 0;
        _layout.minimumLineSpacing = 0;
//        CGFloat width = (self.width - 20) * 0.2;
//        _layout.itemSize = CGSizeMake(floor(width), 90);
        _layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return _layout;
}

@end
