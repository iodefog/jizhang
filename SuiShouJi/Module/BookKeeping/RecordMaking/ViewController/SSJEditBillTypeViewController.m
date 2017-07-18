//
//  SSJEditBillTypeViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/8/31.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJEditBillTypeViewController.h"
#import "SSJRecordMakingViewController.h"
#import "SSJADDNewTypeViewController.h"
#import "SSJNewOrEditCustomCategoryView.h"
#import "SSJRecordMakingCategoryItem.h"
#import "SSJCategoryListHelper.h"
#import "SSJBillModel.h"
#import "SSJDataSynchronizer.h"

@interface SSJEditBillTypeViewController ()

@property (nonatomic, strong) SSJNewOrEditCustomCategoryView *categoryEditView;

@property (nonatomic, strong) UIButton *sureButton;

@end

@implementation SSJEditBillTypeViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"编辑类别";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.categoryEditView];
    [self.view addSubview:self.sureButton];
    [self updateAppearance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

#pragma mark - Private
- (void)loadData {
    // 查询自定义类别图标
    [self.view ssj_showLoadingIndicator];
//    [SSJCategoryListHelper queryCustomCategoryImagesWithIncomeOrExpenture:_model.type success:^(NSArray<NSString *> *images) {
//        [self.view ssj_hideLoadingIndicator];
//        _categoryEditView.images = images;
//        _categoryEditView.colors = _model.type ? [SSJCategoryListHelper payOutColors] : [SSJCategoryListHelper incomeColors];
//        _categoryEditView.textField.text = _model.name;
//        _categoryEditView.selectedImage = _model.icon;
//        _categoryEditView.selectedColor = _model.color;
//    } failure:^(NSError *error) {
//        [self.view ssj_hideLoadingIndicator];
//        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL]];
//    }];
}

- (void)updateAppearance {
    [_categoryEditView updateAppearance];
    if (SSJ_CURRENT_THEME.throughScreenButtonBackGroudColor.length) {
        [_sureButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.throughScreenButtonBackGroudColor alpha:SSJ_CURRENT_THEME.throughScreenButtonAlpha] forState:UIControlStateNormal];

    } else {
        
        [_sureButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor alpha:0.8] forState:UIControlStateNormal];

    }

    [_sureButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor alpha:0.8] forState:UIControlStateNormal];
}

#pragma mark - Event
- (void)sureButtonAction {
    if (_categoryEditView.textField.text.length == 0) {
        [CDAutoHideMessageHUD showMessage:@"请输入类别名称"];
        return;
    }
    
    if (_categoryEditView.textField.text.length > 5) {
        [CDAutoHideMessageHUD showMessage:@"类别名称不能超过5个字符"];
        return;
    }
    
    _model.name = _categoryEditView.textField.text;
    _model.color = _categoryEditView.selectedColor;
    _model.icon = _categoryEditView.selectedImage;
    
    [SSJCategoryListHelper queryAnotherCategoryWithSameName:_model.name 
                                        exceptForCategoryID:_model.ID
                                                    booksId:self.booksId
                                                    success:^(SSJBillModel *model) {
                                                        if (model) {
                                                            if (model.state) {
                                                                [self goBackToRecordMakingControllerWithModel:model];
                                                            } else {
                                                                [self.navigationController popViewControllerAnimated:YES];
                                                                if (_editSuccessHandle) {
                                                                    _editSuccessHandle(self, model);
                                                                }
                                                            }
                                                        } else {
                                                            [self updateCategory];
                                                        }
    }
                                                    failure:^(NSError *error) {
                                                        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了"
                                                                                            message:[error localizedDescription]
                                                                                             action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
                                                    }];
    
   
}

- (void)goBackToRecordMakingControllerWithModel:(SSJBillModel *)model {
    SSJRecordMakingViewController *controller = [self ssj_previousViewControllerBySubtractingIndex:2];
    if ([controller isKindOfClass:[SSJRecordMakingViewController class]]) {
        [self.navigationController popToViewController:controller animated:YES];
        if (_addNewCategoryAction) {
            _addNewCategoryAction(model.ID, model.type);
        }
    }
}

- (void)updateCategory {
    [SSJCategoryListHelper updateCategoryWithID:_model.ID
                                           name:_model.name
                                          color:_model.color
                                          image:_model.icon
                                          order:_model.order
                                        booksId:self.booksId
                                       billType:_model.type
                                        Success:^(NSString *categoryId) {
                                            [self.navigationController popViewControllerAnimated:YES];
                                            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
                                            if (_editSuccessHandle) {
                                                _editSuccessHandle(self, _model);
                                            }
                                        }
                                        failure:^(NSError *error) {
                                            [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了"
                                                                                message:[error localizedDescription]
                                                                                 action:[SSJAlertViewAction
                                                                                         actionWithTitle:@"确定" handler:NULL], nil];
                                        }];
}

#pragma mark - Getter
- (SSJNewOrEditCustomCategoryView *)categoryEditView {
    if (!_categoryEditView) {
        __weak typeof(self) wself = self;
        _categoryEditView = [[SSJNewOrEditCustomCategoryView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM + 10, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM - 10)];
        _categoryEditView.selectImageAction = ^(SSJNewOrEditCustomCategoryView *view) {
            if (wself.model.type) {
                [SSJAnaliyticsManager event:@"add_user_bill_in_custom"];
            }else{
                [SSJAnaliyticsManager event:@"add_user_bill_out_custom"];
            }
        };
        _categoryEditView.selectColorAction = ^(SSJNewOrEditCustomCategoryView *view) {
            [SSJAnaliyticsManager event:@"add_user_bill_color"];
        };
    }
    return _categoryEditView;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.frame = CGRectMake(0, self.view.height - 50, self.view.width, 50);
        _sureButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(sureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

@end
