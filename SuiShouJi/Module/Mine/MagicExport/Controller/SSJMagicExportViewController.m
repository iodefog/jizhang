//
//  SSJMagicExportViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/4/1.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMagicExportViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SSJMagicExportSelectDateView.h"
#import "SSJMagicExportCalendarViewController.h"
#import "SSJRecordMakingViewController.h"
#import "SSJMagicExportAnnouncementViewController.h"
#import "SSJBookKeepingHomeViewController.h"
#import "SSJMagicExportService.h"
#import "SSJMagicExportStore.h"
#import "SSJBorderButton.h"
#import "SSJBooksTypeStore.h"
#import "SSJUserTableManager.h"
#import "SSJMagicExportBookTypeSelectionCell.h"
#import "SSJMagicExportSuccessAlertView.h"

@interface SSJMagicExportViewController () <UITextFieldDelegate>


@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

//
@property (nonatomic, strong) UILabel *dateLabel;

//
@property (nonatomic, strong) UILabel *emailLabel;

//
@property (nonatomic, strong) SSJMagicExportSelectDateView *selectDateView;

//
@property (nonatomic, strong) UIView *emailView;

//
@property (nonatomic, strong) UITextField *emailTextField;

//
@property (nonatomic, strong) UIButton *commitBtn;

// 第一次记账时间
@property (nonatomic, strong) NSDate *firstRecordDate;

// 最后一次记账时间
@property (nonatomic, strong) NSDate *lastRecordDate;

// 导出起始时间
@property (nonatomic, strong) NSDate *beginDate;

// 导出结束时间
@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, strong) SSJMagicExportService *service;

@property (nonatomic, strong) UIView *noDataRemindView;

// 公告
@property (nonatomic, strong) UILabel *announcementLab;

@property (nonatomic, strong) SSJUserItem *userItem;

@end

@implementation SSJMagicExportViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.navigationItem.title = @"数据导出";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpView];
    
    // 现隐藏视图，等数据加载出来在显示
    self.announcementLab.hidden = YES;
    self.scrollView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setShadowImage:nil];
    [self loadAllData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.service cancel];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self commitButtonAction];
    return YES;
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    [super serverDidFinished:service];
    if (service == _service && [_service.returnCode isEqualToString:@"1"]) {
        
        _userItem.email = _service.email;
        [SSJUserTableManager saveUserItem:_userItem success:NULL failure:^(NSError * _Nonnull error) {
            [SSJAlertViewAdapter showError:error];
        }];
        
        __weak typeof(self) wself = self;
        [SSJMagicExportSuccessAlertView show:^{
            [wself goBackToHome];
        }];
    }
}

#pragma mark - Private
- (void)loadAllData {
    [self.view ssj_showLoadingIndicator];
    
    @weakify(self);
    [[[self loadUserItemSignal] then:^RACSignal *{
        @strongify(self);
        return [self loadExportPeriodSingal];
    }] subscribeError:^(NSError *error) {
        @strongify(self);
        [self.view ssj_hideLoadingIndicator];
        [SSJAlertViewAdapter showError:error];
    } completed:^{
        @strongify(self);
        [self.view ssj_hideLoadingIndicator];
    }];
}

- (RACSignal *)loadUserItemSignal {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        [SSJUserTableManager queryUserItemWithID:SSJUSERID() success:^(SSJUserItem * _Nonnull userItem) {
            self.userItem = userItem;
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        } failure:^(NSError * _Nonnull error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (RACSignal *)loadExportPeriodSingal {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        [SSJMagicExportStore queryBillPeriodWithBookId:SSJAllBooksIds success:^(NSDictionary<NSString *,NSDate *> *result) {
            self.firstRecordDate = result[SSJMagicExportStoreBeginDateKey];
            self.lastRecordDate = result[SSJMagicExportStoreEndDateKey];
            
            if (!self.beginDate) {
                self.beginDate = self.firstRecordDate;
            }
            if (!self.endDate) {
                self.endDate = self.lastRecordDate;
            }
            
            if (self.firstRecordDate && self.lastRecordDate) {
                self.announcementLab.hidden = NO;
                self.scrollView.hidden = NO;
                [self updateBeginAndEndButton];
                [self.view ssj_hideWatermark:YES];
            } else {
                self.announcementLab.hidden = YES;
                self.scrollView.hidden = YES;
                [self.view ssj_showWatermarkWithCustomView:self.noDataRemindView animated:YES target:nil action:nil];
            }
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        } failure:^(NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (void)setUpView {
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, self.announcementLab.bottom, self.view.width, self.view.height - self.announcementLab.bottom)];
    }
    
    [self.view addSubview:self.announcementLab];
    [self.view addSubview:_scrollView];
    
    [_scrollView addSubview:self.dateLabel];
    [_scrollView addSubview:self.selectDateView];
    [_scrollView addSubview:self.emailLabel];
    [_scrollView addSubview:self.emailView];
    [_scrollView addSubview:self.commitBtn];
    [self.emailView addSubview:self.emailTextField];
    
    _scrollView.contentSize = CGSizeMake(self.scrollView.width, self.commitBtn.bottom + 20);
}

- (void)updateBeginAndEndButton {
    self.selectDateView.beginDate = self.beginDate;
    self.selectDateView.endDate = self.endDate;
}

- (void)goBackToHome {
    UITabBarController *tabVC = (UITabBarController *)self.navigationController.tabBarController;
    if ([tabVC isKindOfClass:[UITabBarController class]]) {
        UINavigationController *homeNavi = [tabVC.viewControllers firstObject];
        if ([homeNavi isKindOfClass:[UINavigationController class]]) {
            SSJBookKeepingHomeViewController *homeVC = [homeNavi.viewControllers firstObject];
            if ([homeVC isKindOfClass:[SSJBookKeepingHomeViewController class]]) {
                tabVC.selectedIndex = 0;
                [self.navigationController popToRootViewControllerAnimated:NO];
            }
        }
    }
}

#pragma mark - Event
- (void)selectDateActionWithBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate {
    SSJMagicExportCalendarViewController *calendarVC = [[SSJMagicExportCalendarViewController alloc] init];
    calendarVC.billType = SSJBillTypeSurplus;
    calendarVC.selectedBeginDate = beginDate;
    calendarVC.selectedEndDate = endDate;
    calendarVC.booksId = SSJAllBooksIds;
    calendarVC.containsOtherMember = YES;
    __weak typeof(self) weakSelf = self;
    calendarVC.completion = ^(NSDate *selectedBeginDate, NSDate *selectedEndDate) {
        weakSelf.beginDate = selectedBeginDate;
        weakSelf.endDate = selectedEndDate;
        [weakSelf updateBeginAndEndButton];
    };
    [self.navigationController pushViewController:calendarVC animated:YES];
}

- (void)commitButtonAction {
    if (!self.emailTextField.text.length) {
        [CDAutoHideMessageHUD showMessage:@"请先输入邮箱地址"];
        return;
    }
    
    if (![self.emailTextField.text ssj_validEmial]) {
        [CDAutoHideMessageHUD showMessage:@"邮件格式不正确"];
        return;
    }
    
    if (!_service) {
        _service = [[SSJMagicExportService alloc] initWithDelegate:self];
        _service.showLodingIndicator = YES;
    }
    [_service exportWithBeginDate:self.beginDate endDate:self.endDate emailAddress:self.emailTextField.text];
}

- (void)recordBtnAction {
    SSJRecordMakingViewController *recordVC = [[SSJRecordMakingViewController alloc] init];
    [self.navigationController pushViewController:recordVC animated:YES];
}

- (void)showAnnouncement {
    SSJMagicExportAnnouncementViewController *announcementVC = [[SSJMagicExportAnnouncementViewController alloc] init];
    [self.navigationController pushViewController:announcementVC animated:YES];
}

#pragma mark - Getter
- (UILabel *)announcementLab {
    if (!_announcementLab) {
        _announcementLab = [[UILabel alloc] initWithFrame:CGRectMake(0, SSJ_NAVIBAR_BOTTOM, self.view.width, 35)];
        _announcementLab.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        _announcementLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
        _announcementLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.firstLineHeadIndent = 10;
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"【公告】关于邮箱收件问题的通知" attributes:@{NSParagraphStyleAttributeName:style}];
        _announcementLab.attributedText = text;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAnnouncement)];
        [_announcementLab addGestureRecognizer:tap];
        _announcementLab.userInteractionEnabled = YES;
    }
    return _announcementLab;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 36)];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
        _dateLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.firstLineHeadIndent = 10;
        _dateLabel.attributedText = [[NSAttributedString alloc] initWithString:@"选择日期" attributes:@{NSParagraphStyleAttributeName:style}];
    }
    return _dateLabel;
}

- (SSJMagicExportSelectDateView *)selectDateView {
    if (!_selectDateView) {
        _selectDateView = [[SSJMagicExportSelectDateView alloc] initWithFrame:CGRectMake(0, self.dateLabel.bottom, self.view.width, 176)];
        __weak typeof(self) weakSelf = self;
        _selectDateView.beginDateAction = ^{
            [weakSelf selectDateActionWithBeginDate:nil endDate:nil];
        };
        _selectDateView.endDateAction = ^{
            [weakSelf selectDateActionWithBeginDate:weakSelf.beginDate endDate:nil];
        };
    }
    return _selectDateView;
}

- (UILabel *)emailLabel {
    if (!_emailLabel) {
        _emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.selectDateView.bottom, self.view.width, 36)];
        _emailLabel.backgroundColor = [UIColor clearColor];
        _emailLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
        _emailLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.firstLineHeadIndent = 10;
        _emailLabel.attributedText = [[NSAttributedString alloc] initWithString:@"邮箱地址" attributes:@{NSParagraphStyleAttributeName:style}];
    }
    return _emailLabel;
}

- (UIView *)emailView {
    if (!_emailView) {
        _emailView = [[UIView alloc] initWithFrame:CGRectMake(0, self.emailLabel.bottom, self.view.width, 88)];
        _emailView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    }
    return _emailView;
}

- (UITextField *)emailTextField {
    if (!_emailTextField) {
        _emailTextField = [[UITextField alloc] initWithFrame:CGRectInset(self.emailView.bounds, 22, 22)];
        _emailTextField.backgroundColor = [UIColor clearColor];
        _emailTextField.delegate = self;
        _emailTextField.layer.borderWidth = 1;
        _emailTextField.layer.cornerRadius = 3;
        _emailTextField.layer.borderColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor].CGColor;
        _emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _emailTextField.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入邮箱地址" attributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]}];
        _emailTextField.text = _userItem.email;
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, _emailTextField.height)];
        _emailTextField.leftView = leftView;
        _emailTextField.leftViewMode = UITextFieldViewModeAlways;
        _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        _emailTextField.returnKeyType = UIReturnKeyDone;
    }
    return _emailTextField;
}

- (UIButton *)commitBtn {
    if (!_commitBtn) {
        _commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _commitBtn.layer.cornerRadius = 3;
        _commitBtn.clipsToBounds = YES;
        _commitBtn.frame = CGRectMake(22, self.emailView.bottom + 26, self.view.width - 44, 44);
        _commitBtn.titleLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1];
        [_commitBtn setTitle:@"提交" forState:UIControlStateNormal];
        [_commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_commitBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:UIControlStateNormal];
        [_commitBtn addTarget:self action:@selector(commitButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commitBtn;
}

- (UIView *)noDataRemindView {
    if (!_noDataRemindView) {
        _noDataRemindView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 146, 230)];
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calendar_norecord"]];
        imgView.centerX = _noDataRemindView.width * 0.5;
        imgView.top = 10;
        [_noDataRemindView addSubview:imgView];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, imgView.bottom + 10, _noDataRemindView.width, 16)];
        lab.backgroundColor = [UIColor clearColor];
        lab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        lab.text = @"您还未有记账数据哦";
        lab.textAlignment = NSTextAlignmentCenter;
        lab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        [_noDataRemindView addSubview:lab];
        
        SSJBorderButton *recordBtn = [[SSJBorderButton alloc] initWithFrame:CGRectMake((_noDataRemindView.width - 120) * 0.5, lab.bottom + 20, 120, 30)];
        recordBtn.fontSize = 15;
        recordBtn.borderWidth = 1;
        recordBtn.cornerRadius = 15;
        [recordBtn setTitle:@"记一笔" forState:SSJBorderButtonStateNormal];
        [recordBtn setTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:SSJBorderButtonStateNormal];
        [recordBtn setTitleColor:[UIColor whiteColor] forState:SSJBorderButtonStateHighlighted];
        [recordBtn setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:SSJBorderButtonStateNormal];
        [recordBtn setBackgroundColor:[UIColor clearColor] forState:SSJBorderButtonStateNormal];
        [recordBtn setBackgroundColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.buttonColor] forState:SSJBorderButtonStateHighlighted];
        [recordBtn addTarget:self action:@selector(recordBtnAction)];
        [_noDataRemindView addSubview:recordBtn];
    }
    return _noDataRemindView;
}

@end
