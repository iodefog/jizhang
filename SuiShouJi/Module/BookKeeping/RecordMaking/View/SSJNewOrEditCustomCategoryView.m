//
//  SSJNewOrEditCustomCategoryView.m
//  SuiShouJi
//
//  Created by old lang on 16/8/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJNewOrEditCustomCategoryView.h"
#import "SSJCategoryCollectionViewCell.h"

static NSString *const kCellId = @"SSJCategoryCollectionViewCellId";

@interface SSJNewOrEditCustomCategoryView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIImageView *selectedTypeView;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *customCategoryLayout;

@property (nonatomic, strong) SSJAddNewTypeColorSelectionView *colorSelectionView;

@end

@implementation SSJNewOrEditCustomCategoryView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.textField];
        [self addSubview:self.collectionView];
        [self addSubview:self.colorSelectionView];
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    _textField.frame = CGRectMake(0, 0, self.width, 63);
    _collectionView.frame = CGRectMake(0, _textField.bottom, self.width, self.height - _textField.bottom - self.colorSelectionView.height - 5);
    _colorSelectionView.bottom = self.height;
}

- (void)updateAppearance {
    _textField.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    _textField.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入类别名称" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    [_textField ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    _collectionView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    [_colorSelectionView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
}

- (void)setItems:(NSArray<SSJRecordMakingCategoryItem *> *)items {
    _items = items;
    for (SSJRecordMakingCategoryItem *item in _items) {
        if (item.selected) {
            _selectedItem = item;
            break;
        }
    }
    [_collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _items.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJCategoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    cell.item = (SSJRecordMakingCategoryItem *)[_items ssj_safeObjectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (int i = 0; i < _items.count; i ++) {
        SSJRecordMakingCategoryItem *item = _items[i];
        item.selected = i == indexPath.item;
        if (indexPath.item == i) {
            _selectedItem = item;
        }
    }
    
    [self updateSelectedImage];
    
    if (_selectCategoryAction) {
        _selectCategoryAction(self);
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _collectionView) {
        if (scrollView.dragging && !scrollView.decelerating) {
            CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:scrollView];
            if (velocity.y < 0) {
                [_textField resignFirstResponder];
            } else {
                [_textField becomeFirstResponder];
            }
        }
    }
}

#pragma mark - Private
- (void)updateSelectedImage {
    NSString *colorValue = [_colorSelectionView.colors ssj_safeObjectAtIndex:_colorSelectionView.selectedIndex];
    _selectedTypeView.tintColor = [UIColor ssj_colorWithHex:colorValue];
    _selectedTypeView.image = [[UIImage imageNamed:_selectedItem.categoryImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_selectedTypeView sizeToFit];
    _selectedTypeView.left = 30;
    _selectedTypeView.centerY = _textField.height * 0.5;
}

- (void)colorSelectionViewAction {
    NSString *colorValue = [_colorSelectionView.colors ssj_safeObjectAtIndex:_colorSelectionView.selectedIndex];
    _selectedTypeView.tintColor = [UIColor ssj_colorWithHex:colorValue];
    [_items makeObjectsPerformSelector:@selector(setCategoryColor:) withObject:colorValue];
    
    if (_selectColorAction) {
        _selectColorAction(self);
    }
}

#pragma mark - Getter
- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.width, 63)];
        _textField.font = [UIFont systemFontOfSize:15];
        [_textField ssj_setBorderWidth:1];
        [_textField ssj_setBorderStyle:(SSJBorderStyleTop | SSJBorderStyleBottom)];
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, _textField.height)];
        [leftView addSubview:self.selectedTypeView];
        _textField.leftView = leftView;
        _textField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _textField;
}

- (UIImageView *)selectedTypeView {
    if (!_selectedTypeView) {
        _selectedTypeView = [[UIImageView alloc] init];
    }
    return _selectedTypeView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, _textField.bottom, self.width, self.height - _textField.bottom - self.colorSelectionView.height - 5) collectionViewLayout:self.customCategoryLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.bounces = YES;
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[SSJCategoryCollectionViewCell class] forCellWithReuseIdentifier:kCellId];
        _collectionView.contentOffset = CGPointMake(0, 0);
    }
    return _collectionView;
}

- (SSJAddNewTypeColorSelectionView *)colorSelectionView {
    if (!_colorSelectionView) {
        _colorSelectionView = [[SSJAddNewTypeColorSelectionView alloc] initWithWidth:self.width];
        _colorSelectionView.displayRowCount = 2.5;
        [_colorSelectionView ssj_setBorderWidth:1];
        [_colorSelectionView ssj_setBorderStyle:SSJBorderStyleTop];
        [_colorSelectionView addTarget:self action:@selector(colorSelectionViewAction) forControlEvents:UIControlEventValueChanged];
    }
    return _colorSelectionView;
}

- (UICollectionViewFlowLayout *)customCategoryLayout {
    if (!_customCategoryLayout) {
        _customCategoryLayout = [[UICollectionViewFlowLayout alloc] init];
        _customCategoryLayout.minimumInteritemSpacing = 0;
        _customCategoryLayout.minimumLineSpacing = 0;
        CGFloat width = (self.width - 16) * 0.2;
        _customCategoryLayout.itemSize = CGSizeMake(floor(width), 60);
        _customCategoryLayout.sectionInset = UIEdgeInsetsMake(10, 8, 0, 8);
    }
    return _customCategoryLayout;
}

@end
