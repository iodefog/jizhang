//
//  SSJADDNewTypeViewController.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJADDNewTypeViewController.h"
#import "SSJEditBillTypeViewController.h"
#import "SSJRecordMakingCategoryItem.h"
#import "SSJDatabaseQueue.h"
#import "SSJDataSynchronizer.h"
#import "FMDB.h"

#import "SSJSegmentedControl.h"
#import "SCYSlidePagingHeaderView.h"
#import "SSJCategoryEditableCollectionView.h"
#import "SSJNewOrEditCustomCategoryView.h"
#import "SSJBudgetNodataRemindView.h"
#import "SSJCategoryListHelper.h"
#import "SSJBillModel.h"

static const CGFloat kButtonHeight = 54;

static NSString *const kCellId = @"CategoryCollectionViewCellIdentifier";

@interface SSJADDNewTypeViewController () <UIScrollViewDelegate, SCYSlidePagingHeaderViewDelegate>

@property (nonatomic, strong) SSJSegmentedControl *titleSegmentView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) SCYSlidePagingHeaderView *customCategorySwitchConrol;

@property (nonatomic, strong) SSJCategoryEditableCollectionView *featuredCategoryCollectionView;

@property (nonatomic, strong) SSJCategoryEditableCollectionView *customCategoryCollectionView;

@property (nonatomic, strong) SSJNewOrEditCustomCategoryView *newOrEditCategoryView;

@property (nonatomic, strong) UIBarButtonItem *managerItem;

@property (nonatomic, strong) UIBarButtonItem *doneItem;

@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) UIButton *featureDeleteButton;

@property (nonatomic, strong) UIButton *editButton;

@property (nonatomic, strong) UIButton *customDeleteButton;

@property (nonatomic, strong) SSJBudgetNodataRemindView *noFeaturedCategoryRemindView;

@property (nonatomic, strong) SSJBudgetNodataRemindView *noCustomCategoryRemindView;

@property (nonatomic, copy) NSString *selectedID;

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
    
    [self ssj_showBackButtonWithTarget:self selector:@selector(goBackAction)];
    
    self.navigationItem.titleView = self.titleSegmentView;
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.sureButton];
    [self.view addSubview:self.editButton];
    [self.view addSubview:self.featureDeleteButton];
    [self.view addSubview:self.customDeleteButton];
    [self.scrollView addSubview:self.featuredCategoryCollectionView];
    [self.scrollView addSubview:self.customCategorySwitchConrol];
    [self.scrollView addSubview:self.customCategoryCollectionView];
    [self.scrollView addSubview:self.newOrEditCategoryView];
    [self updateButtons];
    [self updateAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.customCategorySwitchConrol setSelectedIndex:1 animated:NO];
    [self loadData];
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
//            [SSJAnaliyticsManager event:@"add_user_bill_in"];
//        }else{
//            [SSJAnaliyticsManager event:@"add_user_bill_out"];
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
        [self updateButtons];
        [self showOrHideKeyboard];
        [self updateEditButtonEnable];
    }
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    [self loadData];
    [self updateButtons];
    [self showOrHideKeyboard];
    [self updateEditButtonEnable];
}

#pragma mark - Event
- (void)titleSegmentViewAciton {
    [self loadData];
    [self updateButtons];
    [self showOrHideKeyboard];
    [self updateEditButtonEnable];
    [_scrollView setContentOffset:CGPointMake(_scrollView.width * _titleSegmentView.selectedSegmentIndex, 0) animated:YES];
}

- (void)managerItemAction {
    if (_titleSegmentView.selectedSegmentIndex == 0) {
        _featuredCategoryCollectionView.editing = YES;
        [SSJAnaliyticsManager event:@"build_in_type_manage"];
    } else if (_titleSegmentView.selectedSegmentIndex == 1) {
        _customCategoryCollectionView.editing = YES;
        [SSJAnaliyticsManager event:@"custom_type_manage"];
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
        
        // 开启系统默认类别
        SSJRecordMakingCategoryItem *item = [_featuredCategoryCollectionView.selectedItems firstObject];
        [self openCategoryWithID:item.categoryID
                            name:item.categoryTitle
                           color:item.categoryColor
                           image:item.categoryImage
                            type:_incomeOrExpence];
        
    } else if (_titleSegmentView.selectedSegmentIndex == 1
               && _customCategorySwitchConrol.selectedIndex == 0) {
        
        // 开启自定义类别
        SSJRecordMakingCategoryItem *item = [_customCategoryCollectionView.selectedItems firstObject];
        [self openCategoryWithID:item.categoryID
                            name:item.categoryTitle
                           color:item.categoryColor
                           image:item.categoryImage
                            type:_incomeOrExpence];
        
    } else if (_titleSegmentView.selectedSegmentIndex == 1
               && _customCategorySwitchConrol.selectedIndex == 1) {
        
        // 新建自定义类别
        NSString *name = _newOrEditCategoryView.textField.text;
        NSString *color = _newOrEditCategoryView.selectedColor;
        NSString *image = _newOrEditCategoryView.selectedImage;
        
        if (name.length == 0) {
            [CDAutoHideMessageHUD showMessage:@"请输入类别名称"];
            return;
        }
        
        if (name.length > 5) {
            [CDAutoHideMessageHUD showMessage:@"类别名称不能超过5个字符"];
            return;
        }
        
        [SSJCategoryListHelper querySameNameCategoryWithName:name
                                             exceptForBillID:nil
                                                     booksId:self.booksId
                                                    expended:self.incomeOrExpence
                                                     success:^(SSJBillModel *model) {
            if (model) {
                if (model.operatorType == 2) {
                    if (model.custom) {
                        [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"您已创建过同名称的自定义类别了，是否要合并将同名的类别一起统计？" action:[SSJAlertViewAction actionWithTitle:@"分为两类别" handler:^(SSJAlertViewAction *action) {
                            [self addNewCategoryWithName:name image:image color:color];
                        }], [SSJAlertViewAction actionWithTitle:@"确定合并" handler:^(SSJAlertViewAction *action) {
                            [self openCategoryWithID:model.ID
                                                name:model.name
                                               color:color
                                               image:image
                                                type:model.type];
                        }], nil];
                    } else {
                        [SSJAlertViewAdapter showAlertViewWithTitle:nil message:@"系统已有过同名的类别，是否要将该名称以两类进行分别统计？" action:[SSJAlertViewAction actionWithTitle:@"分为两类别" handler:^(SSJAlertViewAction *action) {
                            [self addNewCategoryWithName:name image:image color:color];
                        }], [SSJAlertViewAction actionWithTitle:@"恢复系统类别" handler:^(SSJAlertViewAction *action) {
                            [self openCategoryWithID:model.ID
                                                name:model.name
                                               color:model.color
                                               image:model.icon
                                                type:model.type];
                        }], nil];
                    }
                } else {
                    [CDAutoHideMessageHUD showMessage:@"已有同名称类别，不支持新建哦"];
                    if (model.custom) {
                        [self openCategoryWithID:model.ID
                                            name:model.name
                                           color:color
                                           image:image
                                            type:model.type];
                    } else {
                        [self openCategoryWithID:model.ID
                                            name:model.name
                                           color:model.color
                                           image:model.icon
                                            type:model.type];
                    }
                }
            } else {
                [self addNewCategoryWithName:name image:image color:color];
            }
        } failure:^(NSError *error) {
            [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
        }];
    }
}

- (void)editButtonAction {
    NSArray *selectedItems = nil;
    if (_titleSegmentView.selectedSegmentIndex == 0) {
        selectedItems = _featuredCategoryCollectionView.selectedItems;
    } else if (_titleSegmentView.selectedSegmentIndex == 1
               && _customCategorySwitchConrol.selectedIndex == 0) {
        selectedItems = _customCategoryCollectionView.selectedItems;
        [SSJAnaliyticsManager event:@"custom_type_edit"];
    }
    
    if (selectedItems.count == 0) {
        [CDAutoHideMessageHUD showMessage:@"请选择要编辑的类别"];
        return;
    }
    
    if (selectedItems.count > 1) {
        [CDAutoHideMessageHUD showMessage:@"只能选择一个类别进行编辑"];
        return;
    }
    
    SSJRecordMakingCategoryItem *selectedItem = [selectedItems firstObject];
    
    SSJBillModel *editModel = [[SSJBillModel alloc] init];
    editModel.ID = selectedItem.categoryID;
    editModel.name = selectedItem.categoryTitle;
    editModel.icon = selectedItem.categoryImage;
    editModel.color = selectedItem.categoryColor;
    editModel.order = selectedItem.order;
    editModel.state = 0;
    editModel.custom = 1;
    editModel.type = _incomeOrExpence;
    
    __weak typeof(self) wself = self;
    
    SSJEditBillTypeViewController *editVC = [[SSJEditBillTypeViewController alloc] init];
    editVC.booksId = self.booksId;
    editVC.model = editModel;
    editVC.addNewCategoryAction = _addNewCategoryAction;
    editVC.editSuccessHandle = ^(SSJEditBillTypeViewController *controller, SSJBillModel *model) {
        if ([model.ID isEqualToString:editModel.ID]) {
            selectedItem.categoryTitle = model.name;
            selectedItem.categoryImage = model.icon;
            selectedItem.categoryColor = model.color;
        } else {
            wself.titleSegmentView.selectedSegmentIndex = model.custom;
            [wself.scrollView setContentOffset:CGPointMake(wself.scrollView.width * wself.titleSegmentView.selectedSegmentIndex, 0) animated:NO];
            
            wself.selectedID = model.ID;
            wself.incomeOrExpence = model.type;
            
            wself.featuredCategoryCollectionView.items = nil;
            wself.customCategoryCollectionView.items = nil;
            wself.newOrEditCategoryView.textField.text = nil;
            wself.newOrEditCategoryView.images = nil;
            wself.newOrEditCategoryView.colors = nil;
            [wself loadData];
        }
    };
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)featureDeleteButtonAction {
    if (_featuredCategoryCollectionView.selectedItems.count == 0) {
        [CDAutoHideMessageHUD showMessage:@"请选择要删除的类别"];
        return;
    }
    
    NSArray *deleteIDs = [_featuredCategoryCollectionView.selectedItems valueForKeyPath:@"categoryID"];
    [SSJCategoryListHelper deleteCategoryWithIDs:deleteIDs
                                         booksId:self.booksId
                                         success:^{
        [_featuredCategoryCollectionView deleteItems:_featuredCategoryCollectionView.selectedItems];
        if (_featuredCategoryCollectionView.items.count == 0) {
            [_featuredCategoryCollectionView ssj_showWatermarkWithCustomView:_noFeaturedCategoryRemindView animated:YES target:nil action:nil];
        } else {
            [_featuredCategoryCollectionView ssj_hideWatermark:YES];
        }
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL]];
    }];
    
    [SSJAnaliyticsManager event:@"build_in_type_deletec"];
}

- (void)customDeleteButtonAction {
    if (_customCategoryCollectionView.selectedItems.count == 0) {
        [CDAutoHideMessageHUD showMessage:@"请选择要删除的类别"];
        return;
    }
    
    NSArray *deleteIDs = [_customCategoryCollectionView.selectedItems valueForKeyPath:@"categoryID"];
    [SSJCategoryListHelper deleteCategoryWithIDs:deleteIDs
                                         booksId:self.booksId
                                         success:^{
        [_customCategoryCollectionView deleteItems:_customCategoryCollectionView.selectedItems];
        if (_customCategoryCollectionView.items.count == 0) {
            [_customCategoryCollectionView ssj_showWatermarkWithCustomView:_noCustomCategoryRemindView animated:YES target:nil action:nil];
        } else {
            [_customCategoryCollectionView ssj_hideWatermark:YES];
        }
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL]];
    }];
    
    [SSJAnaliyticsManager event:@"custom_type_delete"];
}

#pragma mark - private
- (void)loadData {
//    if (_titleSegmentView.selectedSegmentIndex == 0
//        && _featuredCategoryCollectionView.items.count == 0) {
//        
//        [self.view ssj_showLoadingIndicator];
//        [SSJCategoryListHelper queryForUnusedCategoryListWithIncomeOrExpenture:_incomeOrExpence
//                                                                        custom:0
//                                                                       booksId:self.booksId
//                                                                       success:^(NSMutableArray<SSJRecordMakingCategoryItem *> *result) {
//            _featuredCategoryCollectionView.items = result;
//            [self updateButtons];
//            [self updateSelectedIndexForCollectionView:_featuredCategoryCollectionView];
//            [self.view ssj_hideLoadingIndicator];
//            
//            if (_featuredCategoryCollectionView.items.count == 0) {
//                [_featuredCategoryCollectionView ssj_showWatermarkWithCustomView:self.noFeaturedCategoryRemindView animated:YES target:nil action:nil];
//            } else {
//                [_featuredCategoryCollectionView ssj_hideWatermark:YES];
//            }
//        } failure:^(NSError *error) {
//            [self.view ssj_hideLoadingIndicator];
//            [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL]];
//        }];
//        
//    } else if (_titleSegmentView.selectedSegmentIndex == 1) {
//        
//        if (self.customCategorySwitchConrol.selectedIndex == 0
//            && _customCategoryCollectionView.items.count == 0) {
//            
//            [self.view ssj_showLoadingIndicator];
//            [SSJCategoryListHelper queryForUnusedCategoryListWithIncomeOrExpenture:_incomeOrExpence
//                                                                            custom:1
//                                                                           booksId:self.booksId
//                                                                           success:^(NSMutableArray<SSJRecordMakingCategoryItem *> *result) {
//                _customCategoryCollectionView.items = result;
//                [self updateButtons];
//                [self updateSelectedIndexForCollectionView:_customCategoryCollectionView];
//                [self.view ssj_hideLoadingIndicator];
//                
//                if (_customCategoryCollectionView.items.count == 0) {
//                    [_customCategoryCollectionView ssj_showWatermarkWithCustomView:self.noCustomCategoryRemindView animated:YES target:nil action:nil];
//                } else {
//                    [_customCategoryCollectionView ssj_hideWatermark:YES];
//                }
//                
//            } failure:^(NSError *error) {
//                [self.view ssj_hideLoadingIndicator];
//                [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL]];
//            }];
//            
//        } else if (self.customCategorySwitchConrol.selectedIndex == 1
//                   && _newOrEditCategoryView.images.count == 0) {
//            // 查询自定义类别图标
//            [self.view ssj_showLoadingIndicator];
//            [SSJCategoryListHelper queryCustomCategoryImagesWithIncomeOrExpenture:_incomeOrExpence success:^(NSArray<NSString *> *images) {
//                [self.view ssj_hideLoadingIndicator];
//                [self updateButtons];
//                _newOrEditCategoryView.images = images;
//                _newOrEditCategoryView.colors = _incomeOrExpence ? [SSJCategoryListHelper payOutColors] : [SSJCategoryListHelper incomeColors];
//            } failure:^(NSError *error) {
//                [self.view ssj_hideLoadingIndicator];
//                [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL]];
//            }];
//        }
//    }
}

- (void)updateSelectedIndexForCollectionView:(SSJCategoryEditableCollectionView *)view {
    for (int i = 0; i < view.items.count; i ++) {
        SSJRecordMakingCategoryItem *item = view.items[i];
        if ([item.categoryID isEqualToString:_selectedID]) {
            view.selectedIndexs = @[@(i)];
            break;
        }
    }
}

- (void)updateAppearance {
    _titleSegmentView.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _titleSegmentView.selectedBorderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    [_titleSegmentView setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]} forState:UIControlStateNormal];
    [_titleSegmentView setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]} forState:UIControlStateSelected];
    
    _customCategorySwitchConrol.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    [_customCategorySwitchConrol ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    _customCategorySwitchConrol.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _customCategorySwitchConrol.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    
    _featuredCategoryCollectionView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    
    [_featureDeleteButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor]];

    [_customDeleteButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor]];

    [_sureButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor]];

    [_editButton ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.borderColor]];
    
    if (SSJ_CURRENT_THEME.throughScreenButtonBackGroudColor.length) {
        [_featureDeleteButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.throughScreenButtonBackGroudColor alpha:SSJ_CURRENT_THEME.throughScreenButtonAlpha] forState:UIControlStateNormal];
        
        
        [_customDeleteButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.throughScreenButtonBackGroudColor alpha:SSJ_CURRENT_THEME.throughScreenButtonAlpha] forState:UIControlStateNormal];
        
        [_sureButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.throughScreenButtonBackGroudColor alpha:SSJ_CURRENT_THEME.throughScreenButtonAlpha] forState:UIControlStateNormal];
        
        [_editButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.throughScreenButtonBackGroudColor alpha:SSJ_CURRENT_THEME.throughScreenButtonAlpha] forState:UIControlStateNormal];
        
    } else {
        [_featureDeleteButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor alpha:0.8] forState:UIControlStateNormal];
        
        [_customDeleteButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor alpha:0.8] forState:UIControlStateNormal];
        
        [_sureButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor alpha:0.8] forState:UIControlStateNormal];

        [_editButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor alpha:0.8] forState:UIControlStateNormal];

    }
    
    if ([SSJCurrentThemeID() isEqualToString:SSJDefaultThemeID]) {
        [_featureDeleteButton setTitleColor:[UIColor ssj_colorWithHex:@"#eb4a64"] forState:UIControlStateNormal];
        
        [_customDeleteButton setTitleColor:[UIColor ssj_colorWithHex:@"#eb4a64"] forState:UIControlStateNormal];
        
        
    } else {
        [_featureDeleteButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor] forState:UIControlStateNormal];
        
        [_customDeleteButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor] forState:UIControlStateNormal];
        
    }
    
    [self updateEditButtonTitleColor];
}

- (void)updateButtons {
    if (_titleSegmentView.selectedSegmentIndex == 0) {
        if (_featuredCategoryCollectionView.items.count == 0) {
            _sureButton.hidden = YES;
            _editButton.hidden = YES;
            _customDeleteButton.hidden = YES;
            _featureDeleteButton.hidden = YES;
            [self.navigationItem setRightBarButtonItem:nil animated:YES];
        } else {
            if (_featuredCategoryCollectionView.editing) {
                _sureButton.hidden = YES;
                _editButton.hidden = YES;
                _customDeleteButton.hidden = YES;
                _featureDeleteButton.hidden = NO;
                [self.navigationItem setRightBarButtonItem:self.doneItem animated:YES];
            } else {
                _sureButton.hidden = NO;
                _editButton.hidden = YES;
                _customDeleteButton.hidden = YES;
                _featureDeleteButton.hidden = YES;
                [self.navigationItem setRightBarButtonItem:self.managerItem animated:YES];
            }
        }
    } else {
        if (_customCategorySwitchConrol.selectedIndex == 0) {
            _customCategoryCollectionView.hidden = NO;
            _newOrEditCategoryView.hidden = YES;
            
            if (_customCategoryCollectionView.items.count == 0) {
                _sureButton.hidden = YES;
                _editButton.hidden = YES;
                _customDeleteButton.hidden = YES;
                _featureDeleteButton.hidden = YES;
                [self.navigationItem setRightBarButtonItem:nil animated:YES];
            } else {
                if (_customCategoryCollectionView.editing) {
                    _sureButton.hidden = YES;
                    _editButton.hidden = NO;
                    _customDeleteButton.hidden = NO;
                    _featureDeleteButton.hidden = YES;
                    [self.navigationItem setRightBarButtonItem:self.doneItem animated:YES];
                } else {
                    _sureButton.hidden = NO;
                    _editButton.hidden = YES;
                    _customDeleteButton.hidden = YES;
                    _featureDeleteButton.hidden = YES;
                    [self.navigationItem setRightBarButtonItem:self.managerItem animated:YES];
                }
            }
        } else if (_customCategorySwitchConrol.selectedIndex == 1) {
            _customCategoryCollectionView.hidden = YES;
            _newOrEditCategoryView.hidden = NO;
            _sureButton.hidden = NO;
            _editButton.hidden = YES;
            _customDeleteButton.hidden = YES;
            _featureDeleteButton.hidden = YES;
            [self.navigationItem setRightBarButtonItem:nil animated:YES];
        }
    }
}

- (void)updateEditButtonEnable {
    if (_titleSegmentView.selectedSegmentIndex == 1
        && _customCategorySwitchConrol.selectedIndex == 0
        && _customCategoryCollectionView.editing) {
        [self updateEditButtonTitleColor];
        return;
    }
}

- (void)updateEditButtonTitleColor {
    NSString *titleColor = _customCategoryCollectionView.selectedItems.count == 1 ? SSJ_CURRENT_THEME.mainColor : SSJ_CURRENT_THEME.secondaryColor;
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"编辑（单选）" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:titleColor]}];
    [title setAttributes:@{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3],
                           NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:titleColor]} range:NSMakeRange(2, 4)];
    [_editButton setAttributedTitle:title forState:UIControlStateNormal];
}

- (void)showOrHideKeyboard {
    if (_titleSegmentView.selectedSegmentIndex == 1 && _customCategorySwitchConrol.selectedIndex == 1) {
        [_newOrEditCategoryView.textField becomeFirstResponder];
    } else {
        [_newOrEditCategoryView.textField resignFirstResponder];
    }
} 

- (void)openCategoryWithID:(NSString *)ID name:(NSString *)name color:(NSString *)color image:(NSString *)image type:(int)type {
    int order = [SSJCategoryListHelper queryForBillTypeMaxOrderWithType:type
                                                                 booksId:self.booksId] + 1;
    [SSJCategoryListHelper updateCategoryWithID:ID
                                           name:name
                                          color:color
                                          image:image
                                          order:order
                                        booksId:self.booksId
                                        success:^(NSString *categoryId) {
                                            
        [self.navigationController popViewControllerAnimated:YES];
        if (self.addNewCategoryAction) {
            self.addNewCategoryAction(categoryId, type);
        }
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
                                            
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}

- (void)addNewCategoryWithName:(NSString *)name image:(NSString *)image color:(NSString *)color {
    [SSJCategoryListHelper addNewCustomCategoryWithIncomeOrExpenture:_incomeOrExpence
                                                                name:name
                                                                icon:image color:color
                                                             booksId:self.booksId success:^(NSString *categoryId){
        [self.navigationController popViewControllerAnimated:YES];
        if (self.addNewCategoryAction) {
            self.addNewCategoryAction(categoryId, _incomeOrExpence);
        }
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError *error) {
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}

#pragma mark - Getter
- (SSJSegmentedControl *)titleSegmentView {
    if (!_titleSegmentView) {
        _titleSegmentView = [[SSJSegmentedControl alloc] initWithItems:@[@"精选类别",@"自定义类别"]];
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
        _customCategorySwitchConrol.titles = @[@"已建未启用", @"新建类别"];
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
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (SSJCategoryEditableCollectionView *)featuredCategoryCollectionView {
    if (!_featuredCategoryCollectionView) {
        __weak typeof(self) wself = self;
        _featuredCategoryCollectionView = [[SSJCategoryEditableCollectionView alloc] initWithFrame:CGRectMake(0, 10, self.scrollView.width, self.scrollView.height - 10)];
        _featuredCategoryCollectionView.contentInset = UIEdgeInsetsMake(10, 14, kButtonHeight, 14);
        _featuredCategoryCollectionView.itemSize = CGSizeMake((_featuredCategoryCollectionView.width - 28) / 5, 75);
        _featuredCategoryCollectionView.editStateChangeHandle = ^(SSJCategoryEditableCollectionView *view) {
            [wself updateButtons];
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
        _customCategoryCollectionView.contentInset = UIEdgeInsetsMake(10, 14, kButtonHeight, 14);
        _customCategoryCollectionView.itemSize = CGSizeMake((_featuredCategoryCollectionView.width - 28) / 5, 75);
        _customCategoryCollectionView.editStateChangeHandle = ^(SSJCategoryEditableCollectionView *view) {
            [wself updateButtons];
//            [wself updateEditButtonEnable];
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
        _newOrEditCategoryView.selectImageAction = ^(SSJNewOrEditCustomCategoryView *view) {
            if (wself.incomeOrExpence) {
                [SSJAnaliyticsManager event:@"add_user_bill_in_custom"];
            }else{
                [SSJAnaliyticsManager event:@"add_user_bill_out_custom"];
            }
        };
        _newOrEditCategoryView.selectColorAction = ^(SSJNewOrEditCustomCategoryView *view) {
            [SSJAnaliyticsManager event:@"add_user_bill_color"];
        };
        _newOrEditCategoryView.hidden = YES;
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
        _sureButton.frame = CGRectMake(0, self.view.height - kButtonHeight, self.view.width, kButtonHeight);
        _sureButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton ssj_setBorderStyle:SSJBorderStyleTop];
        [_sureButton setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor] forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(sureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

- (UIButton *)editButton {
    if (!_editButton) {
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _editButton.frame = CGRectMake(0, self.view.height - kButtonHeight, self.view.width * 0.6, kButtonHeight);
        [_editButton ssj_setBorderStyle:SSJBorderStyleTop | SSJBorderStyleRight];
        _editButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
        [_editButton addTarget:self action:@selector(editButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editButton;
}

- (UIButton *)featureDeleteButton {
    if (!_featureDeleteButton) {
        _featureDeleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _featureDeleteButton.frame = CGRectMake(0, self.view.height - kButtonHeight, self.view.width, kButtonHeight);
        _featureDeleteButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
        [_featureDeleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [_featureDeleteButton ssj_setBorderStyle:SSJBorderStyleTop];
        [_featureDeleteButton addTarget:self action:@selector(featureDeleteButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _featureDeleteButton;
}

- (UIButton *)customDeleteButton {
    if (!_customDeleteButton) {
        _customDeleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _customDeleteButton.frame = CGRectMake(self.view.width * 0.6, self.view.height - kButtonHeight, self.view.width * 0.4, kButtonHeight);
        _customDeleteButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
        [_customDeleteButton ssj_setBorderStyle:SSJBorderStyleTop];
        [_customDeleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [_customDeleteButton addTarget:self action:@selector(customDeleteButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _customDeleteButton;
}

- (SSJBudgetNodataRemindView *)noFeaturedCategoryRemindView {
    if (!_noFeaturedCategoryRemindView) {
        _noFeaturedCategoryRemindView = [[SSJBudgetNodataRemindView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 260)];
        _noFeaturedCategoryRemindView.image = @"budget_no_data";
        _noFeaturedCategoryRemindView.title = @"暂无未启用的精选类别哦";
    }
    return _noFeaturedCategoryRemindView;
}

- (SSJBudgetNodataRemindView *)noCustomCategoryRemindView {
    if (!_noCustomCategoryRemindView) {
        _noCustomCategoryRemindView = [[SSJBudgetNodataRemindView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 260)];
        _noCustomCategoryRemindView.image = @"budget_no_data";
        _noCustomCategoryRemindView.title = @"暂无未启用的自定义类别哦";
    }
    return _noCustomCategoryRemindView;
}

@end
