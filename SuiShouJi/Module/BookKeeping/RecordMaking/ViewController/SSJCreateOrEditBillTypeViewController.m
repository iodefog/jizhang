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
#import "SSJBillTypeLibraryModel.h"
#import "SSJBillTypeManager.h"
#import "SSJCategoryListHelper.h"
#import "YYKeyboardManager.h"
#import "SSJBooksTypeStore.h"

static NSString *const kCatgegoriesInfoIncomeKey = @"kCatgegoriesInfoIncomeKey";

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJCreateOrEditBillTypeViewController
#pragma mark -
@interface SSJCreateOrEditBillTypeViewController () <SSJCaterotyMenuSelectionViewDataSource, SSJCaterotyMenuSelectionViewDelegate, YYKeyboardObserver>

@property (nonatomic, strong) SSJCreateOrEditBillTypeTopView *topView;

@property (nonatomic, strong) SSJCaterotyMenuSelectionView *bodyView;

@property (nonatomic, strong) SSJCreateOrEditBillTypeColorSelectionView *colorSelectionView;

@property (nonatomic) SSJBooksType booksType;

@property (nonatomic, strong) NSArray<NSNumber *> *booksTypes;

@property (nonatomic, strong) SSJBillTypeLibraryModel *libraryModel;

@end

@implementation SSJCreateOrEditBillTypeViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[YYKeyboardManager defaultManager] addObserver:self];
        self.booksType = -1;
        self.libraryModel = [[SSJBillTypeLibraryModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.bodyView];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.colorSelectionView];
    
    [self loadColors];
    
    [[[self loadBooksTypeIfNeeded] then:^RACSignal *{
        return [self loadSelectedIndexPath];
    }] subscribeNext:^(SSJCaterotyMenuSelectionViewIndexPath *indexPath) {
        [self.bodyView reloadAllData];
        self.bodyView.selectedIndexPath = indexPath;

        SSJBillTypeCategoryModel *category = [self.currentCategories ssj_safeObjectAtIndex:indexPath.categoryIndex];
        SSJBillTypeModel *item = [category.items ssj_safeObjectAtIndex:indexPath.itemIndex];
        self.topView.billTypeIcon = [UIImage imageNamed:item.icon];
        self.topView.billTypeName = item.name;
        
    } error:^(NSError *error) {
        [CDAutoHideMessageHUD showError:error];
    }];
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
    SSJBillTypeModel *model = [category.items ssj_safeObjectAtIndex:indexPath.itemIndex];
    return [SSJCaterotyMenuSelectionCellItem itemWithTitle:model.name icon:[UIImage imageNamed:model.icon] color:[UIColor ssj_colorWithHex:model.color]];
}

#pragma mark - SSJCaterotyMenuSelectionViewDelegate
- (void)selectionView:(SSJCaterotyMenuSelectionView *)selectionView didSelectMenuAtIndex:(NSInteger)menuIndex {
    self.booksType = [[self.booksTypes objectAtIndex:menuIndex] integerValue];
}

- (void)selectionView:(SSJCaterotyMenuSelectionView *)selectionView didSelectItemAtIndexPath:(SSJCaterotyMenuSelectionViewIndexPath *)indexPath {
    SSJBillTypeCategoryModel *category = [self.currentCategories ssj_safeObjectAtIndex:indexPath.categoryIndex];
    SSJBillTypeModel *item = [category.items ssj_safeObjectAtIndex:indexPath.itemIndex];
    [self.topView setBillTypeIcon:[UIImage imageNamed:item.icon] animated:YES];
    [self.topView setBillTypeName:item.name animated:YES];
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
    self.colorSelectionView.selectedIndex = 0;
    self.topView.billTypeColor =  [colors firstObject];
}

- (NSArray<SSJBillTypeCategoryModel *> *)currentCategories {
    if (self.expended) {
        return [self.libraryModel expenseCategoriesWithBooksType:self.booksType];
    } else {
        return [self.libraryModel incomeCategories];
    }
}

- (RACSignal *)loadBooksTypeIfNeeded {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (self.expended) {
            [SSJBooksTypeStore queryBooksItemWithID:self.booksId success:^(id<SSJBooksItemProtocol> booksItem) {
                self.booksType = booksItem.booksParent;
                [subscriber sendCompleted];
            } failure:^(NSError *error) {
                [subscriber sendError:error];
            }];
        } else {
            [subscriber sendCompleted];
        }
        return nil;
    }];
}

- (RACSignal *)loadSelectedIndexPath {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSInteger menuIndex = [self.booksTypes indexOfObject:@(self.booksType)];
        if (self.icon.length) {
            __block SSJCaterotyMenuSelectionViewIndexPath *indexPath = nil;
            [[self currentCategories] enumerateObjectsUsingBlock:^(SSJBillTypeCategoryModel * _Nonnull categoryModel, NSUInteger categoryIdx, BOOL * _Nonnull stop) {
                [categoryModel.items enumerateObjectsUsingBlock:^(SSJBillTypeModel * _Nonnull billModel, NSUInteger itemIdx, BOOL * _Nonnull stop) {
                    if ([billModel.icon isEqualToString:self.icon]) {
                        indexPath = [SSJCaterotyMenuSelectionViewIndexPath indexPathWithMenuIndex:menuIndex categoryIndex:categoryIdx itemIndex:itemIdx];
                        *stop = YES;
                    }
                }];
                
                if (indexPath) {
                    *stop = YES;
                }
            }];
            
            if (!indexPath) {
                indexPath = [SSJCaterotyMenuSelectionViewIndexPath indexPathWithMenuIndex:menuIndex categoryIndex:-1 itemIndex:-1];
            }
            
            [subscriber sendNext:indexPath];
            [subscriber sendCompleted];
        } else {
            [subscriber sendNext:[SSJCaterotyMenuSelectionViewIndexPath indexPathWithMenuIndex:menuIndex categoryIndex:0 itemIndex:0]];
            [subscriber sendCompleted];
        }
        return nil;
    }];
}

#pragma mark - Lazyloading
- (SSJCreateOrEditBillTypeTopView *)topView {
    if (!_topView) {
        _topView = [[SSJCreateOrEditBillTypeTopView alloc] init];
        _topView.billTypeColor = [UIColor ssj_colorWithHex:self.color];
        _topView.billTypeIcon = [UIImage imageNamed:self.icon];
        _topView.billTypeName = self.name;
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
        _bodyView = [[SSJCaterotyMenuSelectionView alloc] initWithFrame:CGRectZero style:(self.expended ? SSJCaterotyMenuSelectionViewMenuLeft : SSJCaterotyMenuSelectionViewNoMenu)];
        _bodyView.dataSource = self;
        _bodyView.delegate = self;
        _bodyView.numberOfItemPerRow = self.expended ? 4 : 5;
    }
    return _bodyView;
}

- (SSJCreateOrEditBillTypeColorSelectionView *)colorSelectionView {
    if (!_colorSelectionView) {
        _colorSelectionView = [[SSJCreateOrEditBillTypeColorSelectionView alloc] init];
        __weak typeof(self) wself = self;
        _colorSelectionView.selectColorAction = ^(SSJCreateOrEditBillTypeColorSelectionView *view) {
            [wself.topView setArrowDown:YES animated:YES];
            [wself.topView setBillTypeColor:view.colors[view.selectedIndex] animated:YES];
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
