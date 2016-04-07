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
#import "SSJMagicExportResultViewController.h"
#import "SSJMagicExportService.h"
#import "SSJMagicExportStore.h"

@interface SSJMagicExportViewController () <UITextFieldDelegate>

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, strong) UILabel *emailLabel;

@property (nonatomic, strong) SSJMagicExportSelectDateView *selectDateView;

@property (nonatomic, strong) UIView *emailView;

@property (nonatomic, strong) UITextField *emailTextField;

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

@end

@implementation SSJMagicExportViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.navigationItem.title = @"数据导出";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
    // 现隐藏视图，等数据加载出来在显示
    self.scrollView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.service cancel];
}

#pragma mark - SSJBaseNetworkServiceDelegate
- (void)serverDidFinished:(SSJBaseNetworkService *)service {
    [super serverDidFinished:service];
    if ([service.returnCode isEqualToString:@"1"]) {
        SSJMagicExportResultViewController *resultVC = [[SSJMagicExportResultViewController alloc] init];
        resultVC.backController = [self.navigationController.viewControllers firstObject];
        [self.navigationController pushViewController:resultVC animated:YES];
    }
}

#pragma mark - Private
- (void)loadData {
    [self.view ssj_showLoadingIndicator];
    [SSJMagicExportStore queryBillPeriodWithSuccess:^(NSDictionary<NSString *,NSDate *> *result) {
        [self.view ssj_hideLoadingIndicator];
        
        _firstRecordDate = result[SSJMagicExportStoreBeginDateKey];
        _lastRecordDate = result[SSJMagicExportStoreEndDateKey];
        
        if (!_beginDate) {
            _beginDate = _firstRecordDate;
        }
        if (!_endDate) {
            _endDate = _lastRecordDate;
        }
        
        if (_firstRecordDate && _lastRecordDate) {
            self.scrollView.hidden = NO;
            [self updateBeginAndEndButton];
        } else {
            // 没有记账流水
            self.scrollView.hidden = YES;
        }
        
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];
}

- (void)setUpView {
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.dateLabel];
    [self.scrollView addSubview:self.selectDateView];
    [self.scrollView addSubview:self.emailLabel];
    [self.scrollView addSubview:self.emailView];
    [self.scrollView addSubview:self.commitBtn];
    [self.emailView addSubview:self.emailTextField];
}

- (void)updateBeginAndEndButton {
    [self.selectDateView.beginDateBtn setTitle:[self.beginDate formattedDateWithFormat:@"yyyy年M月d日"] forState:UIControlStateNormal];
    [self.selectDateView.endDateBtn setTitle:[self.endDate formattedDateWithFormat:@"yyyy年M月d日"] forState:UIControlStateNormal];
}

#pragma mark - Event
- (void)selectDateAction {
    SSJMagicExportCalendarViewController *calendarVC = [[SSJMagicExportCalendarViewController alloc] init];
    calendarVC.beginDate = _beginDate;
    calendarVC.endDate = _endDate;
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
    
    if (!_service) {
        _service = [[SSJMagicExportService alloc] initWithDelegate:self];
        _service.showLodingIndicator = YES;
    }
//    [_service exportWithBeginDate:self.beginDate endDate:self.endDate emailAddress:self.emailTextField.text];
    
#warning test
    [_service exportWithBeginDate:self.beginDate endDate:self.endDate emailAddress:@"815086764@qq.com"];
}

#pragma mark - Getter
- (TPKeyboardAvoidingScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:self.view.bounds];
    }
    return _scrollView;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 36)];
        _dateLabel.backgroundColor = [UIColor whiteColor];
        _dateLabel.font = [UIFont systemFontOfSize:14];
        _dateLabel.textColor = [UIColor blackColor];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.firstLineHeadIndent = 10;
        _dateLabel.attributedText = [[NSAttributedString alloc] initWithString:@"选择日期" attributes:@{NSParagraphStyleAttributeName:style}];
    }
    return _dateLabel;
}

- (SSJMagicExportSelectDateView *)selectDateView {
    if (!_selectDateView) {
        _selectDateView = [[SSJMagicExportSelectDateView alloc] initWithFrame:CGRectMake(0, self.dateLabel.bottom, self.view.width, 176)];
        [_selectDateView.beginDateBtn addTarget:self action:@selector(selectDateAction) forControlEvents:UIControlEventTouchUpInside];
        [_selectDateView.endDateBtn addTarget:self action:@selector(selectDateAction) forControlEvents:UIControlEventTouchUpInside];
        _selectDateView.beginDate = [NSDate date];
        _selectDateView.endDate = [NSDate date];
    }
    return _selectDateView;
}

- (UILabel *)emailLabel {
    if (!_emailLabel) {
        _emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.selectDateView.bottom, self.view.width, 36)];
        _emailLabel.backgroundColor = [UIColor whiteColor];
        _emailLabel.font = [UIFont systemFontOfSize:14];
        _emailLabel.textColor = [UIColor blackColor];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.firstLineHeadIndent = 10;
        _emailLabel.attributedText = [[NSAttributedString alloc] initWithString:@"邮箱地址" attributes:@{NSParagraphStyleAttributeName:style}];
    }
    return _emailLabel;
}

- (UIView *)emailView {
    if (!_emailView) {
        _emailView = [[UIView alloc] initWithFrame:CGRectMake(0, self.emailLabel.bottom, self.view.width, 88)];
        _emailView.backgroundColor = [UIColor whiteColor];
    }
    return _emailView;
}

- (UITextField *)emailTextField {
    if (!_emailTextField) {
        _emailTextField = [[UITextField alloc] initWithFrame:CGRectInset(self.emailView.bounds, 22, 22)];
        _emailTextField.delegate = self;
        _emailTextField.layer.borderWidth = 1;
        _emailTextField.layer.cornerRadius = 3;
        _emailTextField.layer.borderColor = [UIColor ssj_colorWithHex:@"47cfbe"].CGColor;
        _emailTextField.placeholder = @"请输入邮箱地址";
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, _emailTextField.height)];
        _emailTextField.leftView = leftView;
        _emailTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _emailTextField;
}

- (UIButton *)commitBtn {
    if (!_commitBtn) {
        _commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _commitBtn.layer.cornerRadius = 3;
        _commitBtn.clipsToBounds = YES;
        _commitBtn.frame = CGRectMake(22, self.emailView.bottom + 26, self.view.width - 44, 44);
        _commitBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        [_commitBtn setTitle:@"提交" forState:UIControlStateNormal];
        [_commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_commitBtn ssj_setBackgroundColor:[UIColor ssj_colorWithHex:@"47cfbe"] forState:UIControlStateNormal];
        [_commitBtn addTarget:self action:@selector(commitButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commitBtn;
}

@end
