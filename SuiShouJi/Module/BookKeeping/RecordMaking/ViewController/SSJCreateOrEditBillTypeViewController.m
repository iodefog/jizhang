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

#import "SSJCategoryListHelper.h"

@interface SSJCreateOrEditBillTypeViewController () <SSJCaterotyMenuSelectionViewDataSource, SSJCaterotyMenuSelectionViewDelegate>

@property (nonatomic, strong) SSJCreateOrEditBillTypeTopView *topView;

@property (nonatomic, strong) SSJCaterotyMenuSelectionView *bodyView;

@property (nonatomic, strong) SSJCreateOrEditBillTypeColorSelectionView *colorSelectionView;

@property (nonatomic, strong) NSArray *menuTitle;

@property (nonatomic, strong) NSArray<NSArray<SSJCaterotyMenuSelectionCellItem *> *> *categoryItems1;

@property (nonatomic, strong) NSArray<NSArray<SSJCaterotyMenuSelectionCellItem *> *> *categoryItems2;

@end

@implementation SSJCreateOrEditBillTypeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.categoryItems1 = @[@[[SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]],
                                  [SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]]],
                                @[[SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]],
                                  [SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]],
                                  [SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]],
                                  [SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]],
                                  [SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]],
                                  
                                  [SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]],
                                  [SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]],
                                  [SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]],
                                  [SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]]]];
        
        self.categoryItems2 = @[@[[SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]],
                                  [SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]]],
                                @[[SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]],
                                  [SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]],
                                  [SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]],
                                  [SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]],
                                  [SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]],
                                  [SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]],
                                  [SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]],
                                  [SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]],
                                  [SSJCaterotyMenuSelectionCellItem itemWithTitle:@"category_1"
                                                                             icon:[UIImage imageNamed:@"bt_baby"]
                                                                            color:[UIColor orangeColor]]]];
        
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
    return 2;
}

- (NSString *)selectionView:(SSJCaterotyMenuSelectionView *)selectionView titleForLeftMenuAtIndex:(NSInteger)index {
    return [NSString stringWithFormat:@"title_%d", (int)index];
}

- (NSUInteger)selectionView:(SSJCaterotyMenuSelectionView *)selectionView numberOfCategoriesAtMenuIndex:(NSInteger)index {
    if (index == 0) {
        return self.categoryItems1.count;
    } else if (index == 1) {
        return self.categoryItems2.count;
    } else {
        return 0;
    }
}

- (NSString *)selectionView:(SSJCaterotyMenuSelectionView *)selectionView titleForCategoryAtIndex:(NSInteger)categoryIndex menuIndex:(NSInteger)menuIndex {
    return @"test";
}

- (NSUInteger)selectionView:(SSJCaterotyMenuSelectionView *)selectionView numberOfItemsAtCategoryIndex:(NSInteger)categoryIndex menuIndex:(NSInteger)menuIndex {
    if (menuIndex == 0) {
        NSArray *items = self.categoryItems1[categoryIndex];
        return items.count;
    } else if (menuIndex == 1) {
        NSArray *items = self.categoryItems2[categoryIndex];
        return items.count;
    } else {
        return 0;
    }
}

- (SSJCaterotyMenuSelectionCellItem *)selectionView:(SSJCaterotyMenuSelectionView *)selectionView itemAtIndexPath:(SSJCaterotyMenuSelectionViewIndexPath *)indexPath {
    if (indexPath.menuIndex == 0) {
        NSArray *items = self.categoryItems1[indexPath.categoryIndex];
        return items[indexPath.itemIndex];
    } else if (indexPath.menuIndex == 1) {
        NSArray *items = self.categoryItems2[indexPath.categoryIndex];
        return items[indexPath.itemIndex];
    } else {
        return nil;
    }
}

#pragma mark - SSJCaterotyMenuSelectionViewDelegate
- (void)selectionView:(SSJCaterotyMenuSelectionView *)selectionView didSelectMenuAtIndex:(NSInteger)menuIndex {
    
}

- (void)selectionView:(SSJCaterotyMenuSelectionView *)selectionView didSelectItemAtIndexPath:(SSJCaterotyMenuSelectionViewIndexPath *)indexPath {
    NSArray *items = nil;
    if (indexPath.menuIndex == 0) {
        items = self.categoryItems1[indexPath.categoryIndex];
    } else if (indexPath.menuIndex == 1) {
        items = self.categoryItems2[indexPath.categoryIndex];
    }
    
    SSJCaterotyMenuSelectionCellItem *item = items[indexPath.itemIndex];
    self.topView.billTypeIcon = item.icon;
    self.topView.billTypeName = item.title;
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

- (void)loadColors {
    NSMutableArray *colors = [NSMutableArray array];
    for (NSString *colorValue in [SSJCategoryListHelper payOutColors]) {
        [colors addObject:[UIColor ssj_colorWithHex:colorValue]];
    }
    self.colorSelectionView.colors = colors;
    self.topView.billTypeColor =  [colors firstObject];
}

@end
