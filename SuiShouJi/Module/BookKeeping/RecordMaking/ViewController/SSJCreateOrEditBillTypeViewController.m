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
#import "SSJBillModel.h"

#import "SSJUserTableManager.h"
#import "SSJBillTypeManager.h"
#import "SSJCategoryListHelper.h"
#import "YYKeyboardManager.h"
#import "SSJBooksTypeStore.h"
#import "SSJDataSynchronizer.h"

static const int kBillNameLimit = 4;
static const NSTimeInterval kDuration = 0.25;

static NSString *const kCatgegoriesInfoIncomeKey = @"kCatgegoriesInfoIncomeKey";
static NSString *const kIsCustomBillGuideShowedKey = @"kIsCustomBillGuideShowedKey";

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SSJCreateOrEditBillTypeViewController
#pragma mark -
@interface SSJCreateOrEditBillTypeViewController () <SSJCaterotyMenuSelectionViewDataSource, SSJCaterotyMenuSelectionViewDelegate, YYKeyboardObserver>

@property (nonatomic, strong) SSJCreateOrEditBillTypeTopView *topView;

@property (nonatomic, strong) SSJCaterotyMenuSelectionView *bodyView;

@property (nonatomic, strong) SSJCreateOrEditBillTypeColorSelectionView *colorSelectionView;

@property (nonatomic, strong) UIImageView *guideView;

@property (nonatomic) SSJBooksType booksType;

@property (nonatomic, strong) NSArray<NSNumber *> *booksTypes;

@property (nonatomic, strong) SSJBillTypeLibraryModel *libraryModel;

@property (nonatomic, strong) NSArray<NSString *> *colors;

@end

@implementation SSJCreateOrEditBillTypeViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[YYKeyboardManager defaultManager] addObserver:self];
        self.booksType = -1;
        self.libraryModel = [[SSJBillTypeLibraryModel alloc] init];
        self.colors = [SSJCategoryListHelper billTypeLibraryColors];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateTitle];
    [self setupViews];
    [self setupBindings];
    [self organiseColors];
    
    [[[self loadBooksIdIfNeeded] then:^RACSignal *{
        return [self loadBooksTypeIfNeeded];
    }] subscribeError:^(NSError *error) {
        [CDAutoHideMessageHUD showError:error];
    } completed:^{
        SSJCaterotyMenuSelectionViewIndexPath *indexPath = [self selectedIndexPath];
        
        [self.bodyView reloadAllData];
        self.bodyView.selectedIndexPath = indexPath;
        
        SSJBillTypeCategoryModel *category = [self.currentCategories ssj_safeObjectAtIndex:indexPath.categoryIndex];
        SSJBillTypeModel *item = [category.items ssj_safeObjectAtIndex:indexPath.itemIndex];
        self.icon = self.icon ?: item.icon;
        self.name = self.name ?: item.name;
        self.color = self.color ?: item.color;
    }];
    [self showGuideViewIfNeeded];
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
    return [NSString stringWithFormat:@"【%@】", category.title];
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
    selectionView.selectedIndexPath = [self selectedIndexPath];
}

- (void)selectionView:(SSJCaterotyMenuSelectionView *)selectionView didSelectItemAtIndexPath:(SSJCaterotyMenuSelectionViewIndexPath *)indexPath {
    SSJBillTypeCategoryModel *category = [self.currentCategories ssj_safeObjectAtIndex:indexPath.categoryIndex];
    SSJBillTypeModel *item = [category.items ssj_safeObjectAtIndex:indexPath.itemIndex];
    self.icon = item.icon;
    if (!self.topView.userTypeInBillName) {
        self.name = item.name;
    }
    if (self.colorSelectionView.selectedIndex == NSNotFound) {
        self.color = item.color;
    }
}

#pragma mark - YYKeyboardObserver
- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    CGFloat bottom = transition.toVisible ? [YYKeyboardManager defaultManager].keyboardFrame.size.height : 0;
    self.bodyView.contentInsets = UIEdgeInsetsMake(0, 0, bottom, 0);
}

#pragma mark - Private
- (void)updateTitle {
    if (self.created) {
        self.title = self.expended ? @"添加支出类别" : @"添加收入类别";
    } else {
        self.title = [NSString stringWithFormat:@"修改“%@”", self.name];
    }
}

- (void)setupViews {
    [self.view addSubview:self.bodyView];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.colorSelectionView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"完成", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
}

- (void)setupBindings {
    @weakify(self);
    [RACObserve(self, icon) subscribeNext:^(NSString *icon) {
        @strongify(self);
        [self.topView setBillTypeIcon:[UIImage imageNamed:icon] animated:YES];
    }];
    [RACObserve(self, color) subscribeNext:^(NSString *color) {
        @strongify(self);
        [self.topView setBillTypeColor:[UIColor ssj_colorWithHex:color] animated:YES];
    }];
    RACChannelTo(self.topView, billTypeName) = RACChannelTo(self, name);
}

- (void)organiseColors {
    NSMutableArray *colors = [NSMutableArray array];
    for (NSString *colorValue in self.colors) {
        [colors addObject:[UIColor ssj_colorWithHex:colorValue]];
    }
    self.colorSelectionView.colors = colors;
    self.colorSelectionView.selectedIndex = [self.colors indexOfObject:self.color];
}

- (NSArray<SSJBillTypeCategoryModel *> *)currentCategories {
    if (self.expended) {
        return [self.libraryModel expenseCategoriesWithBooksType:self.booksType];
    } else {
        return [self.libraryModel incomeCategories];
    }
}

- (RACSignal *)loadBooksIdIfNeeded {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (self.booksId.length) {
            [subscriber sendCompleted];
        } else {
            [SSJUserTableManager currentBooksId:^(NSString * _Nonnull booksId) {
                self.booksId = booksId;
                [subscriber sendCompleted];
            } failure:^(NSError * _Nonnull error) {
                [subscriber sendError:error];
            }];
        }
        return nil;
    }];
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

- (SSJCaterotyMenuSelectionViewIndexPath *)selectedIndexPath {
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
        return indexPath;
    } else {
        return [SSJCaterotyMenuSelectionViewIndexPath indexPathWithMenuIndex:menuIndex categoryIndex:0 itemIndex:0];
    }
}

- (void)doneAction {
    if (self.name.length == 0) {
        [CDAutoHideMessageHUD showMessage:@"请输入类别名称"];
        return;
    }
    
    if (self.name.length > kBillNameLimit) {
        [CDAutoHideMessageHUD showMessage:[NSString stringWithFormat:@"类别名称不能超过%d个字符", kBillNameLimit]];
        return;
    }
    
    [SSJCategoryListHelper querySameNameCategoryWithName:self.name exceptForBillID:self.billId booksId:self.booksId expended:self.expended success:^(SSJBillModel *model) {
        if (model && model.operatorType != 2) {
            // 有同名称类别，不支持新建／修改
            [CDAutoHideMessageHUD showMessage:@"已有同名称类别，换个名称吧"];
        } else if (model && model.operatorType == 2 && self.created) {
            // 恢复已删除的类别
            [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"该类别名称曾经使用过，是否将之前的流水合并过来？" action:[SSJAlertViewAction actionWithTitle:@"不合并" handler:^(SSJAlertViewAction *action) {
                [self addNewCategoryWithName:self.name image:self.icon color:self.color];
            }], [SSJAlertViewAction actionWithTitle:@"合并" handler:^(SSJAlertViewAction *action) {
                int order = [SSJCategoryListHelper queryForBillTypeMaxOrderWithType:model.type booksId:self.booksId] + 1;
                [self updateBillTypeWithID:model.ID
                                      name:model.name
                                     color:self.color
                                     image:self.icon
                                     order:order];
            }], nil];
        } else if (self.created) {
            [self addNewCategoryWithName:self.name image:self.icon color:self.color];
        } else {
            [self updateBillTypeWithID:self.billId
                                  name:self.name
                                 color:self.color
                                 image:self.icon
                                 order:SSJImmovableOrder];
        }
    } failure:^(NSError *error) {
        [CDAutoHideMessageHUD showError:error];
    }];
}

- (void)addNewCategoryWithName:(NSString *)name image:(NSString *)image color:(NSString *)color {
    [SSJCategoryListHelper addNewCustomCategoryWithIncomeOrExpenture:self.expended name:name icon:image color:color booksId:self.booksId success:^(NSString *categoryId){
        [self.navigationController popViewControllerAnimated:YES];
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        if (self.saveHandler) {
            self.saveHandler(categoryId);
        }
    } failure:^(NSError *error) {
        [CDAutoHideMessageHUD showError:error];
    }];
}

- (void)updateBillTypeWithID:(NSString *)ID name:(NSString *)name color:(NSString *)color image:(NSString *)image order:(int)order {
    [SSJCategoryListHelper updateCategoryWithID:ID name:name color:color image:image order:order booksId:self.booksId success:^(NSString *categoryId) {
        [self.navigationController popViewControllerAnimated:YES];
        if (self.saveHandler) {
            self.saveHandler(categoryId);
        }
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError *error) {
        [CDAutoHideMessageHUD showError:error];
    }];
}

- (BOOL)showGuideViewIfNeeded {
    BOOL isEverEntered = [[NSUserDefaults standardUserDefaults] boolForKey:kIsCustomBillGuideShowedKey];
    if (!isEverEntered) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsCustomBillGuideShowedKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        self.guideView.frame = window.bounds;
        [UIView transitionWithView:window duration:kDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [window addSubview:self.guideView];
        } completion:NULL];
    }
    return !isEverEntered;
}

- (void)hideGuideView {
    if (self.guideView.superview) {
        [UIView transitionWithView:self.guideView.superview duration:kDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.guideView removeFromSuperview];
            self.guideView = nil;
        } completion:NULL];
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
        _bodyView = [[SSJCaterotyMenuSelectionView alloc] initWithFrame:CGRectZero style:(self.expended ? SSJCaterotyMenuSelectionViewMenuLeft : SSJCaterotyMenuSelectionViewNoMenu)];
        _bodyView.dataSource = self;
        _bodyView.delegate = self;
        _bodyView.numberOfItemPerRow = self.expended ? 4 : 5;
    }
    return _bodyView;
}

- (SSJCreateOrEditBillTypeColorSelectionView *)colorSelectionView {
    if (!_colorSelectionView) {
        __weak typeof(self) wself = self;
        _colorSelectionView = [[SSJCreateOrEditBillTypeColorSelectionView alloc] init];
        _colorSelectionView.selectColorAction = ^(SSJCreateOrEditBillTypeColorSelectionView *view) {
            wself.color = wself.colors[view.selectedIndex];
        };
        _colorSelectionView.dismissHandler = ^(SSJCreateOrEditBillTypeColorSelectionView * _Nonnull view) {
            [wself.topView setArrowDown:YES animated:YES];
        };
    }
    return _colorSelectionView;
}

- (UIImageView *)guideView {
    if (!_guideView) {
        _guideView = [[UIImageView alloc] initWithImage:[UIImage ssj_compatibleImageNamed:@"record_making_guide_1"]];
        _guideView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideGuideView)];
        [_guideView addGestureRecognizer:tap];
    }
    return _guideView;
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
