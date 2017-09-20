//
//  SSJAddOrEditFixedFinanceProductViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/18.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJAddOrEditFixedFinanceProductViewController.h"
#import "SSJFundingTypeSelectViewController.h"
#import "SSJReminderEditeViewController.h"
#import "SSJFixedFinanceProductDetailViewController.h"
#import "SSJFixedFinanceProductListViewController.h"

#import "TPKeyboardAvoidingTableView.h"
#import "SSJLoanFundAccountSelectionView.h"
#import "SSJAddOrEditLoanLabelCell.h"
#import "SSJAddOrEditLoanTextFieldCell.h"
#import "SSJAddOrEditLoanMultiLabelCell.h"
#import "SSJFixedFinanceProDetailTableViewCell.h"
#import "SSJJiXiMethodTableViewCell.h"
#import "SSJHomeDatePickerView.h"

#import "SSJFixedFinanceProductItem.h"
#import "SSJFixedFinanceProductCompoundItem.h"
#import "SSJReminderItem.h"
#import "SSJFixedFinanceProductChargeItem.h"

#import "SSJLoanHelper.h"
#import "SSJFixedFinanceProductStore.h"
#import "SSJDataSynchronizer.h"
#import "SSJLocalNotificationStore.h"
#import "SSJFixedFinanceProductHelper.h"

#import "SSJTextFieldToolbarManager.h"
#import "SSJGeTuiManager.h"
#import "NSString+MoneyDisplayFormat.h"
#import "SSJLocalNotificationHelper.h"


static NSString *KTitle1 = @"投资名称";
static NSString *KTitle2 = @"原始本金";
static NSString *KTitle3 = @"转出账户";
static NSString *KTitle4 = @"起息日期";
static NSString *KTitle5 = @"利率";
static NSString *KTitle6 = @"期限";
static NSString *KTitle7 = @"派息方式";
static NSString *KTitle8 = @"提醒";
static NSString *KTitle9 = @"备注";

static NSString *kAddOrEditFixedFinanceProLabelCellId = @"kAddOrEditFixedFinanceProLabelCellId";
static NSString *kAddOrEditFixedFinanceProTextFieldCellId = @"kAddOrEditFixedFinanceProTextFieldCellId";
static NSString *kAddOrEditFixefFinanceProSegmentTextFieldCellId = @"kAddOrEditFixefFinanceProSegmentTextFieldCellId";

@interface SSJAddOrEditFixedFinanceProductViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;

@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) SSJReminderItem *reminderItem;

// 转出账户
@property (nonatomic, strong) SSJLoanFundAccountSelectionView *fundingSelectionView;

// 计息方式
@property (nonatomic, strong) SSJLoanFundAccountSelectionView *jiXiMethodSelectionView;

// 气息时间
@property (nonatomic, strong) SSJHomeDatePickerView *borrowDateSelectionView;

@property (nonatomic, strong) NSArray<NSString *> *imageItems;

@property (nonatomic, strong) NSArray<NSString *> *titleItems;

// 创建时产生的流水
@property (nonatomic, strong) SSJFixedFinanceProductCompoundItem *createCompoundModel;

@property (nonatomic, strong) UITextField *nameTextF;

@property (nonatomic, strong) UITextField *moneyTextF;

@property (nonatomic, strong) UITextField *liLvTextF;

@property (nonatomic, strong) UITextField *qiXianTextF;

@property (nonatomic, strong) UITextField *memoTextF;

@property (nonatomic, strong) UILabel *jixiTextL;

@property (nonatomic, strong) UILabel *liLvTextL;

// 提醒开关
@property (nonatomic, strong) UISwitch *remindSwitch;

@property (nonatomic, strong) SSJSegmentedControl *liLvSegmentControl;

@property (nonatomic, strong) SSJSegmentedControl *qiXiansegmentControl;

/**<#注释#>*/
@property (nonatomic, copy) NSString *title1;

@property (nonatomic, copy) NSString *title2;

@property (nonatomic, copy) NSString *title3;

@property (nonatomic, copy) NSString *title4;

@property (nonatomic, copy) NSString *title5;

/**lilv*/
@property (nonatomic, assign) SSJMethodOfRateOrTime rateType;

@property (nonatomic, assign) SSJMethodOfRateOrTime timeType;

// 原始的借贷金额，只有在编辑记录此金额
@property (nonatomic) double originalMoney;

/**是否让金额更改 当有赎回或者追加金额的时候不让*/
@property (nonatomic, assign) BOOL allowMoneyChanged;

/**<#注释#>*/
@property (nonatomic, strong) SSJFixedFinanceProductItem *oldProductItem;

@end

@implementation SSJAddOrEditFixedFinanceProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = self.footerView;
    [self getWishRemindDetailFromDB];
    
    [self updateTitle];
    [self loadData];
    
    if (_edited) {
        [self initEditCreateCompoundModel];
        self.originalMoney = [_model.money doubleValue];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteButtonClicked)];
        self.navigationItem.rightBarButtonItem = rightItem;
    } else {
        [self initCreateCompoundModel];
    }
    [self updateAppearance];
}

- (void)getWishRemindDetailFromDB {
    if (self.model.remindid.length) {
        self.reminderItem = [SSJLocalNotificationStore queryReminderItemForID:self.model.remindid];
        if (self.model.remindid.length && self.reminderItem.remindState == 1) {
            self.remindSwitch.on = YES;
        }
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self originalData];
}

- (void)setBind {
    MJWeakSelf;
    [RACObserve(self, liLvSegmentControl.selectedSegmentIndex) subscribeNext:^(id x) {
        [weakSelf updateDayLiXiWithRate:[weakSelf.liLvTextF.text doubleValue] * 0.01 interstType:[weakSelf switchRateType:weakSelf.liLvSegmentControl.selectedSegmentIndex rate:YES] money:[weakSelf.moneyTextF.text doubleValue]];
        weakSelf.rateType = weakSelf.liLvSegmentControl.selectedSegmentIndex;
        [weakSelf updateJiXi];
    }];

    [RACObserve(self, qiXiansegmentControl.selectedSegmentIndex) subscribeNext:^(id x) {
        weakSelf.timeType = weakSelf.qiXiansegmentControl.selectedSegmentIndex;
        [weakSelf updateJiXi];
    }];
    
    [RACObserve(self, jiXiMethodSelectionView.selectedIndex) subscribeNext:^(id x) {
        [weakSelf updateJiXi];
    }];
    
    [self.qiXianTextF.rac_textSignal subscribeNext:^(id x) {
        [weakSelf updateJiXi];
    }];
    
    [self.moneyTextF.rac_textSignal subscribeNext:^(id x) {
        [weakSelf updateJiXi];
    }];
    
    [self.liLvTextF.rac_textSignal subscribeNext:^(id x) {
        [weakSelf updateJiXi];
    }];
    
    [RACObserve(self, qiXianTextF.text) subscribeNext:^(id x) {
        [weakSelf updateJiXi];
    }];
    
    [RACObserve(self, liLvTextF.text) subscribeNext:^(id x) {
        [weakSelf updateJiXi];
    }];
    
    [RACObserve(self, qiXianTextF.text) subscribeNext:^(id x) {
        [weakSelf updateJiXi];
    }];
}

- (void)updateJiXi {
    MJWeakSelf;
    if (weakSelf.jiXiMethodSelectionView.selectedIndex >= 0) {
        NSDictionary *dic = [SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:[weakSelf.liLvTextF.text doubleValue] * 0.01 rateType:[weakSelf switchRateType:weakSelf.liLvSegmentControl.selectedSegmentIndex rate:YES] time:[weakSelf.qiXianTextF.text doubleValue] timetype:[weakSelf switchRateType:weakSelf.qiXiansegmentControl.selectedSegmentIndex rate:NO] money:[weakSelf.moneyTextF.text doubleValue] interestType:[weakSelf switchJiXiMethodWithType:weakSelf.jiXiMethodSelectionView.selectedIndex]  startDate:@""];
        
        NSString *targetJiXiStr = [dic objectForKey:@"interest"];
        NSString *oldJiXiStr = [dic objectForKey:@"desc"];
        weakSelf.jixiTextL.attributedText = [oldJiXiStr attributeStrWithTargetStr:targetJiXiStr range:NSMakeRange(0, 0) color:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]];
    }
}

- (SSJMethodOfRateOrTime)switchRateType:(NSUInteger)index rate:(BOOL)rate {
    switch (index) {
        case 0:
            return SSJMethodOfRateOrTimeYear;
            break;
        case 1:
            return SSJMethodOfRateOrTimeMonth;
            break;
        case 2:
            return SSJMethodOfRateOrTimeDay;
            break;
            
        default:
            break;
    }
    if (rate) {
        return SSJMethodOfRateOrTimeYear;
    } else {
        return SSJMethodOfRateOrTimeDay;
    }
    
}

- (NSInteger)indexWithType:(SSJMethodOfRateOrTime)type
{
    switch (type) {
        case SSJMethodOfRateOrTimeYear:
            return 0;
            break;
        case SSJMethodOfRateOrTimeMonth:
            return 1;
            break;
        case SSJMethodOfRateOrTimeDay:
            return 2;
            break;
            
        default:
            break;
    }
}
/**计息方式（一次性付清:0，每日付息到期还本:1，每月付息到期还本:2）*/
//@property (nonatomic, assign) SSJMethodOfInterest interesttype;
- (SSJMethodOfInterest)switchJiXiMethodWithType:(NSInteger)index {
    switch (index) {
        case 0:
            return SSJMethodOfInterestOncePaid;
            break;
        case 1:
            return SSJMethodOfInterestEveryDay;
            break;
        case 2:
            return SSJMethodOfInterestEveryMonth;
            break;
            
        default:
            break;
    }
    return SSJMethodOfInterestOncePaid;
}

- (void)updateTitle {
    if (_edited) {
        self.title = @"编辑固收理财";
    } else {
        self.title = @"添加固收理财";
    }
}

- (void)originalData {
    [self setBind];
    //拍息方式
    @weakify(self);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @strongify(self);
        NSString *targetLiLvStr = [NSString stringWithFormat:@"%.2f",[SSJFixedFinanceProductHelper caculateInterestForEveryDayWithRate:self.model.rate rateType:self.model.ratetype money:[self.model.money doubleValue]]];
        NSString *oldlilvStr = [NSString stringWithFormat:@"起息日开始计息，产生日息%@元",targetLiLvStr];
        self.liLvTextL.attributedText = [oldlilvStr attributeStrWithTargetStr:targetLiLvStr range:NSMakeRange(0, 0) color:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]];
        
        if (self.jiXiMethodSelectionView.selectedIndex > 0) {
            NSDictionary *dic = [SSJFixedFinanceProductHelper caculateYuQiInterestWithRate:self.model.rate rateType:self.model.ratetype time:self.model.time timetype:self.model.timetype money:[self.model.money doubleValue] interestType:self.model.interesttype startDate:@""];
            NSString *targetJiXiStr = [dic objectForKey:@"interest"];
            NSString *oldJiXiStr = [dic objectForKey:@"desc"];
            self.jixiTextL.attributedText = [oldJiXiStr attributeStrWithTargetStr:targetJiXiStr range:NSMakeRange(0, 0) color:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]];
        }
    });
}

- (void)updateDayLiXiWithRate:(double)rate interstType:(SSJMethodOfRateOrTime)rateType money:(double)money {
    self.model.ratetype = rateType;
    NSString *targetLiLvStr = [NSString stringWithFormat:@"%.2f",[SSJFixedFinanceProductHelper caculateInterestForEveryDayWithRate:rate rateType:rateType money:money]];
    

    NSString *oldlilvStr = [NSString stringWithFormat:@"起息日开始计息，产生日息%@元",targetLiLvStr];
    
    self.liLvTextL.attributedText = [oldlilvStr attributeStrWithTargetStr:targetLiLvStr range:NSMakeRange(0, 0) color:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor]];

}

#pragma mark - Theme
- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self updateAppearance];
    [self.tableView reloadData];
}

- (void)updateAppearance {
    [_sureButton ssj_setBackgroundColor:SSJ_BUTTON_NORMAL_COLOR forState:UIControlStateNormal];
    [_sureButton ssj_setBackgroundColor:SSJ_BUTTON_DISABLE_COLOR forState:UIControlStateDisabled];
    _tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}

#pragma mark - Private
- (void)loadData {
    [self.view ssj_showLoadingIndicator];
    self.allowMoneyChanged = YES;// [SSJFixedFinanceProductStore queryIsChangeMoneyWithProductModel:self.model];
    
    if (_edited) {
        self.jiXiMethodSelectionView.selectedIndex = [self switchJiXiMethodWithType:self.model.interesttype];
        self.rateType = self.model.ratetype;
        self.timeType = self.model.timetype;
    } else {
        self.jiXiMethodSelectionView.selectedIndex = -1;
        self.rateType = SSJMethodOfRateOrTimeYear;
        self.timeType = SSJMethodOfRateOrTimeDay;
    }
    
    MJWeakSelf;
    [SSJLoanHelper queryFundModelListWithSuccess:^(NSArray <SSJLoanFundAccountSelectionViewItem *>*items) {
        
        _tableView.hidden = NO;
        [self.view ssj_hideLoadingIndicator];
        
        // 新建借贷设置默认账户
        self.fundingSelectionView.items = items;
        if (_edited) {//编辑
            BOOL hasSelectedFund = NO;  // 是否有选中的账户
            for (int i = 0; i < items.count; i ++) {
                SSJLoanFundAccountSelectionViewItem *item = items[i];
                if ([item.ID isEqualToString:weakSelf.model.targetfundid]) {
                    self.fundingSelectionView.selectedIndex = i;
                    hasSelectedFund = YES;
                    break;
                }
            }
            // 如果此借贷的目标资金账户不在现有账户列表中，就置为nil
            if (!hasSelectedFund) {
                self.model.targetfundid = nil;
            }
        } else {//新建
            self.fundingSelectionView.selectedIndex = -1;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        [_tableView reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        _tableView.hidden = NO;
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
    
    if (self.model) {
        self.oldProductItem = [self.model copy];
    }
    
}

- (void)funditem:(SSJLoanFundAccountSelectionViewItem *)funditem {
    MJWeakSelf;
    
    //查询转出账户列表
    [SSJLoanHelper queryFundModelListWithSuccess:^(NSArray <SSJLoanFundAccountSelectionViewItem *>*items) {
        weakSelf.tableView.hidden = NO;
        [weakSelf.view ssj_hideLoadingIndicator];
        
        // 新建借贷设置默认账户
        weakSelf.fundingSelectionView.items = items;
        if (!funditem) {
            weakSelf.fundingSelectionView.selectedIndex = -1;
        }else {
            for (NSInteger i=0; i<items.count; i++) {
                SSJLoanFundAccountSelectionViewItem *fund = [items ssj_safeObjectAtIndex:i];
                if ([fund.ID isEqualToString:funditem.ID]) {
                    weakSelf.fundingSelectionView.selectedIndex = i;
                    break;
                }
            }
            weakSelf.createCompoundModel.targetChargeModel.fundId = funditem.ID;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } failure:^(NSError * _Nonnull error) {
        _tableView.hidden = NO;
        [weakSelf.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
    
}


- (BOOL)remindLocation {
    //如果已经弹出过授权弹框开启通知
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SSJNoticeAlertKey]) {//弹出过授权弹框
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0f) {
            UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
            if (UIUserNotificationTypeNone == setting.types) {
                //推送关闭(去设置)
                self.remindSwitch.on = NO;
                [SSJAlertViewAdapter showAlertViewWithTitle:@"哎呀，未开启推送通知" message:@"这样会错过您设定的提醒，墙裂建议您打开吆" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:NULL],[SSJAlertViewAction actionWithTitle:@"确定" handler:^(SSJAlertViewAction * _Nonnull action) {
                    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    
                    if([[UIApplication sharedApplication] canOpenURL:url]) {
                        
                        NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];           [[UIApplication sharedApplication] openURL:url];
                    }
                    
                }],nil];
            }else{
                //推送打开去设置提醒详情
                return YES;
            }
        }
        
    } else { //没有弹出过授权弹框
        //弹出授权弹框
        self.remindSwitch.on = NO;
        [[SSJGeTuiManager shareManager] registerRemoteNotificationWithDelegate:[UIApplication sharedApplication]];//远程通知
    }
    return NO;
}


#pragma mark - Action
- (void)deleteButtonClicked {
    MJWeakSelf;
    [SSJFixedFinanceProductStore deleteFixedFinanceProductWithModel:self.model success:^{
        NSArray *array = self.navigationController.viewControllers;
        for (UIViewController *vc in array) {
            if ([vc isKindOfClass:[SSJFixedFinanceProductListViewController class]]) {
                [weakSelf.navigationController popToViewController:vc animated:YES];
                break;
            }
        }
        [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
    } failure:^(NSError * _Nonnull error) {
        [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
    }];
}


- (void)sureButtonAction {
    if (![self checkFixedFinModelIsValid]) return;
    [self updateChargeModels];
    MJWeakSelf;
    NSArray *saveChargeModels = @[self.createCompoundModel];
    _sureButton.enabled = NO;
    [_sureButton ssj_showLoadingIndicator];
    //如果是编辑并且修改了金额，时间，利率，派息方式，期限，期限类型，利率类型的时候
    if (_edited && (!([self.oldProductItem.money doubleValue] == [self.model.money doubleValue]) || self.oldProductItem.time != self.model.time || self.model.timetype != self.oldProductItem.timetype || self.oldProductItem.rate != self.model.rate || self.oldProductItem.ratetype != self.model.ratetype || self.oldProductItem.interesttype != self.model.interesttype)) {
        if (self.remindSwitch.on) {//打开提醒
            _reminderItem.remindState = 1;
        } else {
            //如果新建的时候有提醒编辑的时候删除提醒
            if (self.oldProductItem.remindid.length) {
                _reminderItem = nil;
            }
        }
        
        [SSJAlertViewAdapter showAlertViewWithTitle:@"" message:@"修改后已有的相关流水会被抹清后重新计算生成，您确定要修改吗" action:[SSJAlertViewAction actionWithTitle:@"取消" handler:^(SSJAlertViewAction * _Nonnull action) {
            weakSelf.sureButton.enabled = YES;
            [weakSelf.sureButton ssj_hideLoadingIndicator];
            return ;
        }],[SSJAlertViewAction actionWithTitle:@"确定修改" handler:^(SSJAlertViewAction * _Nonnull action) {
            //保存固定收益理财
            [SSJFixedFinanceProductStore saveFixedFinanceProductWithModel:weakSelf.model chargeModels:saveChargeModels remindModel:_reminderItem success:^{
                weakSelf.sureButton.enabled = YES;
                
                //调转到详情页面
                //如果是新建的时候
                
                if (_edited) {//编辑的时候
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                } else {
                    SSJFixedFinanceProductDetailViewController *detailVC = [[SSJFixedFinanceProductDetailViewController alloc] init];
                    detailVC.productID = weakSelf.model.productid;
                    [weakSelf.navigationController pushViewController:detailVC animated:YES];
                }

                [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
            } failure:^(NSError * _Nonnull error) {
                weakSelf.sureButton.enabled = YES;
                [weakSelf.sureButton ssj_hideLoadingIndicator];
                [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
            }];
            
        }],nil];
    } else {//新建的时候
        //保存固定收益理财
        if (!self.remindSwitch.on && !_edited) {//新建
            self.reminderItem = nil;
        } else if (!_edited && self.remindSwitch.on) { //如果新建并且打开提醒的时候
            self.reminderItem.remindState = 1;
        }
        
        if (_edited) {//编辑
            if (self.remindSwitch.on) {//打开提醒
                _reminderItem.remindState = 1;
            } else {
                //如果新建的时候没有有提醒编辑的时候删除提醒
                if (!self.oldProductItem.remindid.length) {
                    _reminderItem = nil;
                } else {//如果新建的时候有提醒编辑的时候删除提醒
                    _reminderItem.remindState = 0;
                }
            }

        }
        
                [SSJFixedFinanceProductStore saveFixedFinanceProductWithModel:weakSelf.model chargeModels:saveChargeModels remindModel:_reminderItem success:^{
            weakSelf.sureButton.enabled = YES;
            
            if (_edited) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } else {
                //调转到详情页面
                SSJFixedFinanceProductDetailViewController *detailVC = [[SSJFixedFinanceProductDetailViewController alloc] init];
                detailVC.productID = weakSelf.model.productid;
                [weakSelf.navigationController pushViewController:detailVC animated:YES];
                
                //将当期页面从占中删除
                NSMutableArray *array = [weakSelf.navigationController.viewControllers mutableCopy];
                for (UIViewController *vc in array) {
                    if ([vc isKindOfClass:[SSJAddOrEditFixedFinanceProductViewController class]]) {
                        [array removeObject:vc];
                        break;
                    }
                }
                weakSelf.navigationController.viewControllers = [array copy];
            }
            
            //        [self saveRemind];
            
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        } failure:^(NSError * _Nonnull error) {
            weakSelf.sureButton.enabled = YES;
            [weakSelf.sureButton ssj_hideLoadingIndicator];
            [SSJAlertViewAdapter showAlertViewWithTitle:@"出错了" message:[error localizedDescription] action:[SSJAlertViewAction actionWithTitle:@"确定" handler:NULL], nil];
        }];

    }

}

- (void)saveRemind {
    //保存提醒
    MJWeakSelf;
    if (weakSelf.reminderItem && weakSelf.remindSwitch.isOn) {
        weakSelf.model.remindid = weakSelf.reminderItem.remindId.length ? weakSelf.reminderItem.remindId : SSJUUID();
        weakSelf.reminderItem.remindState = 1;
        weakSelf.reminderItem.remindType = SSJReminderTypeWish;
        [SSJLocalNotificationStore asyncsaveReminderWithReminderItem:weakSelf.reminderItem Success:^(SSJReminderItem *Ritem){
            [SSJLocalNotificationHelper registerLocalNotificationWithremindItem:weakSelf.reminderItem];
            [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
        } failure:^(NSError *error) {
            
        }];
    }
}

- (BOOL)checkFixedFinModelIsValid {
    if (!self.nameTextF.text.length) {
        [CDAutoHideMessageHUD showMessage:@"请输入投资名称"];
        return NO;
    }
    
    if (!self.moneyTextF.text.length || [self.moneyTextF.text doubleValue] <=0) {
        [CDAutoHideMessageHUD showMessage:@"请输入投资金额"];
        return NO;
    }
    
    if (!self.model.startDate) {
        [CDAutoHideMessageHUD showMessage:@"请选择起息时间"];
        return NO;
    }
    
    if (!self.liLvTextF.text.length || [self.liLvTextF.text doubleValue] <= 0) {
        [CDAutoHideMessageHUD showMessage:@"请输入利率"];
        return NO;
    }
    if ([self.liLvTextF.text doubleValue] > 100) {
        [CDAutoHideMessageHUD showMessage:@"利率不可以大于100%哦"];
        return NO;
    }
    
    if (!self.qiXianTextF.text.length || [self.qiXianTextF.text doubleValue] <= 0) {
        [CDAutoHideMessageHUD showMessage:@"请输入期限"];
        return NO;
    }
    
    if (self.jiXiMethodSelectionView.selectedIndex < 0) {
        [CDAutoHideMessageHUD showMessage:@"请选择派息方式"];
        return NO;
    }
    
    if (self.fundingSelectionView.selectedIndex < 0) {
        [CDAutoHideMessageHUD showMessage:@"请选择账户"];
        return NO;
    }
    
    if ([self.model.startDate isLaterThan:[NSDate date]]) {
        [CDAutoHideMessageHUD showMessage:@"不能输入未来时间"];
        return NO;
    }

    return YES;
}

- (void)updateChargeModels {
    self.model.oldMoney = self.model.money;
    self.model.money = self.moneyTextF.text;
    self.model.memo = self.memoTextF.text;
    self.model.rate = [self.liLvTextF.text doubleValue] * 0.01;
    self.model.time = [self.qiXianTextF.text doubleValue];
    self.model.productName = self.nameTextF.text;
    self.model.ratetype = [self switchRateType:self.liLvSegmentControl.selectedSegmentIndex rate:YES];
    self.model.timetype = [self switchRateType:self.qiXiansegmentControl.selectedSegmentIndex rate:NO];
    self.createCompoundModel.chargeModel.billDate = [self.model.startdate ssj_dateWithFormat:@"yyyy-MM-dd"];
    
    if (self.reminderItem.remindId.length) {
        self.model.remindid = self.reminderItem.remindId;
    }
    
    self.createCompoundModel.chargeModel.money = [self.model.money doubleValue];
    self.createCompoundModel.targetChargeModel.money = [self.model.money doubleValue];
    
//    self.createCompoundModel.chargeModel.memo = self.model.memo;
    
    self.createCompoundModel.targetChargeModel.fundId = self.model.targetfundid;
    self.createCompoundModel.targetChargeModel.billDate = [self.model.startdate ssj_dateWithFormat:@"yyyy-MM-dd"];
//    self.createCompoundModel.targetChargeModel.memo = self.model.memo;
    
    self.model.enddate = [[SSJFixedFinanceProductHelper endDateWithStartDate:[self.model.startdate ssj_dateWithFormat:@"yyyy-MM-dd"] time:self.model.time timeType:self.model.timetype] formattedDateWithFormat:@"yyyy-MM-dd"];
    NSDate *billDate = self.model.startDate;
    NSString *cid = [NSString stringWithFormat:@"%@_%.2f",self.model.productid,[billDate timeIntervalSince1970]];
    self.createCompoundModel.chargeModel.cid = self.createCompoundModel.targetChargeModel.cid = cid;
}


- (void)switchValueChanged:(UISwitch *)switchc {
    if (!switchc.isOn) return;
    //判断有没有授权
    if ([self remindLocation]) {
        SSJReminderEditeViewController *remindEditeVc = [[SSJReminderEditeViewController alloc] init];
        remindEditeVc.needToSave = YES;
        __weak typeof(self) weakSelf = self;
        remindEditeVc.addNewReminderAction = ^(SSJReminderItem *item) {
            weakSelf.remindSwitch.on = YES;
            item.remindState = YES;
            item.remindType = SSJFixedFinaProduct;
            weakSelf.reminderItem = item;
        };
        
        remindEditeVc.notSaveReminderAction = ^{
            weakSelf.remindSwitch.on = NO;
        };
        remindEditeVc.needToSave = YES;
        [self.navigationController pushViewController:remindEditeVc animated:YES];
    }
}



- (void)enterReminderVC {
    SSJReminderItem *tmpRemindItem = _reminderItem;
    
    if (!tmpRemindItem) {
        NSDate *paymentDate = [self paymentDate];
        
        tmpRemindItem = [[SSJReminderItem alloc] init];
        tmpRemindItem.remindName = [NSString stringWithFormat:@"投资名称+投资到期"];
        
        tmpRemindItem.remindCycle = 7;
        tmpRemindItem.remindType = SSJReminderTypeBorrowing;
        tmpRemindItem.remindDate = [NSDate dateWithYear:paymentDate.year month:paymentDate.month day:paymentDate.day hour:20 minute:0 second:0];
        tmpRemindItem.minimumDate = [NSDate date];
        tmpRemindItem.remindState = YES;
//        tmpRemindItem.borrowtarget = self.loanModel.lender;
    }
    
    __weak typeof(self) wself = self;
    SSJReminderEditeViewController *reminderVC = [[SSJReminderEditeViewController alloc] init];
    reminderVC.needToSave = NO;
    reminderVC.item = tmpRemindItem;
    reminderVC.addNewReminderAction = ^(SSJReminderItem *item) {
        wself.reminderItem = item;
        wself.model.remindid = wself.model.productid;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
        [wself.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    };
    reminderVC.deleteReminderAction = ^{
        wself.reminderItem = nil;
        wself.reminderItem.remindId = nil;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
        [wself.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    };
    [self.navigationController pushViewController:reminderVC animated:YES];
}

- (NSDate *)paymentDate {
    return [NSDate date];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self.titleItems ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:KTitle3]) {
        [self.view endEditing:YES];
        
        [self.fundingSelectionView show];
    } else if ([title isEqualToString:KTitle4]) {
        [self.view endEditing:YES];
        self.borrowDateSelectionView.date = [NSDate date];
        [self.borrowDateSelectionView show];
    } else if ([title isEqualToString:KTitle7]) {
        [self.view endEditing:YES];
        [self.jiXiMethodSelectionView show];
    } else if ([title isEqualToString:KTitle8]) {
        if (_reminderItem) {
            [self enterReminderVC];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self.titleItems ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:KTitle5] || [title isEqualToString:KTitle6] || [title isEqualToString:KTitle7]) {
        return 75;
    }
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titleItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.titleItems ssj_safeObjectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self.titleItems ssj_objectAtIndexPath:indexPath];
    NSString *imageName = [self.imageItems ssj_objectAtIndexPath:indexPath];
    if ([title isEqualToString:KTitle1]) {
        return [self cellOfKTitle1WithTableView:tableView indexPath:indexPath title:title image:imageName];
    } else if ([title isEqualToString:KTitle2]){
        return [self cellOfKTitle2WithTableView:tableView indexPath:indexPath title:title image:imageName];
    } else if ([title isEqualToString:KTitle3]){
        return [self cellOfKTitle3WithTableView:tableView indexPath:indexPath title:title image:imageName];
    } else if ([title isEqualToString:KTitle4]){
        return [self cellOfKTitle4WithTableView:tableView indexPath:indexPath title:title image:imageName];
    } else if ([title isEqualToString:KTitle5]){
        return [self cellOfKTitle5WithTableView:tableView indexPath:indexPath title:title image:imageName];
    } else if ([title isEqualToString:KTitle6]){
        return [self cellOfKTitle6WithTableView:tableView indexPath:indexPath title:title image:imageName];
    } else if ([title isEqualToString:KTitle7]){
        return [self cellOfKTitle7WithTableView:tableView indexPath:indexPath title:title image:imageName];
    } else if ([title isEqualToString:KTitle8]){
        return [self cellOfKTitle8WithTableView:tableView indexPath:indexPath title:title image:imageName];
    } else if ([title isEqualToString:KTitle9]){
        return [self cellOfKTitle9WithTableView:tableView indexPath:indexPath title:title image:imageName];
    }
    return nil;
}

- (__kindof UITableViewCell *)cellOfKTitle1WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixedFinanceProTextFieldCellId forIndexPath:indexPath];
    cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.textLabel.text = title;
    cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"必填" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    cell.textField.text = self.model.productName;
    cell.textField.keyboardType = UIKeyboardTypeDefault;
    cell.textField.returnKeyType = UIReturnKeyDone;
    cell.textField.delegate = self;
    cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.nameTextF = cell.textField;
    cell.textField.text = self.edited == YES ? self.model.productName : self.title1;
    [cell setNeedsLayout];
    cell.userInteractionEnabled = YES;
    return cell;
}

- (__kindof UITableViewCell *)cellOfKTitle2WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixedFinanceProTextFieldCellId forIndexPath:indexPath];
    cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.textLabel.text = title;
    cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"0.00" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
//    cell.textField.text = [NSString stringWithFormat:@"%.2f", [self.model.money doubleValue]];
    cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
    cell.textField.returnKeyType = UIReturnKeyDone;
    cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    cell.textField.delegate = self;
    if (self.edited == YES) {
        cell.textField.text = [NSString stringWithFormat:@"%@",[SSJFixedFinanceProductStore queryOrangeMoneyWithProductModel:self.model]];
    } else {
        cell.textField.text = self.title2;
    }
    
    self.moneyTextF = cell.textField;
    [cell setNeedsLayout];
    [cell.textField ssj_installToolbar];
    //通过是否有赎回或者追加的记录
    cell.userInteractionEnabled = self.allowMoneyChanged;
    return cell;
}

- (__kindof UITableViewCell *)cellOfKTitle3WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixedFinanceProLabelCellId forIndexPath:indexPath];
    cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.textLabel.text = title;
    if (_fundingSelectionView.selectedIndex >= 0) {
        SSJLoanFundAccountSelectionViewItem *selectedFundItem = [self.fundingSelectionView.items ssj_safeObjectAtIndex:_fundingSelectionView.selectedIndex];
        cell.additionalIcon.image = [UIImage imageNamed:selectedFundItem.image];
        cell.subtitleLabel.text = selectedFundItem.title;
    } else {
        cell.additionalIcon.image = nil;
        cell.subtitleLabel.text = @"请选择账户";
    }
    
    cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.switchControl.hidden = YES;
    cell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
    [cell setNeedsLayout];
    cell.userInteractionEnabled = YES;
    return cell;
}

- (__kindof UITableViewCell *)cellOfKTitle4WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixedFinanceProLabelCellId forIndexPath:indexPath];
    cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.textLabel.text = title;
    cell.additionalIcon.image = nil;
    cell.subtitleLabel.text = self.model.startdate ? : [[NSDate date] ssj_dateStringWithFormat:@"yyyy-MM-dd"];
//    [self.model.startDate ssj_dateStringFromFormat:@"yyyy.MM.dd HH:mm:ss.SSS" toFormat:@"yyyy-MM-dd"] 
    cell.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.switchControl.hidden = YES;
    cell.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
    [cell setNeedsLayout];
    cell.userInteractionEnabled = YES;
    return cell;
}

- (__kindof UITableViewCell *)cellOfKTitle5WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJFixedFinanceProDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixefFinanceProSegmentTextFieldCellId forIndexPath:indexPath];
    cell.leftImageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入利率" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
    cell.textField.delegate = self;
    cell.textField.text = self.edited ? [NSString stringWithFormat:@"%.2f",self.model.rate * 100] : self.title3;
    cell.nameL.text = @"利率";
    self.liLvTextF = cell.textField;
    cell.segmentControl.selectedSegmentIndex = [self indexWithType:self.rateType];
    self.liLvSegmentControl = cell.segmentControl;
    self.liLvTextL = cell.subNameL;
    
    cell.hasPercentageL = YES;
    cell.userInteractionEnabled = YES;
    return cell;
}

- (__kindof UITableViewCell *)cellOfKTitle6WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJFixedFinanceProDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixefFinanceProSegmentTextFieldCellId forIndexPath:indexPath];
    cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入整数" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    cell.textField.keyboardType = UIKeyboardTypeNumberPad;
    cell.textField.returnKeyType = UIReturnKeyDone;
    cell.textField.delegate = self;
    cell.textField.text = self.edited ? [NSString stringWithFormat:@"%.f",self.model.time] : self.title4;
    self.qiXianTextF = cell.textField;
    self.qiXiansegmentControl = cell.segmentControl;
    cell.leftImageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.nameL.text = @"期限";

    cell.segmentControl.selectedSegmentIndex = [self indexWithType:self.timeType];

    cell.userInteractionEnabled = YES;
    
    return cell;
}

- (__kindof UITableViewCell *)cellOfKTitle7WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJJiXiMethodTableViewCell *cell = [SSJJiXiMethodTableViewCell cellWithTableView:tableView];
    cell.additionalIcon.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.nameLabel.text = title;
    if (_jiXiMethodSelectionView.selectedIndex >= 0) {
        SSJLoanFundAccountSelectionViewItem *selectedFundItem = [self.jiXiMethodSelectionView.items ssj_safeObjectAtIndex:_jiXiMethodSelectionView.selectedIndex];
        cell.detailL.text = selectedFundItem.title;
    } else {
        cell.detailL.text = @"请选择派息方式";
    }
    self.jixiTextL = cell.subtitleLabel;
    [cell setNeedsLayout];
    cell.userInteractionEnabled = YES;
    return cell;

}

- (__kindof UITableViewCell *)cellOfKTitle8WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJAddOrEditLoanLabelCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixedFinanceProLabelCellId forIndexPath:indexPath];
    cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.textLabel.text = title;
    cell.subtitleLabel.text = [_reminderItem.remindDate formattedDateWithFormat:@"yyyy.MM.dd"];
    cell.additionalIcon.image = nil;
    cell.customAccessoryType = UITableViewCellAccessoryNone;
    cell.switchControl.hidden = NO;
    cell.switchControl.on = _reminderItem.remindState && _reminderItem.remindId.length;
    [cell.switchControl removeTarget:self action:NULL forControlEvents:UIControlEventValueChanged];
    [cell.switchControl addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    cell.selectionStyle = _reminderItem ? SSJ_CURRENT_THEME.cellSelectionStyle : UITableViewCellSelectionStyleNone;
    self.remindSwitch = cell.switchControl;
    [cell setNeedsLayout];
    cell.userInteractionEnabled = YES;
    return cell;

}

- (__kindof UITableViewCell *)cellOfKTitle9WithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title image:(NSString *)imageName {
    SSJAddOrEditLoanTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kAddOrEditFixedFinanceProTextFieldCellId forIndexPath:indexPath];
    cell.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.textLabel.text = @"备注";
    cell.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"备注说明" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    cell.textField.text = self.edited ? self.model.memo : self.title5;
    cell.textField.keyboardType = UIKeyboardTypeDefault;
    cell.textField.returnKeyType = UIReturnKeyDone;
    cell.textField.clearsOnBeginEditing = NO;
    cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    cell.textField.delegate = self;
    self.memoTextF = cell.textField;
    [cell setNeedsLayout];
    cell.userInteractionEnabled = YES;
    return cell;

}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (self.nameTextF == textField) {
        self.title1 = text;
    } else if (self.moneyTextF == textField) {
        self.title2 = [text ssj_reserveDecimalDigits:2 intDigits:9];
    } else if (self.liLvTextF == textField) {
        self.title3 = [text ssj_reserveDecimalDigits:2 intDigits:9];
    } else if (self.qiXianTextF == textField) {
        self.title4 = text;
    } else if (self.memoTextF == textField) {
        self.title5 = text;
    }
    
    
    if (self.moneyTextF == textField || self.liLvTextF == textField) {
        textField.text = [text ssj_reserveDecimalDigits:2 intDigits:9];
        
        //计算利息
        [self updateDayLiXiWithRate:[self.liLvTextF.text doubleValue] * 0.01 interstType:[self switchRateType:self.liLvSegmentControl.selectedSegmentIndex rate:YES] money:[self.moneyTextF.text doubleValue]];
        return NO;
    } else if (self.qiXianTextF == textField) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = [text ssj_reserveDecimalDigits:2 intDigits:9];
        return NO;
    }
    return YES;
}

#pragma mark - Lazy
- (TPKeyboardAvoidingTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundView = nil;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView registerClass:[SSJAddOrEditLoanLabelCell class] forCellReuseIdentifier:kAddOrEditFixedFinanceProLabelCellId];
        [_tableView registerClass:[SSJAddOrEditLoanTextFieldCell class] forCellReuseIdentifier:kAddOrEditFixedFinanceProTextFieldCellId];
        [_tableView registerClass:[SSJFixedFinanceProDetailTableViewCell class] forCellReuseIdentifier:kAddOrEditFixefFinanceProSegmentTextFieldCellId];
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
        [_sureButton setTitle:@"保存" forState:UIControlStateNormal];
        [_sureButton setTitle:@"" forState:UIControlStateDisabled];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(sureButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _sureButton.frame = CGRectMake(15, 30, self.footerView.width - 30, 44);
        _sureButton.clipsToBounds = YES;
        _sureButton.layer.cornerRadius = 6;
    }
    return _sureButton;
}

- (SSJLoanFundAccountSelectionView *)fundingSelectionView {
    if (!_fundingSelectionView) {
        __weak typeof(self) weakSelf = self;
        _fundingSelectionView = [[SSJLoanFundAccountSelectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _fundingSelectionView.shouldSelectAccountAction = ^BOOL(SSJLoanFundAccountSelectionView *view, NSUInteger index) {
            if (index < view.items.count - 1) {
                SSJLoanFundAccountSelectionViewItem *item = [view.items objectAtIndex:index];
                weakSelf.model.targetfundid = item.ID;
                weakSelf.fundingSelectionView.selectedIndex = index;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                return YES;
            } else if (index == view.items.count - 1) {
                SSJFundingTypeSelectViewController *NewFundingVC = [[SSJFundingTypeSelectViewController alloc]initWithTableViewStyle:UITableViewStyleGrouped];
                NewFundingVC.needLoanOrNot = NO;
                NewFundingVC.addNewFundingBlock = ^(SSJFinancingHomeitem *item){
                        weakSelf.model.targetfundid = item.fundingID;
                    weakSelf.createCompoundModel.chargeModel.fundId = item.fundingID;
                    SSJLoanFundAccountSelectionViewItem *funItem = [[SSJLoanFundAccountSelectionViewItem alloc] init];
                    funItem.title = item.fundingName;
                    funItem.image = item.fundingIcon;
                    funItem.ID = item.fundingID;
                    [weakSelf funditem:funItem];
                };
                [weakSelf.navigationController pushViewController:NewFundingVC animated:YES];
                return NO;
            } else {
                SSJPRINT(@"警告：selectedIndex大于数组范围");
                return NO;
            }
        };
    }
    return _fundingSelectionView;
}


- (SSJLoanFundAccountSelectionView *)jiXiMethodSelectionView {
    if (!_jiXiMethodSelectionView) {
        __weak typeof(self) weakSelf = self;
        NSArray *titleArr = @[@"一次性还本付息",@"每日付息，到期还本"];
        NSMutableArray *itemArr = [NSMutableArray array];
        for (NSString *title in titleArr) {
            SSJLoanFundAccountSelectionViewItem *item = [[SSJLoanFundAccountSelectionViewItem alloc] init];
            item.title = title;
            [itemArr addObject:item];
        }
        
        _jiXiMethodSelectionView = [[SSJLoanFundAccountSelectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 142)];
        
        _jiXiMethodSelectionView.title = @"派息方式";
        _jiXiMethodSelectionView.items = itemArr;
        _jiXiMethodSelectionView.shouldSelectAccountAction = ^BOOL(SSJLoanFundAccountSelectionView *view, NSUInteger index) {
            if (weakSelf.qiXiansegmentControl.selectedSegmentIndex == 2 && index == 2) {
                [CDAutoHideMessageHUD showMessage:@"期限为日则不能选择每月付息派息方式"];
                return NO;
            }
            
            if (index <= view.items.count - 1) {
                SSJLoanFundAccountSelectionViewItem *item = [view.items objectAtIndex:index];
                weakSelf.model.interesttype = index;
                weakSelf.jiXiMethodSelectionView.selectedIndex = index;
                
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:1];
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                return YES;
            } else {
                SSJPRINT(@"警告：selectedIndex大于数组范围");
                return NO;
            }
        };
    }
    return _jiXiMethodSelectionView;
}


- (SSJHomeDatePickerView *)borrowDateSelectionView {
    if (!_borrowDateSelectionView) {
        __weak typeof(self) wself = self;
        _borrowDateSelectionView = [[SSJHomeDatePickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 244)];
        _borrowDateSelectionView.horuAndMinuBgViewBgColor = [UIColor clearColor];
        _borrowDateSelectionView.datePickerMode = SSJDatePickerModeDate;
        _borrowDateSelectionView.shouldConfirmBlock = ^BOOL(SSJHomeDatePickerView *view, NSDate *date) {
            if ([date isLaterThan:[NSDate date]]) {
                [CDAutoHideMessageHUD showMessage:@"不能输入未来时间"];
                return NO;
            }
            return YES;
        };
        _borrowDateSelectionView.confirmBlock = ^(SSJHomeDatePickerView *view) {
            
            wself.model.startDate = view.date;
            wself.model.startdate = [view.date formattedDateWithFormat:@"yyyy-MM-dd"];
            
            if (wself.reminderItem.remindDate && [view.date compare:wself.reminderItem.remindDate] == NSOrderedDescending) {
                wself.reminderItem.remindDate = view.date;
            }
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
            [wself.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        };
    }
    return _borrowDateSelectionView;
}


- (NSArray<NSString *> *)imageItems {
    if (!_imageItems) {
        _imageItems = @[@[@"loan_person",@"loan_money",@"fixed_finance_out"],@[@"fixed_finance_qixi",@"fixed_finance_lixi",@"fixed_finance_time_qixian",@"fixed_finance_paixi_method"],@[@"loan_remind",@"loan_memo"]];
    }
    return _imageItems;
}

- (NSArray<NSString *> *)titleItems {
    if (!_titleItems) {
        _titleItems = @[@[KTitle1,KTitle2,KTitle3],@[KTitle4,KTitle5,KTitle6,KTitle7],@[KTitle8,KTitle9]];
    }
    return _titleItems;
}

- (SSJReminderItem *)reminderItem {
    if (!_reminderItem) {
        _reminderItem = [[SSJReminderItem alloc] init];
    }
    return _reminderItem;
}


- (UISwitch *)remindSwitch {
    if (!_remindSwitch) {
        _remindSwitch = [[UISwitch alloc] init];
        [_remindSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _remindSwitch;
}

- (void)initCreateCompoundModel {
    if (!_createCompoundModel) {
            NSString *chargeBillId = @"3";
            NSString *targetChargeBillId = @"4";
            NSString *uuid = SSJUUID();
            SSJFixedFinanceProductChargeItem *chargeModel = [[SSJFixedFinanceProductChargeItem alloc] init];
            chargeModel.chargeId = [NSString stringWithFormat:@"%@_%@",uuid,chargeBillId];
            chargeModel.fundId = self.model.thisfundid;
            chargeModel.billId = chargeBillId;
            chargeModel.userId = SSJUSERID();
            chargeModel.chargeType = SSJLoanCompoundChargeTypeCreate;
            
            SSJFixedFinanceProductChargeItem *targetChargeModel = [[SSJFixedFinanceProductChargeItem alloc] init];
            targetChargeModel.chargeId = [NSString stringWithFormat:@"%@_%@",uuid,targetChargeBillId];;
            targetChargeModel.fundId = self.model.targetfundid;
            targetChargeModel.billId = targetChargeBillId;
            targetChargeModel.userId = SSJUSERID();
            targetChargeModel.chargeType = SSJLoanCompoundChargeTypeCreate;
            
            _createCompoundModel = [[SSJFixedFinanceProductCompoundItem alloc] init];
            _createCompoundModel.chargeModel = chargeModel;
            _createCompoundModel.targetChargeModel = targetChargeModel;
    }
}

- (void)initEditCreateCompoundModel {
    if (!_createCompoundModel) {
        NSString *chargeBillId = @"3";
        NSString *targetChargeBillId = @"4";

        SSJFixedFinanceProductChargeItem *chargeModel = [[SSJFixedFinanceProductChargeItem alloc] init];
       SSJFixedFinanceProductChargeItem *chargeItem =[SSJFixedFinanceProductStore queryChargeItemOfOrangeMoneyWithProductModel:self.model];
        chargeModel.chargeId = chargeItem.chargeId;
        chargeModel.fundId = self.model.thisfundid;
        chargeModel.billId = chargeBillId;
        chargeModel.userId = SSJUSERID();

        SSJFixedFinanceProductChargeItem *targetChargeModel = [[SSJFixedFinanceProductChargeItem alloc] init];
        NSString *uuid = [[chargeItem.chargeId componentsSeparatedByString:@"_"] firstObject];
        targetChargeModel.chargeId = [NSString stringWithFormat:@"%@_%@",uuid,targetChargeBillId];;
        targetChargeModel.fundId = self.model.targetfundid;
        targetChargeModel.billId = targetChargeBillId;
        targetChargeModel.userId = SSJUSERID();

        
        _createCompoundModel = [[SSJFixedFinanceProductCompoundItem alloc] init];
        _createCompoundModel.chargeModel = chargeModel;
        _createCompoundModel.targetChargeModel = targetChargeModel;
    }
}

- (SSJFixedFinanceProductItem *)model {
    if (!_model) {
        _model = [[SSJFixedFinanceProductItem alloc] init];
        _model.productid = SSJUUID();
        _model.userid = SSJUSERID();
        _model.thisfundid = [NSString stringWithFormat:@"%@-8", SSJUSERID()];
        _model.startDate = [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day];
        _model.startdate = [_model.startDate formattedDateWithFormat:@"yyyy-MM-dd"];
        
    }
    return _model;
}

@end
