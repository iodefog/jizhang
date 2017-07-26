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
#import "YYKeyboardManager.h"

@interface SSJCreateOrEditBillTypeViewController () <SSJCaterotyMenuSelectionViewDataSource, SSJCaterotyMenuSelectionViewDelegate, YYKeyboardObserver>

@property (nonatomic, strong) SSJCreateOrEditBillTypeTopView *topView;

@property (nonatomic, strong) SSJCaterotyMenuSelectionView *bodyView;

@property (nonatomic, strong) SSJCreateOrEditBillTypeColorSelectionView *colorSelectionView;

@property (nonatomic, strong) NSArray *menuTitle;

@property (nonatomic, strong) NSArray<NSArray<SSJCaterotyMenuSelectionCellItem *> *> *categoryItems1;

@end

@implementation SSJCreateOrEditBillTypeViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[YYKeyboardManager defaultManager] addObserver:self];
        [self initItems];
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
    return 20;
}

- (NSString *)selectionView:(SSJCaterotyMenuSelectionView *)selectionView titleForLeftMenuAtIndex:(NSInteger)index {
    return [NSString stringWithFormat:@"title_%d", (int)index];
}

- (NSUInteger)selectionView:(SSJCaterotyMenuSelectionView *)selectionView numberOfCategoriesAtMenuIndex:(NSInteger)index {
    return self.categoryItems1.count;
}

- (NSString *)selectionView:(SSJCaterotyMenuSelectionView *)selectionView titleForCategoryAtIndex:(NSInteger)categoryIndex menuIndex:(NSInteger)menuIndex {
    return [NSString stringWithFormat:@"menu_%d_category_%d", (int)menuIndex, (int)categoryIndex];
}

- (NSUInteger)selectionView:(SSJCaterotyMenuSelectionView *)selectionView numberOfItemsAtCategoryIndex:(NSInteger)categoryIndex menuIndex:(NSInteger)menuIndex {
    NSArray *items = self.categoryItems1[categoryIndex];
    return items.count;
}

- (SSJCaterotyMenuSelectionCellItem *)selectionView:(SSJCaterotyMenuSelectionView *)selectionView itemAtIndexPath:(SSJCaterotyMenuSelectionViewIndexPath *)indexPath {
    NSArray *items = self.categoryItems1[indexPath.categoryIndex];
    return items[indexPath.itemIndex];
}

#pragma mark - SSJCaterotyMenuSelectionViewDelegate
- (void)selectionView:(SSJCaterotyMenuSelectionView *)selectionView didSelectMenuAtIndex:(NSInteger)menuIndex {
    
}

- (void)selectionView:(SSJCaterotyMenuSelectionView *)selectionView didSelectItemAtIndexPath:(SSJCaterotyMenuSelectionViewIndexPath *)indexPath {
    NSArray *items = self.categoryItems1[indexPath.categoryIndex];
    SSJCaterotyMenuSelectionCellItem *item = items[indexPath.itemIndex];
    self.topView.billTypeIcon = item.icon;
    self.topView.billTypeName = item.title;
}

#pragma mark - YYKeyboardObserver
- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    CGFloat bottom = transition.toVisible ? [YYKeyboardManager defaultManager].keyboardFrame.size.height : 0;
    self.bodyView.contentInsets = UIEdgeInsetsMake(0, 0, bottom, 0);
}

#pragma mark - Private
//- ()

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

- (void)initItems {
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
}

@end
