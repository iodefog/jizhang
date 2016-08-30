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
#import "SSJCategoryEditableCollectionView.h"
#import "SSJNewOrEditCustomCategoryView.h"
#import "SSJCategoryListHelper.h"

static NSString *const kCellId = @"CategoryCollectionViewCellIdentifier";

@interface SSJADDNewTypeViewController () <UIScrollViewDelegate, UITextFieldDelegate, SCYSlidePagingHeaderViewDelegate>

@property (nonatomic, strong) SSJSegmentedControl *titleSegmentView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) SCYSlidePagingHeaderView *customCategorySwitchConrol;

@property (nonatomic, strong) SSJCategoryEditableCollectionView *featuredCategoryCollectionView;

@property (nonatomic, strong) SSJCategoryEditableCollectionView *customCategoryCollectionView;

@property (nonatomic, strong) SSJNewOrEditCustomCategoryView *newOrEditCategoryView;

@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) UIButton *editButton;

@property (nonatomic, strong) UIButton *deleteButton;

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
    [self.scrollView addSubview:self.customCategoryCollectionView];
    [self.scrollView addSubview:self.newOrEditCategoryView];
    [self updateHidden];
    [self updateAppearance];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
    [self.featuredCategoryCollectionView updateAppearance];
    [self.customCategoryCollectionView updateAppearance];
}
//#pragma mark - UICollectionViewDelegate
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (collectionView == _featuredCategoryCollectionView) {
//        if (self.incomeOrExpence) {
//            [MobClick event:@"add_user_bill_in"];
//        }else{
//            [MobClick event:@"add_user_bill_out"];
//        }
//        _newCategorySelectedIndex = indexPath.item;
//        for (int i = 0; i < _items.count; i ++) {
//            SSJRecordMakingCategoryItem *item = _items[i];
//            item.selected = i == _newCategorySelectedIndex;
//        }
//        [_featuredCategoryCollectionView reloadData];
//    }
//}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _scrollView) {
        _titleSegmentView.selectedSegmentIndex = _scrollView.contentOffset.x / _scrollView.width;
        [self loadData];
        [self showOrHideKeyboard];
    }
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    [self loadData];
    [self updateHidden];
    [self showOrHideKeyboard];
}

#pragma mark - Event
-(void)comfirmButtonClick:(id)sender{
//    if (_titleSegmentView.selectedSegmentIndex == 0) {
//        SSJRecordMakingCategoryItem *item = [_items ssj_safeObjectAtIndex:_newCategorySelectedIndex];
//        [SSJCategoryListHelper addNewCategoryWithidentifier:item.categoryID incomeOrExpenture:_incomeOrExpence success:^{
//            [self.navigationController popViewControllerAnimated:YES];
//            if (self.addNewCategoryAction) {
//                self.addNewCategoryAction(item.categoryID);
//            }
//        } failure:^(NSError *error) {
//            [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
//        }];
//        
//    } else if (_titleSegmentView.selectedSegmentIndex == 1) {
//        SSJRecordMakingCategoryItem *item = _newOrEditCategoryView.selectedItem;
//        if (item.categoryTitle.length == 0) {
//            [CDAutoHideMessageHUD showMessage:@"请输入类别名称"];
//            return;
//        } else if (item.categoryTitle.length > 4) {
//            [CDAutoHideMessageHUD showMessage:@"类别名称不能超过4个字符"];
//            return;
//        }
//        
//        [SSJCategoryListHelper addNewCustomCategoryWithIncomeOrExpenture:_incomeOrExpence name:item.categoryTitle icon:item.categoryImage color:item.categoryColor success:^(NSString *categoryId){
//            [self.navigationController popViewControllerAnimated:YES];
//            if (self.addNewCategoryAction) {
//                self.addNewCategoryAction(categoryId);
//            }
//            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
//        } failure:^(NSError *error) {
//            [CDAutoHideMessageHUD showMessage:[error localizedDescription]];
//        }];
//    }
}

- (void)titleSegmentViewAciton {
    [self loadData];
    [self showOrHideKeyboard];
    [_scrollView setContentOffset:CGPointMake(_scrollView.width * _titleSegmentView.selectedSegmentIndex, 0) animated:YES];
}

#pragma mark - private
- (void)loadData {
    [self.view ssj_showLoadingIndicator];
    if (_titleSegmentView.selectedSegmentIndex == 0
        && _featuredCategoryCollectionView.items.count == 0) {
        
        [SSJCategoryListHelper queryForUnusedCategoryListWithIncomeOrExpenture:_incomeOrExpence custom:0 success:^(NSMutableArray<SSJRecordMakingCategoryItem *> *result) {
            _featuredCategoryCollectionView.items = result;
            [self.view ssj_hideLoadingIndicator];
        } failure:^(NSError *error) {
            [self.view ssj_hideLoadingIndicator];
            [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL]];
        }];
        
    } else if (_titleSegmentView.selectedSegmentIndex == 1) {
        
        if (self.customCategorySwitchConrol.selectedIndex == 0
            && _customCategoryCollectionView.items.count == 0) {
            
            [SSJCategoryListHelper queryForUnusedCategoryListWithIncomeOrExpenture:_incomeOrExpence custom:1 success:^(NSMutableArray<SSJRecordMakingCategoryItem *> *result) {
                _customCategoryCollectionView.items = result;
                [self.view ssj_hideLoadingIndicator];
            } failure:^(NSError *error) {
                [self.view ssj_hideLoadingIndicator];
                [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL]];
            }];
            
        } else if (self.customCategorySwitchConrol.selectedIndex == 1
                   && _newOrEditCategoryView.items.count == 0) {
            // 查询自定义类别图标
            [SSJCategoryListHelper queryCustomCategoryListWithIncomeOrExpenture:_incomeOrExpence success:^(NSArray<SSJRecordMakingCategoryItem *> *items) {
                [self.view ssj_hideLoadingIndicator];
                _newOrEditCategoryView.items = items;
                _newOrEditCategoryView.colors = _incomeOrExpence ? [SSJCategoryListHelper payOutColors] : [SSJCategoryListHelper incomeColors];
            } failure:^(NSError *error) {
                [self.view ssj_hideLoadingIndicator];
                [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL]];
            }];
        }
    }
}

- (void)updateAppearance {
    _titleSegmentView.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _titleSegmentView.selectedBorderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    [_titleSegmentView setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]} forState:UIControlStateNormal];
    [_titleSegmentView setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]} forState:UIControlStateSelected];
    
    _customCategorySwitchConrol.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    [_customCategorySwitchConrol ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    _customCategorySwitchConrol.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _customCategorySwitchConrol.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    
    _featuredCategoryCollectionView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:SSJ_CURRENT_THEME.backgroundAlpha];
}

- (void)updateHidden {
    if (_customCategorySwitchConrol.selectedIndex == 0) {
        _customCategoryCollectionView.hidden = NO;
        _newOrEditCategoryView.hidden = YES;
    } else if (_customCategorySwitchConrol.selectedIndex == 1) {
        _customCategoryCollectionView.hidden = YES;
        _newOrEditCategoryView.hidden = NO;
    }
}

- (void)showOrHideKeyboard {
    if (_titleSegmentView.selectedSegmentIndex == 1 && _customCategorySwitchConrol.selectedIndex == 1) {
        [_newOrEditCategoryView.textField becomeFirstResponder];
    } else {
        [_newOrEditCategoryView.textField resignFirstResponder];
    }
}

#pragma mark - Getter
- (SSJSegmentedControl *)titleSegmentView {
    if (!_titleSegmentView) {
        _titleSegmentView = [[SSJSegmentedControl alloc] initWithItems:@[@"添加类别",@"自定义类别"]];
        _titleSegmentView.size = CGSizeMake(204, 44);
        _titleSegmentView.size = CGSizeMake(202, 30);
        [_titleSegmentView addTarget:self action:@selector(titleSegmentViewAciton) forControlEvents: UIControlEventValueChanged];
    }
    return _titleSegmentView;
}

- (SCYSlidePagingHeaderView *)customCategorySwitchConrol {
    if (!_customCategorySwitchConrol) {
        _customCategorySwitchConrol = [[SCYSlidePagingHeaderView alloc] initWithFrame:CGRectMake(self.scrollView.width, 0, self.scrollView.width, 40)];
        _customCategorySwitchConrol.customDelegate = self;
        _customCategorySwitchConrol.buttonClickAnimated = NO;
        _customCategorySwitchConrol.titles = @[@"已建类别", @"新建类别"];
        [_customCategorySwitchConrol setTabSize:CGSizeMake(self.view.width / _customCategorySwitchConrol.titles.count, 3)];
        [_customCategorySwitchConrol ssj_setBorderWidth:1];
        [_customCategorySwitchConrol ssj_setBorderStyle:(SSJBorderStyleTop | SSJBorderStyleBottom)];
    }
    return _customCategorySwitchConrol;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM)];
        _scrollView.contentSize = CGSizeMake(_scrollView.width * 2, _scrollView.height);
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (SSJCategoryEditableCollectionView *)featuredCategoryCollectionView {
    if (!_featuredCategoryCollectionView) {
        _featuredCategoryCollectionView = [[SSJCategoryEditableCollectionView alloc] initWithFrame:CGRectMake(0, 10, self.scrollView.width, self.scrollView.height - 10)];
    }
    return _featuredCategoryCollectionView;
}

- (SSJCategoryEditableCollectionView *)customCategoryCollectionView {
    if (!_customCategoryCollectionView) {
        _customCategoryCollectionView = [[SSJCategoryEditableCollectionView alloc] initWithFrame:CGRectMake(self.scrollView.width, self.customCategorySwitchConrol.bottom + 10, self.scrollView.width, self.scrollView.height - self.customCategorySwitchConrol.bottom - 10)];
    }
    return _customCategoryCollectionView;
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

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.frame = CGRectMake(0, self.view.height - 50, self.view.width, 50);
        _sureButton.titleLabel.font = [UIFont systemFontOfSize:20];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton setTitle:@"" forState:UIControlStateDisabled];
        [_sureButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor alpha:0.8] forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(sureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

- (UIButton *)editButton {
    if (!_editButton) {
//        NSMutableAttributedString *title = [nsmuta]
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _editButton.frame = CGRectMake(0, self.view.height - 50, self.view.width, 50);
        _editButton.titleLabel.font = [UIFont systemFontOfSize:20];
        [_editButton setTitle:@"确定" forState:UIControlStateNormal];
//        [_editButton setAttributedTitle:<#(nullable NSAttributedString *)#> forState:UIControlStateNormal];
        [_editButton setTitle:@"" forState:UIControlStateDisabled];
        [_editButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor alpha:0.8] forState:UIControlStateNormal];
        [_editButton addTarget:self action:@selector(editButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}

@end
