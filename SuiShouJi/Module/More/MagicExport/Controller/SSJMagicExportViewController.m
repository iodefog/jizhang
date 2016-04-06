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

@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, strong) UILabel *emailLabel;

@property (nonatomic, strong) SSJMagicExportSelectDateView *selectDateView;

@property (nonatomic, strong) UIView *emailView;

@property (nonatomic, strong) UITextField *emailTextField;

@property (nonatomic, strong) UIButton *commitBtn;

@property (nonatomic, strong) NSDate *beginDate;

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
    
    [self.view ssj_showLoadingIndicator];
    [SSJMagicExportStore queryBillPeriodWithSuccess:^(NSDictionary<NSString *,NSDate *> *result) {
        [self.view ssj_hideLoadingIndicator];
        
        self.beginDate = result[SSJMagicExportStoreBeginDateKey];
        self.endDate = result[SSJMagicExportStoreEndDateKey];
        
        if (self.beginDate && self.endDate) {
            [self setUpView];
            [self updateBeginAndEndDate];
        } else {
            
        }
        
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];
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
        [self.navigationController pushViewController:resultVC animated:YES];
    }
}

#pragma mark - Private
- (void)setUpView {
    TPKeyboardAvoidingScrollView *scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    [scrollView addSubview:self.dateLabel];
    [scrollView addSubview:self.selectDateView];
    [scrollView addSubview:self.emailLabel];
    [scrollView addSubview:self.emailView];
    [self.emailView addSubview:self.emailTextField];
    [scrollView addSubview:self.commitBtn];
}

- (void)updateBeginAndEndDate {
    [self.selectDateView.beginDateBtn setTitle:[self.beginDate formattedDateWithFormat:@"yyyy年M月d日"] forState:UIControlStateNormal];
    [self.selectDateView.endDateBtn setTitle:[self.endDate formattedDateWithFormat:@"yyyy年M月d日"] forState:UIControlStateNormal];
}

#pragma mark - Event
- (void)selectDateAction {
    SSJMagicExportCalendarViewController *calendarVC = [[SSJMagicExportCalendarViewController alloc] init];
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
    [_service exportWithBeginDate:self.beginDate endDate:self.endDate emailAddress:self.emailTextField.text];
}

#pragma mark - Getter
- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 36)];
        _dateLabel.backgroundColor = [UIColor whiteColor];
        _dateLabel.font = [UIFont systemFontOfSize:14];
        _dateLabel.textColor = [UIColor blackColor];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.headIndent = 10;
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
        style.headIndent = 10;
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
    }
    return _emailTextField;
}

- (UIButton *)commitBtn {
    if (!_commitBtn) {
        _commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
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
