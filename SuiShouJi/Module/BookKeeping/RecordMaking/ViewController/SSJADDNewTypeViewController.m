//
//  SSJADDNewTypeViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJADDNewTypeViewController.h"
#import "SSJCategoryCollectionViewCell.h"
#import "SSJRecordMakingCategoryItem.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "FMDB.h"

#import "SSJSegmentedControl.h"
#import "SCYSlidePagingHeaderView.h"
#import "SSJAddNewTypeColorSelectionView.h"
#import "SSJNewOrEditCustomCategoryView.h"
#import "SSJCategoryListHelper.h"

static NSString *const kCellId = @"CategoryCollectionViewCellIdentifier";

@interface SSJADDNewTypeViewController () <UITextFieldDelegate, SCYSlidePagingHeaderViewDelegate>

@property (nonatomic, strong) NSMutableArray *items;

@property (nonatomic, strong) NSArray *customItems;

@property (nonatomic, strong) SSJSegmentedControl *titleSegmentView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) SCYSlidePagingHeaderView *customCategorySwitchConrol;

@property (nonatomic, strong) UICollectionView *featuredCategoryCollectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *newCategoryLayout;

@property (nonatomic, strong) SSJNewOrEditCustomCategoryView *newOrEditCategoryView;

@property (nonatomic) NSInteger newCategorySelectedIndex;

@end

@implementation SSJADDNewTypeViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"添加新类别";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadData];
    
    [self ssj_showBackButtonWithTarget:self selector:@selector(goBackAction)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"checkmark"] style:UIBarButtonItemStylePlain target:self action:@selector(comfirmButtonClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.navigationItem.titleView = self.titleSegmentView;
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.featuredCategoryCollectionView];
    [self.scrollView addSubview:self.customCategorySwitchConrol];
    [self.scrollView addSubview:self.newOrEditCategoryView];
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return (_titleSegmentView.selectedSegmentIndex ? _customItems.count : _items.count);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SSJCategoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    NSArray *currentItems = (_titleSegmentView.selectedSegmentIndex ? _customItems : _items);
    cell.item = (SSJRecordMakingCategoryItem*)[currentItems ssj_safeObjectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _featuredCategoryCollectionView) {
        if (self.incomeOrExpence) {
            [MobClick event:@"add_user_bill_in"];
        }else{
            [MobClick event:@"add_user_bill_out"];
        }
        _newCategorySelectedIndex = indexPath.item;
        for (int i = 0; i < _items.count; i ++) {
            SSJRecordMakingCategoryItem *item = _items[i];
            item.selected = i == _newCategorySelectedIndex;
        }
        [_featuredCategoryCollectionView reloadData];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _scrollView) {
        _titleSegmentView.selectedSegmentIndex = _scrollView.contentOffset.x / _scrollView.width;
        [self loadData];
    }
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    
}

#pragma mark - Event
-(void)comfirmButtonClick:(id)sender{
    if (_titleSegmentView.selectedSegmentIndex == 0) {
        SSJRecordMakingCategoryItem *item = [_items ssj_safeObjectAtIndex:_newCategorySelectedIndex];
        [SSJCategoryListHelper addNewCategoryWithidentifier:item.categoryID incomeOrExpenture:_incomeOrExpence success:^{
            [self.navigationController popViewControllerAnimated:YES];
            if (self.addNewCategoryAction) {
                self.addNewCategoryAction(item.categoryID);
            }
        } failure:^(NSError *error) {
            [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
        }];
        
    } else if (_titleSegmentView.selectedSegmentIndex == 1) {
        SSJRecordMakingCategoryItem *item = _newOrEditCategoryView.selectedItem;
        if (item.categoryTitle.length == 0) {
            [CDAutoHideMessageHUD showMessage:@"请输入类别名称"];
            return;
        } else if (item.categoryTitle.length > 4) {
            [CDAutoHideMessageHUD showMessage:@"类别名称不能超过4个字符"];
            return;
        }
        
        [SSJCategoryListHelper addNewCustomCategoryWithIncomeOrExpenture:_incomeOrExpence name:item.categoryTitle icon:item.categoryImage color:item.categoryColor success:^(NSString *categoryId){
            [self.navigationController popViewControllerAnimated:YES];
            if (self.addNewCategoryAction) {
                self.addNewCategoryAction(categoryId);
            }
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        } failure:^(NSError *error) {
            [CDAutoHideMessageHUD showMessage:[error localizedDescription]];
        }];
    }
}

- (void)titleSegmentViewAciton {
    [self loadData];
    [_scrollView setContentOffset:CGPointMake(_scrollView.width * _titleSegmentView.selectedSegmentIndex, 0) animated:YES];
    if (_titleSegmentView.selectedSegmentIndex == 0) {
        [_newOrEditCategoryView.textField resignFirstResponder];
    } else if (_titleSegmentView.selectedSegmentIndex == 1) {
        [_newOrEditCategoryView.textField becomeFirstResponder];
    }
}

#pragma mark - Getter
- (SSJSegmentedControl *)titleSegmentView {
    if (!_titleSegmentView) {
        _titleSegmentView = [[SSJSegmentedControl alloc] initWithItems:@[@"添加类别",@"自定义类别"]];
        _titleSegmentView.size = CGSizeMake(204, 44);
        _titleSegmentView.size = CGSizeMake(202, 30);
        _titleSegmentView.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _titleSegmentView.selectedBorderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
        [_titleSegmentView setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]} forState:UIControlStateNormal];
        [_titleSegmentView setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]} forState:UIControlStateSelected];
        [_titleSegmentView addTarget:self action:@selector(titleSegmentViewAciton) forControlEvents: UIControlEventValueChanged];
    }
    return _titleSegmentView;
}

- (SCYSlidePagingHeaderView *)customCategorySwitchConrol {
    if (!_customCategorySwitchConrol) {
        _customCategorySwitchConrol = [[SCYSlidePagingHeaderView alloc] initWithFrame:CGRectMake(self.scrollView.width, 0, self.scrollView.width, 40)];
        _customCategorySwitchConrol.customDelegate = self;
        _customCategorySwitchConrol.buttonClickAnimated = YES;
        _customCategorySwitchConrol.titles = @[@"已建类别", @"新建类别"];
        [_customCategorySwitchConrol setTabSize:CGSizeMake(self.view.width / _customCategorySwitchConrol.titles.count, 3)];
        [_customCategorySwitchConrol ssj_setBorderWidth:1];
        [_customCategorySwitchConrol ssj_setBorderStyle:(SSJBorderStyleTop | SSJBorderStyleBottom)];
    }
    return _customCategorySwitchConrol;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM + 10, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM - 10)];
        _scrollView.contentSize = CGSizeMake(_scrollView.width * 2, _scrollView.height);
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UICollectionView *)featuredCategoryCollectionView {
    if (!_featuredCategoryCollectionView) {
        _featuredCategoryCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 10, self.scrollView.width, self.scrollView.height - 10) collectionViewLayout:self.newCategoryLayout];
        _featuredCategoryCollectionView.dataSource = self;
        _featuredCategoryCollectionView.delegate = self;
        _featuredCategoryCollectionView.bounces = YES;
        _featuredCategoryCollectionView.alwaysBounceVertical = YES;
        [_featuredCategoryCollectionView registerClass:[SSJCategoryCollectionViewCell class] forCellWithReuseIdentifier:kCellId];
        _featuredCategoryCollectionView.contentOffset = CGPointMake(0, 0);
        _featuredCategoryCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 94, 0);
        _featuredCategoryCollectionView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return _featuredCategoryCollectionView;
}

- (UICollectionViewFlowLayout *)newCategoryLayout {
    if (!_newCategoryLayout) {
        _newCategoryLayout = [[UICollectionViewFlowLayout alloc] init];
        _newCategoryLayout.minimumInteritemSpacing = 0;
        _newCategoryLayout.minimumLineSpacing = 0;
        CGFloat width = (self.view.width - 16) * 0.2;
        _newCategoryLayout.itemSize = CGSizeMake(floor(width), 94);
        _newCategoryLayout.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8);
    }
    return _newCategoryLayout;
}

- (SSJNewOrEditCustomCategoryView *)newOrEditCategoryView {
    if (!_newOrEditCategoryView) {
        __weak typeof(self) wself = self;
        _newOrEditCategoryView = [[SSJNewOrEditCustomCategoryView alloc] initWithFrame:CGRectMake(self.scrollView.width, self.customCategorySwitchConrol.bottom + 10, self.scrollView.width, self.scrollView.height - self.customCategorySwitchConrol.bottom - 10)];
        _newOrEditCategoryView.selectCategoryAction = ^(SSJNewOrEditCustomCategoryView *view) {
            if (wself.incomeOrExpence) {
                [MobClick event:@"add_user_bill_in_custom"];
            }else{
                [MobClick event:@"add_user_bill_out_custom"];
            }
        };
        _newOrEditCategoryView.selectColorAction = ^(SSJNewOrEditCustomCategoryView *view) {
            [MobClick event:@"add_user_bill_color"];
        };
    }
    return _newOrEditCategoryView;
}

#pragma mark - private
- (void)loadData {
    [self.view ssj_showLoadingIndicator];
    if (_titleSegmentView.selectedSegmentIndex == 0 && _items.count == 0) {
        [SSJCategoryListHelper queryForUnusedCategoryListWithIncomeOrExpenture:_incomeOrExpence custom:0 success:^(NSMutableArray<SSJRecordMakingCategoryItem *> *result) {
            _items = result;
            _newCategorySelectedIndex = MIN(_newCategorySelectedIndex, _items.count - 1);
            SSJRecordMakingCategoryItem *selectedItem = _items[_newCategorySelectedIndex];
            selectedItem.selected = YES;
            [_featuredCategoryCollectionView reloadData];
            [self.view ssj_hideLoadingIndicator];
        } failure:^(NSError *error) {
            [self.view ssj_hideLoadingIndicator];
            [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL]];
        }];
    } else if (_titleSegmentView.selectedSegmentIndex == 1) {
        if (self.customCategorySwitchConrol.selectedIndex == 0 && _customItems.count == 0) {
            [SSJCategoryListHelper queryForUnusedCategoryListWithIncomeOrExpenture:_incomeOrExpence custom:1 success:^(NSMutableArray<SSJRecordMakingCategoryItem *> *result) {
                _customItems = result;
                [self.view ssj_hideLoadingIndicator];
#warning 刷新自定义类别
                
            } failure:^(NSError *error) {
                [self.view ssj_hideLoadingIndicator];
                [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL]];
            }];
        } else if (self.customCategorySwitchConrol.selectedIndex == 1 && _newOrEditCategoryView.items.count == 0) {
            // 查询自定义类别图标
            [SSJCategoryListHelper queryCustomCategoryListWithIncomeOrExpenture:_incomeOrExpence success:^(NSArray<SSJRecordMakingCategoryItem *> *items) {
                [self.view ssj_hideLoadingIndicator];
                _newOrEditCategoryView.items = items;
            } failure:^(NSError *error) {
                [self.view ssj_hideLoadingIndicator];
                [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL]];
            }];
        }
    }
}

@end
