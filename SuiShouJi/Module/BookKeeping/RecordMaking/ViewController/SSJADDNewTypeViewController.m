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

@property (nonatomic, strong) UIBarButtonItem *managerItem;

@property (nonatomic, strong) UIBarButtonItem *doneItem;

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
    
    self.navigationItem.titleView = self.titleSegmentView;
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.sureButton];
    [self.view addSubview:self.editButton];
    [self.view addSubview:self.deleteButton];
    [self.scrollView addSubview:self.featuredCategoryCollectionView];
    [self.scrollView addSubview:self.customCategorySwitchConrol];
    [self.scrollView addSubview:self.customCategoryCollectionView];
    [self.scrollView addSubview:self.newOrEditCategoryView];
    [self updateSubviews];
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
        [self updateSubviews];
        [self showOrHideKeyboard];
        [self updateEditButtonEnable];
    }
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    [self loadData];
    [self updateSubviews];
    [self showOrHideKeyboard];
    [self updateEditButtonEnable];
}

#pragma mark - Event
- (void)titleSegmentViewAciton {
    [self loadData];
    [self updateSubviews];
    [self showOrHideKeyboard];
    [self updateEditButtonEnable];
    [_scrollView setContentOffset:CGPointMake(_scrollView.width * _titleSegmentView.selectedSegmentIndex, 0) animated:YES];
}

- (void)managerItemAction {
    if (_titleSegmentView.selectedSegmentIndex == 0) {
        _featuredCategoryCollectionView.editing = YES;
    } else if (_titleSegmentView.selectedSegmentIndex == 1) {
        _customCategoryCollectionView.editing = YES;
    }
}

- (void)doneItemAction {
    if (_titleSegmentView.selectedSegmentIndex == 0) {
        _featuredCategoryCollectionView.editing = NO;
    } else if (_titleSegmentView.selectedSegmentIndex == 1) {
        _customCategoryCollectionView.editing = NO;
    }
}

- (void)sureButtonAction {
    if (_titleSegmentView.selectedSegmentIndex == 0) {
        // 添加系统默认类别
        for (SSJRecordMakingCategoryItem *item in _featuredCategoryCollectionView.selectedItems) {
            [SSJCategoryListHelper updateCategoryWithID:item.categoryID state:1 incomeOrExpenture:_incomeOrExpence Success:^(BOOL result) {
                [self.navigationController popViewControllerAnimated:YES];
                if (self.addNewCategoryAction) {
                    self.addNewCategoryAction(item.categoryID);
                }
            } failure:^(NSError *error) {
                [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
            }];
        }
    } else if (_titleSegmentView.selectedSegmentIndex == 1
               && _customCategorySwitchConrol.selectedIndex == 0) {
        // 添加自定义类别
        for (SSJRecordMakingCategoryItem *item in _customCategoryCollectionView.selectedItems) {
            [SSJCategoryListHelper updateCategoryWithID:item.categoryID state:1 incomeOrExpenture:_incomeOrExpence Success:^(BOOL result) {
                [self.navigationController popViewControllerAnimated:YES];
                if (self.addNewCategoryAction) {
                    self.addNewCategoryAction(item.categoryID);
                }
            } failure:^(NSError *error) {
                [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
            }];
        }
        
    } else if (_titleSegmentView.selectedSegmentIndex == 1
               && _customCategorySwitchConrol.selectedIndex == 1) {
        // 新建自定义类别
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
            [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
        }];
    }
}

- (void)editButtonAction {
    
}

- (void)deleteButtonAction {
    NSArray *selectedItems = nil;
    if (_titleSegmentView.selectedSegmentIndex == 0) {
        selectedItems = _featuredCategoryCollectionView.selectedItems;
    } else if (_titleSegmentView.selectedSegmentIndex == 0 && _customCategorySwitchConrol.selectedIndex == 0) {
        selectedItems = _customCategoryCollectionView.selectedItems;
    }
    
    NSArray *deleteIDs = [selectedItems valueForKeyPath:@"categoryID"];
    [SSJCategoryListHelper deleteCategoryWithIDs:deleteIDs success:^{
        
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL]];
    }];
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
                _newOrEditCategoryView.colorSelectionView.colors = _incomeOrExpence ? [SSJCategoryListHelper payOutColors] : [SSJCategoryListHelper incomeColors];
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
    
    [_sureButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor alpha:0.8] forState:UIControlStateNormal];
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"编辑（单选）" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]}];
    [title setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],
                           NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]} range:NSMakeRange(2, 4)];
    
    NSMutableAttributedString *disableTitle = [[NSMutableAttributedString alloc] initWithString:@"编辑（单选）" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    [disableTitle setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],
                                  NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]} range:NSMakeRange(2, 4)];
    
    [_editButton setAttributedTitle:title forState:UIControlStateNormal];
    [_editButton setAttributedTitle:disableTitle forState:UIControlStateDisabled];
    [_editButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainFillColor alpha:0.8] forState:UIControlStateNormal];
    
    [_deleteButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
    [_deleteButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainFillColor alpha:0.8] forState:UIControlStateNormal];
}

- (void)updateSubviews {
    if (_titleSegmentView.selectedSegmentIndex == 0) {
        if (_featuredCategoryCollectionView.editing) {
            _sureButton.hidden = YES;
            _editButton.hidden = NO;
            _deleteButton.hidden = NO;
            [self.navigationItem setRightBarButtonItem:self.doneItem animated:YES];
        } else {
            _sureButton.hidden = NO;
            _editButton.hidden = YES;
            _deleteButton.hidden = YES;
            [self.navigationItem setRightBarButtonItem:self.managerItem animated:YES];
        }
    } else {
        if (_customCategorySwitchConrol.selectedIndex == 0) {
            _customCategoryCollectionView.hidden = NO;
            _newOrEditCategoryView.hidden = YES;
            
            if (_customCategoryCollectionView.editing) {
                _sureButton.hidden = YES;
                _editButton.hidden = NO;
                _deleteButton.hidden = NO;
                [self.navigationItem setRightBarButtonItem:self.doneItem animated:YES];
            } else {
                _sureButton.hidden = NO;
                _editButton.hidden = YES;
                _deleteButton.hidden = YES;
                [self.navigationItem setRightBarButtonItem:self.managerItem animated:YES];
            }
        } else if (_customCategorySwitchConrol.selectedIndex == 1) {
            _customCategoryCollectionView.hidden = YES;
            _newOrEditCategoryView.hidden = NO;
            _sureButton.hidden = NO;
            _editButton.hidden = YES;
            _deleteButton.hidden = YES;
            [self.navigationItem setRightBarButtonItem:nil animated:YES];
        }
    }
}

- (void)updateEditButtonEnable {
    if (_titleSegmentView.selectedSegmentIndex == 0) {
        if (_featuredCategoryCollectionView.editing
            && _featuredCategoryCollectionView.selectedItems.count > 1) {
            self.editButton.enabled = NO;
        } else {
            self.editButton.enabled = YES;
        }
    } else if (_titleSegmentView.selectedSegmentIndex == 1
               && _customCategorySwitchConrol.selectedIndex == 0) {
        
        if (_customCategoryCollectionView.editing
            && _customCategoryCollectionView.selectedItems.count > 1) {
            self.editButton.enabled = NO;
        } else {
            self.editButton.enabled = YES;
        }
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
        __weak typeof(self) wself = self;
        _featuredCategoryCollectionView = [[SSJCategoryEditableCollectionView alloc] initWithFrame:CGRectMake(0, 10, self.scrollView.width, self.scrollView.height - 10)];
        _featuredCategoryCollectionView.editStateChangeHandle = ^(SSJCategoryEditableCollectionView *view) {
            [wself updateSubviews];
            [wself updateEditButtonEnable];
        };
        _featuredCategoryCollectionView.selectedItemsChangeHandle = ^(SSJCategoryEditableCollectionView *view) {
            [wself updateEditButtonEnable];
        };
    }
    return _featuredCategoryCollectionView;
}

- (SSJCategoryEditableCollectionView *)customCategoryCollectionView {
    if (!_customCategoryCollectionView) {
        __weak typeof(self) wself = self;
        _customCategoryCollectionView = [[SSJCategoryEditableCollectionView alloc] initWithFrame:CGRectMake(self.scrollView.width, self.customCategorySwitchConrol.bottom + 10, self.scrollView.width, self.scrollView.height - self.customCategorySwitchConrol.bottom - 10)];
        _customCategoryCollectionView.editStateChangeHandle = ^(SSJCategoryEditableCollectionView *view) {
            [wself updateSubviews];
            [wself updateEditButtonEnable];
        };
        _customCategoryCollectionView.selectedItemsChangeHandle = ^(SSJCategoryEditableCollectionView *view) {
            [wself updateEditButtonEnable];
        };
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

- (UIBarButtonItem *)managerItem {
    if (!_managerItem) {
        _managerItem = [[UIBarButtonItem alloc] initWithTitle:@"管理" style:UIBarButtonItemStylePlain target:self action:@selector(managerItemAction)];
    }
    return _managerItem;
}

- (UIBarButtonItem *)doneItem {
    if (!_doneItem) {
        _doneItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneItemAction)];
    }
    return _doneItem;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.frame = CGRectMake(0, self.view.height - 50, self.view.width, 50);
        _sureButton.titleLabel.font = [UIFont systemFontOfSize:20];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(sureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _editButton.frame = CGRectMake(0, self.view.height - 54, self.view.width * 0.6, 54);
        _editButton.titleLabel.font = [UIFont systemFontOfSize:20];
        [_editButton addTarget:self action:@selector(editButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(self.view.width * 0.6, self.view.height - 54, self.view.width * 0.4, 54);
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:20];
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

@end
