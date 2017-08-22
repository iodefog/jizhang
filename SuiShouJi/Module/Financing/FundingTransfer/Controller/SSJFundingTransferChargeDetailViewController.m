//
//  SSJFundingTransferChargeDetailViewController.m
//  SuiShouJi
//
//  Created by old lang on 17/2/12.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFundingTransferChargeDetailViewController.h"
#import "SSJFundingTypeSelectViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "SSJChargeCircleModifyCell.h"
#import "SSJFundingTypeSelectView.h"
#import "SSJHomeDatePickerView.h"
#import "SSJFundingTransferDetailItem.h"
#import "SSJCreditCardItem.h"
#import "SSJFinancingHomeitem.h"
#import "SSJFundingTransferStore.h"
#import "SSJDataSynchronizer.h"
#import "SSJTextFieldToolbarManager.h"

static NSString *const kMoneyImage = @"loan_money";
static NSString *const kTransOutAcctImage = @"founds_zhuanchuzhanghu";
static NSString *const kTransInAcctImage = @"founds_zhuanruzhanghu";
static NSString *const kMemoImage = @"loan_memo";
static NSString *const kTransDateImage = @"loan_calendar";

static NSString *const kMoney = @"转账金额";
static NSString *const kTransOutAcctName = @"转出账户";
static NSString *const kTransInAcctName = @"转入账户";
static NSString *const kMemo = @"备注";
static NSString *const kTransDate = @"转账日期";

static NSString *const kCellId = @"SSJChargeCircleModifyCell";

static const NSInteger kMoneyTag = 1001;
static const NSInteger kMemoTag = 1002;

@interface __SSJFundingTransferChargeDetailModel : NSObject

@property (nonatomic, strong) NSString *image;

@property (nonatomic, strong) NSString *title;

+ (instancetype)modelWithImage:(NSString *)image title:(NSString *)title;

@end

@implementation __SSJFundingTransferChargeDetailModel

+ (instancetype)modelWithImage:(NSString *)image title:(NSString *)title {
    __SSJFundingTransferChargeDetailModel *model = [[__SSJFundingTransferChargeDetailModel alloc] init];
    model.image = image;
    model.title = title;
    return model;
}

@end

@interface SSJFundingTransferChargeDetailViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) NSArray <NSArray <__SSJFundingTransferChargeDetailModel *>*>*models;

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property (nonatomic, strong) UIButton *saveButton;

@property (nonatomic, strong) SSJFundingTypeSelectView *transferInFundingTypeSelect;

@property (nonatomic, strong) SSJFundingTypeSelectView *transferOutFundingTypeSelect;

@property (nonatomic, strong) SSJHomeDatePickerView *dateSelectionView;

@end

@implementation SSJFundingTransferChargeDetailViewController

#pragma mark - Lifecycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"转账详情";
        self.hidesBottomBarWhenPushed = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transferTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
        [self initModels];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteAction)];
    [self.view addSubview:self.tableView];
    [self updateAppearance];
    
    if (!_item && _chargeItem) {
        self.tableView.hidden = YES;
        [self.view ssj_showLoadingIndicator];
        [SSJFundingTransferStore queryFundingTransferDetailItemWithBillingChargeCellItem:_chargeItem success:^(SSJFundingTransferDetailItem * _Nonnull item) {
            _item = item;
            self.tableView.hidden = NO;
            [self.tableView reloadData];
            [self.view ssj_hideLoadingIndicator];
        } failure:^(NSError * _Nonnull error) {
            self.tableView.hidden = NO;
            [self.view ssj_hideLoadingIndicator];
        }];
    }
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _models.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_models[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __SSJFundingTransferChargeDetailModel *model = [_models ssj_objectAtIndexPath:indexPath];
    SSJChargeCircleModifyCell *circleModifyCell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    circleModifyCell.cellTitle = model.title;
    circleModifyCell.cellImageName = model.image;
    
    if ([model.title isEqualToString:kMoney]) {
        
        if (_item.transferMoney.length) {
            circleModifyCell.cellInput.text = [NSString stringWithFormat:@"%.2f",[_item.transferMoney doubleValue]];
        }
        circleModifyCell.cellInput.hidden = NO;
        circleModifyCell.cellInput.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        circleModifyCell.cellInput.keyboardType = UIKeyboardTypeDecimalPad;
        circleModifyCell.cellInput.delegate = self;
        circleModifyCell.cellInput.tag = kMoneyTag;
        circleModifyCell.cellInput.clearButtonMode = UITextFieldViewModeNever;
        [circleModifyCell.cellInput ssj_installToolbar];
        
    } else if ([model.title isEqualToString:kTransOutAcctName]) {
        
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        circleModifyCell.cellInput.hidden = YES;
        if (!_item.transferOutId) {
            circleModifyCell.cellDetail = @"请选择转出账户";
        } else {
            circleModifyCell.cellDetail = _item.transferOutName;
            circleModifyCell.cellTypeImageName = _item.transferOutImage;
        }
        
    } else if ([model.title isEqualToString:kTransInAcctName]) {
        
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        circleModifyCell.cellInput.hidden = YES;
        if (!_item.transferInId) {
            circleModifyCell.cellDetail = @"请选择转入账户";
        } else {
            circleModifyCell.cellDetail = _item.transferInName;
            circleModifyCell.cellTypeImageName = _item.transferInImage;
        }
        
    } else if ([model.title isEqualToString:kMemo]) {
        
        circleModifyCell.cellInput.hidden = NO;
        circleModifyCell.cellInput.returnKeyType = UIReturnKeyDone;
        circleModifyCell.cellInput.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"备注说明" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        circleModifyCell.cellInput.text = self.item.transferMemo;
        circleModifyCell.cellInput.tag = kMemoTag;
        circleModifyCell.cellInput.delegate = self;
        circleModifyCell.cellInput.returnKeyType = UIReturnKeyDone;
        circleModifyCell.cellInput.clearButtonMode = UITextFieldViewModeWhileEditing;
        
    } else if ([model.title isEqualToString:kTransDate]) {
        circleModifyCell.cellInput.hidden = YES;
        circleModifyCell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        circleModifyCell.cellDetail = self.item.transferDate;
    }
    
    return circleModifyCell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    __SSJFundingTransferChargeDetailModel *model = [_models ssj_objectAtIndexPath:indexPath];
    if ([model.title isEqualToString:kTransOutAcctName]) {
        self.transferOutFundingTypeSelect.selectFundID = _item.transferOutId;
        [self.transferOutFundingTypeSelect show];
    } else if ([model.title isEqualToString:kTransInAcctName]) {
        self.transferInFundingTypeSelect.selectFundID = _item.transferInId;
        [self.transferInFundingTypeSelect show];
    } else if ([model.title isEqualToString:kTransDate]) {
        self.dateSelectionView.date = [NSDate dateWithString:self.item.transferDate formatString:@"yyyy-MM-dd"];
        [self.dateSelectionView show];
    }
}

#pragma mark - UITextFieldDelegate
//- (void)textFieldDidEndEditing:(UITextField *)textField {
//    if (textField.tag == kMoneyTag) {
//        self.item.transferMoney = textField.text;
//    } else if (textField.tag == kMemoTag) {
//        self.item.transferMemo = textField.text;
//    }
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Private
- (void)initModels {
    __SSJFundingTransferChargeDetailModel *moneyModel = [__SSJFundingTransferChargeDetailModel modelWithImage:kMoneyImage title:kMoney];
    __SSJFundingTransferChargeDetailModel *transOutModel = [__SSJFundingTransferChargeDetailModel modelWithImage:kTransOutAcctImage title:kTransOutAcctName];
    __SSJFundingTransferChargeDetailModel *transInModel = [__SSJFundingTransferChargeDetailModel modelWithImage:kTransInAcctImage title:kTransInAcctName];
    __SSJFundingTransferChargeDetailModel *memoModel = [__SSJFundingTransferChargeDetailModel modelWithImage:kMemoImage title:kMemo];
    __SSJFundingTransferChargeDetailModel *dateModel = [__SSJFundingTransferChargeDetailModel modelWithImage:kTransDateImage title:kTransDate];
    _models = @[@[moneyModel, transOutModel, transInModel], @[memoModel, dateModel]];
}

- (void)transferTextDidChange:(NSNotification *)notification {
    UITextField *textField = notification.object;
    if (textField.tag == kMoneyTag) {
        textField.text = [textField.text ssj_reserveDecimalDigits:2 intDigits:9];
        _item.transferMoney = textField.text;
    } else if (textField.tag == kMemoTag) {
        _item.transferMemo = textField.text;
    }
}

- (void)updateAppearance {
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    [_saveButton ssj_setBackgroundColor:SSJ_BUTTON_NORMAL_COLOR forState:UIControlStateNormal];
    [_saveButton ssj_setBackgroundColor:[SSJ_BUTTON_DISABLE_COLOR colorWithAlphaComponent:SSJButtonDisableAlpha] forState:UIControlStateDisabled];
}

- (BOOL)checkModelValid {
    if ([_item.transferMoney floatValue] <= 0) {
        [CDAutoHideMessageHUD showMessage:@"请输入有效金额"];
        return NO;
    }
    
    if (!_item.transferOutId) {
        [CDAutoHideMessageHUD showMessage:@"请选择转出账户"];
        return NO;
    }
    
    if (!_item.transferInId) {
        [CDAutoHideMessageHUD showMessage:@"请选择转入账户"];
        return NO;
    }
    
    if ([_item.transferOutId isEqualToString:_item.transferInId]) {
        [CDAutoHideMessageHUD showMessage:@"请选择不同账户"];
        return NO;
    }
    
    if (_item.transferMemo.length > 15) {
        [CDAutoHideMessageHUD showMessage:@"备注不能超过15个字哦"];
        return NO;
    }
    
    return YES;
}

#pragma mark - Event
- (void)saveButtonClicked {
    if (![self checkModelValid]) {
        return;
    }
    
    _saveButton.enabled = NO;
    [_saveButton ssj_showLoadingIndicator];
    [SSJFundingTransferStore saveTransferChargeWithTransInChargeId:_item.transferInChargeId transOutChargeId:_item.transferOutChargeId transInAcctId:_item.transferInId transOutAcctId:_item.transferOutId money:[_item.transferMoney doubleValue] memo:_item.transferMemo billDate:_item.transferDate success:^{
        _saveButton.enabled = YES;
        [_saveButton ssj_hideLoadingIndicator];
        [self.navigationController popViewControllerAnimated:YES];
        [CDAutoHideMessageHUD showMessage:@"保存成功"];
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError * _Nonnull error) {
        _saveButton.enabled = YES;
        [_saveButton ssj_hideLoadingIndicator];
    }];
}

- (void)deleteAction {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"确定删除该项记录?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SSJFundingTransferStore deleteFundingTransferWithItem:self.item Success:^{
            [CDAutoHideMessageHUD showMessage:@"删除成功"];
            [self.navigationController popViewControllerAnimated:YES];
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        } failure:NULL];
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

#pragma mark - LazyLoading
- (TPKeyboardAvoidingTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[TPKeyboardAvoidingTableView alloc]initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        [_tableView registerClass:[SSJChargeCircleModifyCell class] forCellReuseIdentifier:kCellId];
        _tableView.rowHeight = 55;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 80)];
        [footerView addSubview:self.saveButton];
        self.saveButton.center = CGPointMake(footerView.width / 2, footerView.height / 2);
        _tableView.tableFooterView = footerView;
    }
    return _tableView;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.width - 20, 40)];
        _saveButton.layer.cornerRadius = 3.f;
        _saveButton.layer.masksToBounds = YES;
        [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [_saveButton setTitle:nil forState:UIControlStateDisabled];
        [_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_saveButton addTarget:self action:@selector(saveButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

- (SSJFundingTypeSelectView *)transferInFundingTypeSelect {
    if (!_transferInFundingTypeSelect) {
        __weak typeof(self) weakSelf = self;
        _transferInFundingTypeSelect = [[SSJFundingTypeSelectView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _transferInFundingTypeSelect.fundingTypeSelectBlock = ^(SSJFundingItem *fundingItem) {
            if ([fundingItem.fundingName isEqualToString:@"添加新的资金账户"]) {
                SSJFundingTypeSelectViewController *newFundingVC = [[SSJFundingTypeSelectViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
                newFundingVC.needLoanOrNot = NO;
                newFundingVC.addNewFundingBlock = ^(SSJBaseCellItem *item) {
                    if ([item isKindOfClass:[SSJFundingItem class]]) {
                        SSJFundingItem *fundItem = (SSJFundingItem *)item;
                        weakSelf.item.transferInId = fundItem.fundingID;
                        weakSelf.item.transferInName = fundItem.fundingName;
                        weakSelf.item.transferInImage = fundItem.fundingIcon;
                    } else if ([item isKindOfClass:[SSJCreditCardItem class]]) {
                        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
                        weakSelf.item.transferInId = cardItem.cardId;
                        weakSelf.item.transferInName = cardItem.cardName;
                        weakSelf.item.transferInImage = @"ft_creditcard";
                    } else if ([item isKindOfClass:[SSJFinancingHomeitem class]]) {
                        SSJFinancingHomeitem *homeItem = (SSJFinancingHomeitem *)item;
                        weakSelf.item.transferInId = homeItem.fundingID;
                        weakSelf.item.transferInName = homeItem.fundingName;
                        weakSelf.item.transferInImage = homeItem.fundingIcon;
                    } else {
                        [CDAutoHideMessageHUD showError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"为定义添加资金账户执行的逻辑"}]];
                    }
                    [weakSelf.tableView reloadData];
                };
                [weakSelf.navigationController pushViewController:newFundingVC animated:YES];
            } else {
                
                weakSelf.item.transferInId = fundingItem.fundingID;
                weakSelf.item.transferInName = fundingItem.fundingName;
                weakSelf.item.transferInImage = fundingItem.fundingIcon;
            }
            
            [weakSelf.tableView reloadData];
            [weakSelf.transferInFundingTypeSelect dismiss];
        };
    }
    return _transferInFundingTypeSelect;
}

- (SSJFundingTypeSelectView *)transferOutFundingTypeSelect {
    if (!_transferOutFundingTypeSelect) {
        __weak typeof(self) weakSelf = self;
        _transferOutFundingTypeSelect = [[SSJFundingTypeSelectView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _transferOutFundingTypeSelect.fundingTypeSelectBlock = ^(SSJFundingItem *fundingItem){
            if ([fundingItem.fundingName isEqualToString:@"添加新的资金账户"]) {
                SSJFundingTypeSelectViewController *newFundingVC = [[SSJFundingTypeSelectViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
                newFundingVC.needLoanOrNot = NO;
                newFundingVC.addNewFundingBlock = ^(SSJBaseCellItem *item) {
                    if ([item isKindOfClass:[SSJFundingItem class]]) {
                        SSJFundingItem *fundItem = (SSJFundingItem *)item;
                        weakSelf.item.transferOutId = fundItem.fundingID;
                        weakSelf.item.transferOutName = fundItem.fundingName;
                        weakSelf.item.transferOutImage = fundItem.fundingIcon;
                    } else if ([item isKindOfClass:[SSJCreditCardItem class]]) {
                        SSJCreditCardItem *cardItem = (SSJCreditCardItem *)item;
                        weakSelf.item.transferOutId = cardItem.cardId;
                        weakSelf.item.transferOutName = cardItem.cardName;
                        weakSelf.item.transferOutImage = @"ft_creditcard";
                    } else if ([item isKindOfClass:[SSJFinancingHomeitem class]]) {
                        SSJFinancingHomeitem *homeItem = (SSJFinancingHomeitem *)item;
                        weakSelf.item.transferOutId = homeItem.fundingID;
                        weakSelf.item.transferOutName = homeItem.fundingName;
                        weakSelf.item.transferOutImage = homeItem.fundingIcon;
                    } else {
                        [CDAutoHideMessageHUD showError:[NSError errorWithDomain:SSJErrorDomain code:SSJErrorCodeUndefined userInfo:@{NSLocalizedDescriptionKey:@"为定义添加资金账户执行的逻辑"}]];
                    }
                    [weakSelf.tableView reloadData];
                };
                [weakSelf.navigationController pushViewController:newFundingVC animated:YES];
            } else {
                
                weakSelf.item.transferOutId = fundingItem.fundingID;
                weakSelf.item.transferOutName = fundingItem.fundingName;
                weakSelf.item.transferOutImage = fundingItem.fundingIcon;
            }
            
            [weakSelf.tableView reloadData];
            [weakSelf.transferOutFundingTypeSelect dismiss];
        };
    }
    return _transferOutFundingTypeSelect;
}

- (SSJHomeDatePickerView *)dateSelectionView {
    if (!_dateSelectionView) {
        __weak typeof(self) wself = self;
        _dateSelectionView = [[SSJHomeDatePickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _dateSelectionView.horuAndMinuBgViewBgColor = [UIColor clearColor];;
        _dateSelectionView.datePickerMode = SSJDatePickerModeDate;
        _dateSelectionView.shouldConfirmBlock = ^BOOL(SSJHomeDatePickerView *view, NSDate *date) {
            NSDate *currentDate = [NSDate date];
            currentDate = [NSDate dateWithYear:currentDate.year month:currentDate.month day:currentDate.day];
            if ([date compare:currentDate] == NSOrderedDescending) {
                [CDAutoHideMessageHUD showMessage:@"转账日期不能大于当前日期哦"];
                return NO;
            }
            return YES;
        };
        _dateSelectionView.confirmBlock = ^(SSJHomeDatePickerView *view) {
            wself.item.transferDate = [view.date formattedDateWithFormat:@"yyyy-MM-dd"];
            [wself.tableView reloadData];
        };
    }
    return _dateSelectionView;
}

@end
