//
//  SSJCreateOrEditBillTypeIconSelectionView.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCaterotyMenuSelectionView.h"
#import "SSJBaseTableViewCell.h"

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJCaterotyMenuSelectionCellItem
#pragma mark -
@implementation SSJCaterotyMenuSelectionCellItem

+ (instancetype)itemWithTitle:(NSString *)title icon:(UIImage *)icon color:(UIColor *)color {
    SSJCaterotyMenuSelectionCellItem *item = [[SSJCaterotyMenuSelectionCellItem alloc] init];
    item.title = title;
    item.icon = icon;
    item.color = color;
    return item;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJCaterotyMenuSelectionViewIndexPath
#pragma mark -
@implementation SSJCaterotyMenuSelectionViewIndexPath

+ (instancetype)indexPathWithMenuIndex:(NSInteger)menuIndex categoryIndex:(NSInteger)categoryIndex itemIndex:(NSInteger)itemIndex {
    SSJCaterotyMenuSelectionViewIndexPath *indexPath = [[SSJCaterotyMenuSelectionViewIndexPath alloc] init];
    indexPath.menuIndex = menuIndex;
    indexPath.categoryIndex = categoryIndex;
    indexPath.itemIndex = itemIndex;
    return indexPath;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - _SSJCaterotyMenuSelectionViewTableViewCell
#pragma mark -
@interface _SSJCaterotyMenuSelectionViewTableViewCell : SSJBaseTableViewCell

@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation _SSJCaterotyMenuSelectionViewTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLab];
    }
    return self;
}

- (void)updateConstraints {
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];
    [super updateConstraints];
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.numberOfLines = 0;
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _titleLab;
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    _titleLab.textColor = self.selected ? SSJ_MAIN_COLOR : SSJ_SECONDARY_COLOR;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJCaterotyMenuSelectionViewCollectionCell
#pragma mark -

@interface SSJCaterotyMenuSelectionViewCollectionCell : UICollectionViewCell

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJCaterotyMenuSelectionView
#pragma mark -

static NSString *const kTableViewCellID = @"kTableViewCellID";
static NSString *const kCollectionViewCellID = @"kCollectionViewCellID";

@interface SSJCaterotyMenuSelectionView () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@end

@implementation SSJCaterotyMenuSelectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.tableView];
        [self addSubview:self.collectionView];
    }
    return self;
}

- (void)updateConstraints {
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(50);
        make.top.and.left.and.height.mas_equalTo(self);
    }];
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.tableView.mas_right);
        make.top.and.bottom.and.right.mas_equalTo(self);
    }];
    [super updateConstraints];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfMenuTitlesInSelectionView:)]) {
        return [self.dataSource numberOfMenuTitlesInSelectionView:self];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    _SSJCaterotyMenuSelectionViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellID];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(selectionView:titleForLeftMenuAtIndex:)]) {
        cell.titleLab.text = [self.dataSource selectionView:self titleForLeftMenuAtIndex:indexPath.row];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView reloadData];
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectionView:didSelectMenuAtIndex:)]) {
        [self.delegate selectionView:self didSelectMenuAtIndex:indexPath.row];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(selectionView:numberOfCategoriesAtMenuIndex:)]) {
        NSInteger selectedMenuIndex = self.tableView.indexPathForSelectedRow.row;
        return [self.dataSource selectionView:self numberOfCategoriesAtMenuIndex:selectedMenuIndex];
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(selectionView:numberOfItemsAtCategoryIndex:menuIndex:)]) {
        NSInteger selectedMenuIndex = self.tableView.indexPathForSelectedRow.row;
        return [self.dataSource selectionView:self numberOfItemsAtCategoryIndex:section menuIndex:selectedMenuIndex];
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(selectionView:itemAtIndexPath:)]) {
        NSInteger selectedMenuIndex = self.tableView.indexPathForSelectedRow.row;
        SSJCaterotyMenuSelectionViewIndexPath *tIndexPath = [SSJCaterotyMenuSelectionViewIndexPath indexPathWithMenuIndex:selectedMenuIndex categoryIndex:indexPath.section itemIndex:indexPath.item];
        [self.dataSource selectionView:self itemAtIndexPath:tIndexPath];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UICollectionViewDelegate

#pragma mark - Lazyloading
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 90;
        [_tableView registerClass:[_SSJCaterotyMenuSelectionViewTableViewCell class] forCellReuseIdentifier:kTableViewCellID];
    }
    return _tableView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        //[_collectionView registerClass:[SSJCreateOrEditBillTypeColorSelectionCell class] forCellWithReuseIdentifier:kCellId];
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)layout {
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc]init];
        [_layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _layout.minimumInteritemSpacing = 0;
        _layout.minimumLineSpacing = 0;
    }
    return _layout;
}

@end
