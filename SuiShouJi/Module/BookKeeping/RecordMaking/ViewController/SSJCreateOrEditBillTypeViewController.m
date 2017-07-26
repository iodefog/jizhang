//
//  SSJCreateOrEditBillTypeViewController.m
//  SuiShouJi
//
//  Created by old lang on 2017/7/20.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJCreateOrEditBillTypeViewController.h"
#import "SSJCreateOrEditBillTypeTopView.h"
#import "SSJCreateOrEditBillTypeColorSelectionView.h"
#import "SSJCaterotyMenuSelectionView.h"

#import "SSJBillTypeCategoryModel.h"
#import "SSJCategoryListHelper.h"
#import "SSJCreateOrEditBillTypeHelper.h"
#import "YYKeyboardManager.h"

static NSString *const kCatgegoriesInfoIncomeKey = @"kCatgegoriesInfoIncomeKey";

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJCreateOrEditBillTypeViewController
#pragma mark -
@interface SSJCreateOrEditBillTypeViewController () <SSJCaterotyMenuSelectionViewDataSource, SSJCaterotyMenuSelectionViewDelegate, YYKeyboardObserver>

@property (nonatomic, strong) SSJCreateOrEditBillTypeTopView *topView;

@property (nonatomic, strong) SSJCaterotyMenuSelectionView *bodyView;

@property (nonatomic, strong) SSJCreateOrEditBillTypeColorSelectionView *colorSelectionView;

@property (nonatomic, strong) NSArray<NSNumber *> *booksTypes;

@property (nonatomic, strong) NSMutableDictionary<id<NSCopying>, NSArray<SSJBillTypeCategoryModel *> *> *catgegoriesInfo;

@end

@implementation SSJCreateOrEditBillTypeViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.catgegoriesInfo = [NSMutableDictionary dictionary];
        [[YYKeyboardManager defaultManager] addObserver:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.bodyView];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.colorSelectionView];
    
    [self loadColors];
}

- (void)updateViewConstraints {
    [self.topView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(SSJ_NAVIBAR_BOTTOM);
        make.left.and.right.mas_equalTo(self.view);
        make.height.mas_equalTo(65);
    }];
    [self.bodyView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.left.and.right.and.bottom.mas_equalTo(self.view);
    }];
    [self.colorSelectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.bodyView);
    }];
    [super updateViewConstraints];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self.topView updateAppearanceAccordingToTheme];
    [self.bodyView updateAppearanceAccordingToTheme];
}

#pragma mark - SSJCaterotyMenuSelectionViewDataSource
- (NSUInteger)numberOfMenuTitlesInSelectionView:(SSJCaterotyMenuSelectionView *)selectionView {
    return self.expended ? self.booksTypes.count : 1;
}

- (NSString *)selectionView:(SSJCaterotyMenuSelectionView *)selectionView titleForLeftMenuAtIndex:(NSInteger)index {
    SSJBooksType booksType = [[self.booksTypes ssj_safeObjectAtIndex:index] integerValue];
    switch (booksType) {
        case SSJBooksTypeDaily:
            return @"日常";
            break;
            
        case SSJBooksTypeBusiness:
            return @"生意";
            break;
            
        case SSJBooksTypeMarriage:
            return @"结婚";
            break;
            
        case SSJBooksTypeDecoration:
            return @"装修";
            break;
            
        case SSJBooksTypeTravel:
            return @"旅行";
            break;
            
        case SSJBooksTypeBaby:
            return @"宝宝";
            break;
    }
}

- (NSUInteger)selectionView:(SSJCaterotyMenuSelectionView *)selectionView numberOfCategoriesAtMenuIndex:(NSInteger)index {
    return self.currentCategories.count;
}

- (NSString *)selectionView:(SSJCaterotyMenuSelectionView *)selectionView titleForCategoryAtIndex:(NSInteger)categoryIndex menuIndex:(NSInteger)menuIndex {
    SSJBillTypeCategoryModel *category = [self.currentCategories ssj_safeObjectAtIndex:categoryIndex];
    return category.title;
}

- (NSUInteger)selectionView:(SSJCaterotyMenuSelectionView *)selectionView numberOfItemsAtCategoryIndex:(NSInteger)categoryIndex menuIndex:(NSInteger)menuIndex {
    SSJBillTypeCategoryModel *category = [self.currentCategories ssj_safeObjectAtIndex:categoryIndex];
    return category.items.count;
}

- (SSJCaterotyMenuSelectionCellItem *)selectionView:(SSJCaterotyMenuSelectionView *)selectionView itemAtIndexPath:(SSJCaterotyMenuSelectionViewIndexPath *)indexPath {
    SSJBillTypeCategoryModel *category = [self.currentCategories ssj_safeObjectAtIndex:indexPath.categoryIndex];
    return [category.items ssj_safeObjectAtIndex:indexPath.itemIndex];
}

#pragma mark - SSJCaterotyMenuSelectionViewDelegate
- (void)selectionView:(SSJCaterotyMenuSelectionView *)selectionView didSelectMenuAtIndex:(NSInteger)menuIndex {
    
}

- (void)selectionView:(SSJCaterotyMenuSelectionView *)selectionView didSelectItemAtIndexPath:(SSJCaterotyMenuSelectionViewIndexPath *)indexPath {
    SSJBillTypeCategoryModel *category = [self.currentCategories ssj_safeObjectAtIndex:indexPath.categoryIndex];
    SSJCaterotyMenuSelectionCellItem *item = [category.items ssj_safeObjectAtIndex:indexPath.itemIndex];
    self.topView.billTypeIcon = item.icon;
    self.topView.billTypeName = item.title;
}

#pragma mark - YYKeyboardObserver
- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    CGFloat bottom = transition.toVisible ? [YYKeyboardManager defaultManager].keyboardFrame.size.height : 0;
    self.bodyView.contentInsets = UIEdgeInsetsMake(0, 0, bottom, 0);
}

#pragma mark - Private
- (void)loadColors {
    NSMutableArray *colors = [NSMutableArray array];
    for (NSString *colorValue in [SSJCategoryListHelper payOutColors]) {
        [colors addObject:[UIColor ssj_colorWithHex:colorValue]];
    }
    self.colorSelectionView.colors = colors;
    self.topView.billTypeColor =  [colors firstObject];
}

- (NSArray<SSJBillTypeCategoryModel *> *)currentCategories {
    if (self.expended) {
        NSNumber *booksTypeValue = [self.booksTypes ssj_safeObjectAtIndex:self.bodyView.selectedIndexPath.menuIndex];
        NSArray *categories = self.catgegoriesInfo[booksTypeValue];
        if (categories) {
            return categories;
        }
        categories = [SSJCreateOrEditBillTypeHelper expenseCategoriesWithBooksType:[booksTypeValue integerValue]];
        self.catgegoriesInfo[booksTypeValue] = categories;
        return categories;
    } else {
        NSArray *categories = self.catgegoriesInfo[kCatgegoriesInfoIncomeKey];
        if (categories) {
            return categories;
        }
        categories = [SSJCreateOrEditBillTypeHelper incomeCategories];
        self.catgegoriesInfo[kCatgegoriesInfoIncomeKey] = categories;
        return categories;
    }
}

#pragma mark - Lazyloading
- (SSJCreateOrEditBillTypeTopView *)topView {
    if (!_topView) {
        _topView = [[SSJCreateOrEditBillTypeTopView alloc] init];
        __weak typeof(self) wself = self;
        _topView.tapColorAction = ^(SSJCreateOrEditBillTypeTopView *view){
            if (view.arrowDown) {
                [wself.colorSelectionView dismiss];
            } else {
                [wself.colorSelectionView show];
            }
        };
    }
    return _topView;
}

- (SSJCaterotyMenuSelectionView *)bodyView {
    if (!_bodyView) {
        _bodyView = [[SSJCaterotyMenuSelectionView alloc] init];
        _bodyView.dataSource = self;
        _bodyView.delegate = self;
        [_bodyView setSelectedIndexPath:[SSJCaterotyMenuSelectionViewIndexPath indexPathWithMenuIndex:0 categoryIndex:-1 itemIndex:-1]];
    }
    return _bodyView;
}

- (SSJCreateOrEditBillTypeColorSelectionView *)colorSelectionView {
    if (!_colorSelectionView) {
        _colorSelectionView = [[SSJCreateOrEditBillTypeColorSelectionView alloc] init];
        __weak typeof(self) wself = self;
        _colorSelectionView.selectColorAction = ^(SSJCreateOrEditBillTypeColorSelectionView *view) {
            [view dismiss];
            [wself.topView setArrowDown:YES animated:YES];
            [UIView animateWithDuration:0.25 animations:^{
                wself.topView.billTypeColor = view.colors[view.selectedIndex];
            }];
        };
    }
    return _colorSelectionView;
}

- (NSArray<NSNumber *> *)booksTypes {
    if (!_booksTypes) {
        _booksTypes = @[@(SSJBooksTypeDaily),
                        @(SSJBooksTypeBaby),
                        @(SSJBooksTypeBusiness),
                        @(SSJBooksTypeTravel),
                        @(SSJBooksTypeDecoration),
                        @(SSJBooksTypeMarriage)];
    }
    return _booksTypes;
}

@end
