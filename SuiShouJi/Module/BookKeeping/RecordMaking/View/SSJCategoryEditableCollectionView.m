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

@property (nonatomic, strong) NSMutableArray <SSJRecordMakingCategoryItem *>*selectedItems;

@end

@implementation SSJCategoryEditableCollectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _editable = YES;
        
        _contentInset = UIEdgeInsetsMake(0, 10, 94, 10);
        
        _cellItems = [NSMutableArray array];
        _selectedItems = [NSMutableArray array];
        
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
    _items = items;
    _editing = NO;
    _collectionView.allowsMultipleSelection = NO;

    [_cellItems removeAllObjects];
    
    NSInteger selectedIndex = -1;
    for (int i = 0; i < _items.count; i ++) {
        SSJRecordMakingCategoryItem *item = _items[i];
        SSJCategoryEditableCollectionViewCellItem *cellItem = [[SSJCategoryEditableCollectionViewCellItem alloc] init];
        cellItem.imageName = item.categoryImage;
        cellItem.title = item.categoryTitle;
        cellItem.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        if (item.selected) {
            cellItem.imageTintColor = [UIColor whiteColor];
            cellItem.imageBackgroundColor = [UIColor ssj_colorWithHex:item.categoryColor];
            cellItem.additionImageName = @"";
            selectedIndex = i;
        } else {
            cellItem.imageTintColor = [UIColor ssj_colorWithHex:item.categoryColor];
            cellItem.imageBackgroundColor = [UIColor clearColor];
            cellItem.additionImageName = @"";
        }
        [_cellItems addObject:cellItem];
    }
    
    [_collectionView reloadData];
    
    if (selectedIndex >= 0) {
        [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:selectedIndex inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically];
    }
    [self updateSelectedItems];
}

- (void)setEditing:(BOOL)editing {
    if (!_editable) {
        return;
    }
    
    _editing = editing;
    _collectionView.allowsMultipleSelection = _editing;
    
    for (NSIndexPath *path in [_collectionView indexPathsForSelectedItems]) {
        [_collectionView deselectItemAtIndexPath:path animated:YES];
    }
    
    for (int i = 0; i < _cellItems.count; i ++) {
        [self deselectCellItemAtIndex:i];
    }
    
    [self updateSelectedItems];
    
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

- (void)deleteItems:(NSArray <SSJRecordMakingCategoryItem *>*)items {
    NSMutableArray *deleteIndexPaths = [NSMutableArray arrayWithCapacity:items.count];
    NSMutableArray *tmpItems = [_items mutableCopy];
    
    for (SSJRecordMakingCategoryItem *item in items) {
        NSUInteger index = [_items indexOfObject:item];
        if (index != NSNotFound) {
            [deleteIndexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
            [tmpItems removeObjectAtIndex:index];
            [_cellItems removeObjectAtIndex:index];
        }
    }
    
    _items = [tmpItems copy];
    
    [_collectionView deleteItemsAtIndexPaths:deleteIndexPaths];
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
    [self updateSelectedItems];
    [self selectCellItemAtIndex:indexPath.item];
    
    if (_selectedItemsChangeHandle) {
        _selectedItemsChangeHandle(self);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self updateSelectedItems];
    [self deselectCellItemAtIndex:indexPath.item];
    
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

#pragma mark - 
- (void)beginEditingWhenLongPressBegin {
    self.editing = YES;
}

#pragma mark - Private
- (void)selectCellItemAtIndex:(NSUInteger)index {
    SSJRecordMakingCategoryItem *item = [_items ssj_safeObjectAtIndex:index];
    SSJCategoryEditableCollectionViewCellItem *cellItem = [_cellItems ssj_safeObjectAtIndex:index];
    
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

- (void)updateSelectedItems {
    [_selectedItems removeAllObjects];
    NSArray *selctedIndexPaths = [_collectionView indexPathsForSelectedItems];
    for (NSIndexPath *selctedIndexPath in selctedIndexPaths) {
        SSJRecordMakingCategoryItem *selectedItem = [_items ssj_safeObjectAtIndex:selctedIndexPath.item];
        [_selectedItems addObject:selectedItem];
    }
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
