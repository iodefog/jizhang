//
//  SSJAddOrEditLoanViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/8/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJAddOrEditLoanViewController.h"
#import "SSJNewFundingViewController.h"
#import "SSJAddOrEditLoanLabelCell.h"
#import "SSJAddOrEditLoanTextFieldCell.h"
#import "SSJAddOrEditLoanSwitchCell.h"
#import "SSJAddOrEditLoanMultiLabelCell.h"
#import "SSJLoanFundAccountSelectionView.h"
#import "SSJLoanHelper.h"

static NSString *const kAddOrEditLoanLabelCellId = @"SSJAddOrEditLoanLabelCell";
static NSString *const kAddOrEditLoanTextFieldCellId = @"SSJAddOrEditLoanTextFieldCell";
static NSString *const kAddOrEditLoanSwitchCellId = @"SSJAddOrEditLoanSwitchCell";
static NSString *const kAddOrEditLoanMultiLabelCellId = @"SSJAddOrEditLoanMultiLabelCell";

@interface SSJAddOrEditLoanViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) SSJLoanFundAccountSelectionView *fundingSelectionView;

@property (nonatomic, strong) NSArray *fundIds;

@end

@implementation SSJAddOrEditLoanViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_loanModel.ID.length) {
        self.title = @"编辑借出款";
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClicked)];
        self.navigationItem.rightBarButtonItem = rightItem;
    } else {
        self.title = @"新建借出款";
        [self initLoanModel];
    }
    
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = self.footerView;
    
    [self updateAppearance];
    
    [self loadData];
}

- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 3;
    } else if (section == 2) {
        return _loanModel.interest ? 2 : 1;
    } else if (section == 3) {
        return 1;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:0]] == NSOrderedSame) {
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                cell.textLabel.text = @"被谁借款";
                break;
                
            case SSJLoanTypeBorrow:
                cell.textLabel.text = @"欠谁钱款";
                break;
        }
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"必填" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        
        return cell;
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:1 inSection:0]] == NSOrderedSame) {
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                cell.textLabel.text = @"借出金额";
                break;
                
            case SSJLoanTypeBorrow:
                cell.textLabel.text = @"欠款金额";
                break;
        }
        
        cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"¥0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        
        return cell;
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:2 inSection:0]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                cell.textLabel.text = @"借出账户";
                break;
                
            case SSJLoanTypeBorrow:
                cell.textLabel.text = @"借入账户";
                break;
        }
        return cell;
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:1]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                cell.textLabel.text = @"借出日期";
                break;
                
            case SSJLoanTypeBorrow:
                cell.textLabel.text = @"借入日期";
                break;
        }
        return cell;
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:1 inSection:1]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        switch (_loanModel.type) {
            case SSJLoanTypeLend:
                cell.textLabel.text = @"借款期限日";
                break;
                
            case SSJLoanTypeBorrow:
                cell.textLabel.text = @"还款期限日";
                break;
        }
        return cell;
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:2 inSection:1]] == NSOrderedSame) {
        SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanTextFieldCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        cell.textLabel.text = @"备注";
        return cell;
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:2]] == NSOrderedSame) {
        SSJAddOrEditLoanSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanSwitchCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        cell.textLabel.text = @"计息";
        return cell;
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:1 inSection:2]] == NSOrderedSame) {
        SSJAddOrEditLoanMultiLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanMultiLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        cell.textLabel.text = @"年收益率";
        return cell;
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:3]] == NSOrderedSame) {
        SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditLoanLabelCellId forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@""];
        cell.textLabel.text = @"到期日提醒";
        return cell;
    } else {
        return [[UITableViewCell alloc] init];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare:[NSIndexPath indexPathForRow:1 inSection:2]] == NSOrderedSame) {
        return 74;
    } else {
        return 54;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare:[NSIndexPath indexPathForRow:2 inSection:0]] == NSOrderedSame) {
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:1]] == NSOrderedSame) {
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:1 inSection:1]] == NSOrderedSame) {
        
    } else if ([indexPath compare:[NSIndexPath indexPathForRow:0 inSection:2]] == NSOrderedSame) {
        
    }
}

#pragma mark - Event
- (void)deleteButtonClicked {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [SSJLoanHelper deleteLoanModel:_loanModel success:^{
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError * _Nonnull error) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [CDAutoHideMessageHUD showMessage:[error localizedDescription]];
    }];
}

- (void)sureButtonAction {
#warning 没有传入remindModel
    _sureButton.enabled = NO;
    [_sureButton ssj_showLoadingIndicator];
    [SSJLoanHelper saveLoanModel:_loanModel remindModel:nil success:^{
        _sureButton.enabled = YES;
        [_sureButton ssj_hideLoadingIndicator];
    } failure:^(NSError * _Nonnull error) {
        _sureButton.enabled = YES;
        [_sureButton ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:[error localizedDescription]];
    }];
}

#pragma mark - Private
- (void)updateAppearance {
    [_sureButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
    [_sureButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor alpha:0.5] forState:UIControlStateDisabled];
    
    CGFloat alpha = [[SSJThemeSetting currentThemeModel].ID isEqualToString:SSJDefaultThemeID] ? 1 : 0.1;
    _tableView.backgroundColor = [UIColor ssj_colorWithHex:@"#FFFFFF" alpha:alpha];
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}

- (void)initLoanModel {
    _loanModel = [[SSJLoanModel alloc] init];
    _loanModel.ID = SSJUUID();
    _loanModel.userID = SSJUSERID();
//    _loanModel.targetFundID = 
    _loanModel.chargeID = SSJUUID();
    _loanModel.targetChargeID = SSJUUID();
    _loanModel.rate = @"0";
    _loanModel.interest = YES;
    _loanModel.operatorType = 0;
}

- (void)loadData {
    _tableView.hidden = YES;
    [self.view ssj_showLoadingIndicator];
    [SSJLoanHelper queryFundModelListWithSuccess:^(NSDictionary<NSString *,NSArray *> * _Nonnull listDic) {
        
        if (_loanModel.remindID.length) {
            
        } else {
            _tableView.hidden = NO;
            [self.view ssj_hideLoadingIndicator];
            
            _fundIds = listDic[SSJFundIDListKey];
            _fundingSelectionView.items = listDic[SSJFundItemListKey];
            [_tableView reloadData];
        }
    } failure:^(NSError * _Nonnull error) {
        _tableView.hidden = NO;
        [self.view ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:[error localizedDescription]];
    }];
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView setTableFooterView:[[UIView alloc] init]];
//        [_tableView registerClass:[SSJLoanListCell class] forCellReuseIdentifier:kLoanListCellId];
        _tableView.rowHeight = 90;
    }
    return _tableView;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 108)];
        _footerView.backgroundColor = [UIColor clearColor];
        [_footerView addSubview:self.sureButton];
    }
    return _footerView;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sureButton setTitle:@"立借条" forState:UIControlStateNormal];
        [_sureButton setTitle:@"" forState:UIControlStateDisabled];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(sureButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _sureButton.frame = CGRectMake((self.footerView.width - 296) * 0.5, 30, 296, 48);
    }
    return _sureButton;
}

- (SSJLoanFundAccountSelectionView *)fundingSelectionView {
    if (!_fundingSelectionView) {
        __weak typeof(self) weakSelf = self;
        _fundingSelectionView = [[SSJLoanFundAccountSelectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
        _fundingSelectionView.selectAccountAction = ^(SSJLoanFundAccountSelectionView *selectionView) {
            
//            weakSelf.loanModel.targetFundID =
        };
    }
    return _fundingSelectionView;
}

@end
