//
//  SSJBudgetEditViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/2/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetEditViewController.h"
#import "SSJBudgetEditPeriodSelectionView.h"
#import "SSJBudgetEditLabelCell.h"
#import "SSJBudgetEditTextFieldCell.h"
#import "SSJBudgetEditSwitchCtrlCell.h"
#import "SSJBudgetDatabaseHelper.h"
#import "SSJBudgetCalendarHelper.h"

static NSString *const kBudgetEditLabelCellId = @"kBudgetEditLabelCellId";
static NSString *const kBudgetEditTextFieldCellId = @"kBudgetEditTextFieldCellId";
static NSString *const kBudgetEditSwitchCtrlCellId = @"kBudgetEditSwitchCtrlCellId";

static NSString *const kBudgetTypeTitle = @"预算类别";
static NSString *const kAutoContinueTitle = @"自动续用";
static NSString *const kBudgetMoneyTitle = @"金额";
static NSString *const kBudgetRemindTitle = @"预算提醒";
static NSString *const kBudgetRemindScaleTitle = @"预算占比提醒";
static NSString *const kBudgetPeriodTitle = @"周期";

@interface SSJBudgetEditViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) UIButton *saveBtn;

@property (nonatomic, strong) SSJBudgetEditPeriodSelectionView *periodSelectionView;

@property (nonatomic, strong) NSArray *cellTitles;

@property (nonatomic, strong) NSArray *budgetTypeList;

@property (nonatomic, strong) NSDictionary *budgetTypeMap;

@end

@implementation SSJBudgetEditViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.navigationItem.title = @"编辑预算";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self queryBillTypeList];
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cellTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.cellTitles ssj_safeObjectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self reuseCellIdForIndexPath:indexPath] forIndexPath:indexPath];
    [self updateCell:cell forIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *title = [self.cellTitles ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:kBudgetMoneyTitle]) {
        
    } else if ([title isEqualToString:kBudgetRemindScaleTitle]) {
        
    } else if ([title isEqualToString:kBudgetPeriodTitle]) {
        [self.periodSelectionView show];
    }
}

#pragma mark - Event
- (void)autoContinueSwitchCtrlAction:(UISwitch *)switchCtrl {
    self.model.isAutoContinued = switchCtrl.isOn;
}

- (void)remindSwitchCtrlAction:(UISwitch *)switchCtrl {
    self.model.isRemind = switchCtrl.isOn;
}

- (void)periodSelectionViewAction {
    switch (self.periodSelectionView.periodType) {
        case SSJBudgetPeriodTypeWeek:
            self.model.type = 0;
            break;
            
        case SSJBudgetPeriodTypeMonth:
            self.model.type = 1;
            break;
            
        case SSJBudgetPeriodTypeYear:
            self.model.type = 2;
            break;
    }
    [self.tableView reloadData];
}

- (void)saveButtonAction {
    self.saveBtn.enabled = NO;
    [self.saveBtn ssj_showLoadingIndicator];
    [self.saveBtn setTitle:nil forState:UIControlStateNormal];
    
    [SSJBudgetDatabaseHelper saveBudgetModel:self.model success:^{
        self.saveBtn.enabled = YES;
        [self.saveBtn ssj_hideLoadingIndicator];
        [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    } failure:^(NSError * _Nonnull error) {
        self.saveBtn.enabled = YES;
        [self.saveBtn ssj_hideLoadingIndicator];
        [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:SSJ_ERROR_MESSAGE action:action, nil];
    }];
}

#pragma mark - Private
- (void)queryBillTypeList {
    [self.view ssj_showLoadingIndicator];
    [SSJBudgetDatabaseHelper queryBillTypeMapWithSuccess:^(NSDictionary * _Nonnull billTypeMap) {
        [self.view ssj_hideLoadingIndicator];
        self.budgetTypeMap = billTypeMap;
        if (!self.model) {
            [self initBudgetModel];
        }
        [self updateCellTitles];
        [self.tableView reloadData];
        
        self.periodSelectionView.periodType = self.model.type;
    } failure:^(NSError * _Nonnull error) {
        [self.view ssj_hideLoadingIndicator];
        SSJAlertViewAction *action = [SSJAlertViewAction actionWithTitle:@"确认" handler:NULL];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"温馨提示" message:SSJ_ERROR_MESSAGE action:action, nil];
    }];
}

- (void)initBudgetModel {
    self.model = [[SSJBudgetModel alloc] init];
    self.model.ID = SSJUUID();
    self.model.userId = SSJUSERID();
    self.model.billIds = [self.budgetTypeMap allKeys];
    self.model.type = 1;
    self.model.budgetMoney = 3000;
    self.model.remindMoney = 300;
    self.model.beginDate = [SSJBudgetCalendarHelper getFirstDayOfCurrentWeek];
    self.model.endDate = [SSJBudgetCalendarHelper getLastDayOfCurrentWeek];
    self.model.isAutoContinued = YES;
    self.model.isRemind = YES;
}

- (void)updateCellTitles {
    if (self.model.isRemind) {
        self.cellTitles = @[@[kBudgetTypeTitle], @[kAutoContinueTitle], @[kBudgetMoneyTitle], @[kBudgetRemindTitle, kBudgetRemindScaleTitle], @[kBudgetPeriodTitle]];
    } else {
        self.cellTitles = @[@[kBudgetTypeTitle], @[kAutoContinueTitle], @[kBudgetMoneyTitle], @[kBudgetRemindTitle], @[kBudgetPeriodTitle]];
    }
}

- (NSString *)reuseCellIdForIndexPath:(NSIndexPath *)indexPath {
    NSString *cellTitle = [self.cellTitles ssj_objectAtIndexPath:indexPath];
    if ([cellTitle isEqualToString:kBudgetTypeTitle]
        || [cellTitle isEqualToString:kBudgetRemindScaleTitle]
        || [cellTitle isEqualToString:kBudgetPeriodTitle]) {
        return kBudgetEditLabelCellId;
    } else if ([cellTitle isEqualToString:kBudgetMoneyTitle]) {
        return kBudgetEditTextFieldCellId;
    } else if ([cellTitle isEqualToString:kAutoContinueTitle]
               || [cellTitle isEqualToString:kBudgetRemindTitle]) {
        return kBudgetEditSwitchCtrlCellId;
    } else {
        return @"";
    }
}

- (void)updateCell:(__kindof UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    NSString *cellTitle = [self.cellTitles ssj_objectAtIndexPath:indexPath];
    cell.textLabel.text = cellTitle;
    [cell.textLabel sizeToFit];
    [cell setNeedsLayout];
    
    if ([cellTitle isEqualToString:kBudgetTypeTitle]) {
        //  预算类别
        SSJBudgetEditLabelCell *budgetTypeCell = cell;
        
        budgetTypeCell.subtitleLab.text = [self budgetTypeNames];
        [budgetTypeCell.subtitleLab sizeToFit];
        
        budgetTypeCell.detailTextLabel.text = nil;
        [budgetTypeCell.detailTextLabel sizeToFit];

    } else if ([cellTitle isEqualToString:kAutoContinueTitle]) {
        //  自动续用
        SSJBudgetEditSwitchCtrlCell *autoContinueCell = cell;
        [autoContinueCell.switchCtrl addTarget:self action:@selector(autoContinueSwitchCtrlAction:) forControlEvents:UIControlEventValueChanged];
        [autoContinueCell.switchCtrl setOn:self.model.isAutoContinued animated:YES];
        autoContinueCell.detailTextLabel.text = @"系统会自动为您自动续用您设置的预算内容";
        [autoContinueCell.detailTextLabel sizeToFit];
        
    } else if ([cellTitle isEqualToString:kBudgetMoneyTitle]) {
        //  预算金额
        SSJBudgetEditTextFieldCell *budgetMoneyCell = cell;
        budgetMoneyCell.textField.text = [NSString stringWithFormat:@"%f", self.model.budgetMoney];
        
    } else if ([cellTitle isEqualToString:kBudgetRemindTitle]) {
        //  预算提醒
        SSJBudgetEditSwitchCtrlCell *budgetRemindCell = cell;
        [budgetRemindCell.switchCtrl addTarget:self action:@selector(remindSwitchCtrlAction:) forControlEvents:UIControlEventValueChanged];
        [budgetRemindCell.switchCtrl setOn:self.model.isRemind animated:YES];
        budgetRemindCell.detailTextLabel.text = nil;
        [budgetRemindCell.detailTextLabel sizeToFit];
        
    } else if ([cellTitle isEqualToString:kBudgetRemindScaleTitle]) {
        //  预算占比提醒
        SSJBudgetEditLabelCell *budgetRemindScaleCell = cell;
        budgetRemindScaleCell.subtitleLab.text = [NSString stringWithFormat:@"%.0f％", (self.model.remindMoney / self.model.budgetMoney)];
        [budgetRemindScaleCell.subtitleLab sizeToFit];
        
        budgetRemindScaleCell.detailTextLabel.text = [NSString stringWithFormat:@"当预算金额剩余%f时，即会提醒您哦！", self.model.remindMoney];
        [budgetRemindScaleCell.detailTextLabel sizeToFit];
        
        budgetRemindScaleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        budgetRemindScaleCell.selectionStyle = UITableViewCellSelectionStyleGray;
        
    } else if ([cellTitle isEqualToString:kBudgetPeriodTitle]) {
        //  周期
        SSJBudgetEditLabelCell *budgetPeriodCell = cell;
        budgetPeriodCell.subtitleLab.text = [self budgetPeriod];
        [budgetPeriodCell.subtitleLab sizeToFit];
        
        budgetPeriodCell.detailTextLabel.text = nil;
        [budgetPeriodCell.detailTextLabel sizeToFit];
        
        budgetPeriodCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        budgetPeriodCell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
}

- (NSString *)budgetPeriod {
    switch (self.model.type) {
        case 0:
            return @"每周";
        case 1:
            return @"每月";
        case 2:
            return @"每年";
        default:
            return nil;
    }
}

- (NSString *)budgetTypeNames {
    NSMutableArray *typeNameArr = [NSMutableArray arrayWithCapacity:5];
    for (NSString *typeId in self.model.billIds) {
        [typeNameArr addObject:self.budgetTypeMap[typeId]];
        if (typeNameArr.count == 5) {
            break;
        }
    }
    return [typeNameArr componentsJoinedByString:@","];
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.sectionHeaderHeight = 10;
        _tableView.tableFooterView = self.footerView;
        _tableView.backgroundColor = SSJ_DEFAULT_BACKGROUND_COLOR;
        _tableView.separatorColor = SSJ_DEFAULT_SEPARATOR_COLOR;
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView setTableFooterView:[[UIView alloc] init]];
        [_tableView registerClass:[SSJBudgetEditLabelCell class] forCellReuseIdentifier:kBudgetEditLabelCellId];
        [_tableView registerClass:[SSJBudgetEditTextFieldCell class] forCellReuseIdentifier:kBudgetEditTextFieldCellId];
        [_tableView registerClass:[SSJBudgetEditSwitchCtrlCell class] forCellReuseIdentifier:kBudgetEditSwitchCtrlCellId];
    }
    return _tableView;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 66)];
        _footerView.backgroundColor = [UIColor clearColor];
        [_footerView addSubview:self.saveBtn];
    }
    return _footerView;
}

- (UIButton *)saveBtn {
    if (!_saveBtn) {
        _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveBtn.frame = CGRectMake(22, 22, self.view.width, 44);
        _saveBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_saveBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"47cfbe"] forState:UIControlStateNormal];
        [_saveBtn addTarget:self action:@selector(saveButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveBtn;
}

- (SSJBudgetEditPeriodSelectionView *)periodSelectionView {
    if (!_periodSelectionView) {
        _periodSelectionView = [[SSJBudgetEditPeriodSelectionView alloc] init];
        [_periodSelectionView addTarget:self action:@selector(periodSelectionViewAction) forControlEvents:UIControlEventValueChanged];
    }
    return _periodSelectionView;
}

@end
