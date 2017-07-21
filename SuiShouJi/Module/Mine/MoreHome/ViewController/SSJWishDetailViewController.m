//
//  SSJWishDetailViewController.m
//  SuiShouJi
//
//  Created by yi cai on 2017/7/19.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJWishDetailViewController.h"
#import "SSJWishPhotoChooseViewController.h"
#import "SSJReminderEditeViewController.h"
#import "TPKeyboardAvoidingtableView.h"

#import "SSJLocalNotificationStore.h"
#import "SSJLocalNotificationHelper.h"
#import "SSJWishHelper.h"

#import "SSJGeTuiManager.h"
#import "SSJDataSynchronizer.h"

#import "SSJCreditCardEditeCell.h"

@interface SSJWishDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;
/**topImg*/
@property (nonatomic, strong) UIImageView *topImg;

/**图片蒙层*/
@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) UIButton *cameraImg;

@property (nonatomic, strong) UILabel *slognL;


@property (nonatomic, strong) UITextField *wishNameTF;

@property (nonatomic, strong) UITextField *wishAmountTF;

// 提醒开关
@property (nonatomic, strong) UISwitch *remindSwitch;

/**save*/
@property (nonatomic, strong) UIView *saveFooterView;

/**<#注释#>*/
@property (nonatomic, strong) SSJReminderItem *reminderItem;

/**<#注释#>*/
@property (nonatomic, strong) NSArray *titlesArr;

/**<#注释#>*/
@property (nonatomic, strong) UIButton *saveBtn;

@end

@implementation SSJWishDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑心愿";
    [self setUpUI];
    [self setUpNav];
    [self normalData];
    [self updateViewConstraints];
    [self appearanceWithTheme];
}

- (void)normalData {
    self.titlesArr = @[@"心愿名称",@"目标金额",@"提醒"];
}

- (void)setUpNav {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"终止" style:UIBarButtonItemStylePlain target:self action:@selector(navRightClick)];
}

- (void)navRightClick {
    
}

- (void)setUpUI {
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.topImg];
    [self.topImg addSubview:self.coverView];
    [self.topImg addSubview:self.slognL];
    [self.topImg addSubview:self.cameraImg];
    
    [self.tableView addSubview:self.wishNameTF];
    [self.tableView addSubview:self.wishAmountTF];
    [self.tableView addSubview:self.remindSwitch];
}

#pragma mark - Layout
- (void)updateViewConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(SSJ_NAVIBAR_BOTTOM);
    }];
    
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];
    
    [self.slognL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.coverView);
        make.width.height.greaterThanOrEqualTo(0);
    }];
    
    [self.cameraImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(15);
    }];

    [super updateViewConstraints];
}

#pragma mark - Theme
- (void)updateAppearanceAfterThemeChanged {
    [super updateAppearanceAfterThemeChanged];
    [self appearanceWithTheme];
}

- (void)appearanceWithTheme {
    self.wishNameTF.textColor = self.wishAmountTF.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    
    self.wishNameTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入心愿" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
    self.wishAmountTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"完成心愿所需金额" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];

    self.tableView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
}

#pragma mark - Private


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

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titlesArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"WishDetailVCCellId";
    SSJCreditCardEditeCell *newReminderCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!newReminderCell) {
        newReminderCell = [[SSJCreditCardEditeCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:cellId];
        newReminderCell.customAccessoryType = UITableViewCellAccessoryNone;
        newReminderCell.selectionStyle = UITableViewCellSelectionStyleNone;
        newReminderCell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    }
    
    NSString *title = [self.titlesArr ssj_safeObjectAtIndex:indexPath.row];
    
    if (indexPath.row == 0) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.cellTitle = title;
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入心愿名称" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        newReminderCell.textInput.text = self.wishModel.wishName;
        newReminderCell.textInput.delegate = self;
        self.wishNameTF = newReminderCell.textInput;
    } else if (indexPath.row == 1) {
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.type = SSJCreditCardCellTypeTextField;
        newReminderCell.cellTitle = title;
        newReminderCell.textInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"完成心愿所需金额" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        newReminderCell.textInput.text = self.wishModel.wishMoney;
        newReminderCell.textInput.delegate = self;
        newReminderCell.textInput.keyboardType = UIKeyboardTypePhonePad;
        self.wishAmountTF = newReminderCell.textInput;
    } else if (indexPath.row == 2) {
        newReminderCell.type = SSJCreditCardCellTypeassertedDetail;
        newReminderCell.cellDetail = [self.reminderItem.remindDate formattedDateWithFormat:@"yyyy-MM-dd"];
        newReminderCell.cellTitle = title;
        self.remindSwitch.on = self.reminderItem.remindState;
        newReminderCell.accessoryView = self.remindSwitch;
        
    }
    
    return newReminderCell;
}

#pragma mark - Lazy

- (TPKeyboardAvoidingTableView *)tableView {
    if (!_tableView) {
        _tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, self.view.height - SSJ_NAVIBAR_BOTTOM) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableHeaderView = self.topImg;
        _tableView.tableFooterView = self.saveFooterView;
        _tableView.rowHeight = 55;
    }
    return _tableView;
}

- (UITextField *)wishNameTF {
    if (!_wishNameTF) {
        _wishNameTF = [[UITextField alloc] init];
        _wishNameTF.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_wishNameTF ssj_setBorderWidth:1/SSJSCREENSCALE];
        [_wishNameTF ssj_setBorderStyle:SSJBorderStyleBottom];
    }
    return _wishNameTF;
}

- (UITextField *)wishAmountTF {
    if (!_wishAmountTF) {
        _wishAmountTF = [[UITextField alloc] init];
        _wishAmountTF.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [_wishAmountTF ssj_setBorderWidth:1/SSJSCREENSCALE];
        [_wishAmountTF ssj_setBorderStyle:SSJBorderStyleBottom];
    }
    return _wishAmountTF;
}

- (UISwitch *)remindSwitch {
    if (!_remindSwitch) {
        _remindSwitch = [[UISwitch alloc] init];
        [_remindSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _remindSwitch;
}

#pragma mark - Action
- (void)switchValueChanged:(UISwitch *)switchc {
    if (!switchc.isOn) return;
    //判断有没有授权
    if ([self remindLocation]) {
        SSJReminderEditeViewController *remindEditeVc = [[SSJReminderEditeViewController alloc]init];
        remindEditeVc.needToSave = YES;
        
        __weak typeof(self) weakSelf = self;
        remindEditeVc.addNewReminderAction = ^(SSJReminderItem *item) {
            weakSelf.remindSwitch.on = YES;
            item.remindType = SSJReminderTypeWish;
            weakSelf.reminderItem = item;
        };
        
        remindEditeVc.notSaveReminderAction = ^{
            weakSelf.remindSwitch.on= NO;
        };
        remindEditeVc.needToSave = YES;
        [self.navigationController pushViewController:remindEditeVc animated:YES];

    }
}

- (UIImageView *)topImg {
    if (!_topImg) {
        _topImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kFinalImgHeight(SSJSCREENWITH))];
        _topImg.userInteractionEnabled = YES;
        _topImg.contentMode = UIViewContentModeScaleToFill;
        _topImg.image = [UIImage imageNamed:self.wishModel.wishImage];
    }
    return _topImg;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [UIColor ssj_colorWithHex:@"000000" alpha:0.7];
    }
    return _coverView;
}

- (UILabel *)slognL {
    if (!_slognL) {
        _slognL = [[UILabel alloc] init];
        _slognL.text = @"许下心愿  为心愿存钱";
        _slognL.font = [UIFont ssj_pingFangMediumFontOfSize:SSJ_FONT_SIZE_1];
        _slognL.textColor = [UIColor whiteColor];
        [_slognL sizeToFit];
    }
    return _slognL;
}

- (UIButton *)cameraImg {
    if (!_cameraImg) {
        _cameraImg = [[UIButton alloc] init];
        [_cameraImg setImage:[UIImage imageNamed:@"wish_bg_camera"] forState:UIControlStateNormal];
        @weakify(self);
        [[_cameraImg rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            SSJWishPhotoChooseViewController *photoVC = [[SSJWishPhotoChooseViewController alloc] init];
            @weakify(self);
            photoVC.changeTopImage = ^(UIImage *seleImg) {
                @strongify(self);
                //切换背景
                self.topImg.image = seleImg;
                [self.navigationController popViewControllerAnimated:YES];
            };
            
            [self.navigationController pushViewController:photoVC animated:YES];
        }];
    }
    return _cameraImg;
}


-(UIView *)saveFooterView {
    if (_saveFooterView == nil) {
        _saveFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 160)];
        UIButton *saveButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, _saveFooterView.width - 20, 40)];
        saveButton.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_2];
        [saveButton setTitle:@"保存" forState:UIControlStateNormal];
        saveButton.layer.cornerRadius = 6.f;
        saveButton.layer.masksToBounds = YES;
        [saveButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
        [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [saveButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor alpha:SSJButtonDisableAlpha] forState:UIControlStateSelected];
        [saveButton ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
        [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [[saveButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            //保存提醒
            if (weakSelf.reminderItem && weakSelf.remindSwitch.isOn) {
                [SSJLocalNotificationStore asyncsaveReminderWithReminderItem:weakSelf.reminderItem Success:^(SSJReminderItem *Ritem){
                    [SSJLocalNotificationHelper registerLocalNotificationWithremindItem:weakSelf.reminderItem];
                    [[SSJDataSynchronizer shareInstance] startSyncIfNeededWithSuccess:NULL failure:NULL];
                } failure:^(NSError *error) {
                    
                }];
                weakSelf.wishModel.remindId = weakSelf.reminderItem.remindId;
            } else {
                weakSelf.wishModel.remindId = @"";
            }
            weakSelf.wishModel.wishName = weakSelf.wishNameTF.text;
            weakSelf.wishModel.wishMoney = weakSelf.wishAmountTF.text;
            //保存愿望详情
            [SSJWishHelper saveWishWithWishModel:weakSelf.wishModel success:^{
                [weakSelf ssj_backOffAction];
            } failure:^(NSError *error) {
                [SSJAlertViewAdapter showError:error];
            }];
            
            
        }];

        saveButton.center = CGPointMake(_saveFooterView.width / 2, _saveFooterView.height / 2);
        RACSignal *signal = [RACSignal combineLatest:@[RACObserve(self, wishNameTF.text),RACObserve(self, wishAmountTF.text)] reduce:^id(NSString *name, NSString *money) {
            return @(name.length && money.length);
        }];
        RAC(saveButton,enabled) = signal;
        [_saveFooterView addSubview:saveButton];
    }
    return _saveFooterView;
}


@end
