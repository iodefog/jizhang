//
//  SSJReportFormsCurveViewController.m
//  SuiShouJi
//
//  Created by old lang on 16/6/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsCurveViewController.h"
#import "SSJSegmentedControl.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "SSJReportFormsCurveGraphView.h"
#import "SSJReportFormsCurveModel.h"
#import "SSJReportFormsUtil.h"

@interface SSJReportFormsCurveViewController () <SSJReportFormsCurveGraphViewDelegate>

@property (nonatomic, strong) SSJSegmentedControl *segmentControl;

@property (nonatomic, strong) TPKeyboardAvoidingScrollView *scrollView;

@property (nonatomic, strong) UILabel *periodLabel;

@property (nonatomic, strong) SSJReportFormsCurveGraphView *curveView;

@property (nonatomic, strong) NSArray *datas;

@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, strong) NSDate *endDate;

@end

@implementation SSJReportFormsCurveViewController

#pragma mark - Lifecycle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.titleView = self.segmentControl;
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.periodLabel];
    [self.scrollView addSubview:self.curveView];
    
    [self reloadData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.scrollView.frame = self.view.bounds;
}

- (void)reloadData {
    [self.view ssj_showLoadingIndicator];
    [SSJReportFormsUtil queryForBillStatisticsWithType:(int)_segmentControl.selectedSegmentIndex startDate:_startDate endDate:_endDate success:^(NSArray<SSJReportFormsCurveModel *> *result) {
        [self.view ssj_hideLoadingIndicator];
        _datas = result;
        [_curveView reloadData];
        if (_datas.count >= 4) {
            [_curveView scrollToAxisXAtIndex:_datas.count - 4 animated:NO];
        }
    } failure:^(NSError *error) {
        [self.view ssj_hideLoadingIndicator];
        [CDAutoHideMessageHUD showMessage:SSJ_ERROR_MESSAGE];
    }];
}

#pragma mark - SSJReportFormsCurveGraphViewDelegate
- (NSUInteger)numberOfAxisXInCurveGraphView:(SSJReportFormsCurveGraphView *)graphView {
    return _datas.count;
}

- (NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView titleAtAxisXIndex:(NSUInteger)index {
    SSJReportFormsCurveModel *model = [_datas ssj_safeObjectAtIndex:index];
    return model.time;
}

- (CGFloat)curveGraphView:(SSJReportFormsCurveGraphView *)graphView paymentValueAtAxisXIndex:(NSUInteger)index {
    SSJReportFormsCurveModel *model = [_datas ssj_safeObjectAtIndex:index];
    return [model.payment floatValue];
}

- (CGFloat)curveGraphView:(SSJReportFormsCurveGraphView *)graphView incomeValueAtAxisXIndex:(NSUInteger)index {
    SSJReportFormsCurveModel *model = [_datas ssj_safeObjectAtIndex:index];
    return [model.income floatValue];
}

- (void)curveGraphView:(SSJReportFormsCurveGraphView *)graphView didScrollToAxisXIndex:(NSUInteger)index {
    
}

#pragma mark - Event
- (void)segmentControlValueDidChange {
    [self reloadData];
}

#pragma mark - Getter
- (SSJSegmentedControl *)segmentControl {
    if (!_segmentControl) {
        _segmentControl = [[SSJSegmentedControl alloc] initWithItems:@[@"月", @"周"]];
        _segmentControl.size = CGSizeMake(150, 30);
        _segmentControl.font = [UIFont systemFontOfSize:15];
        _segmentControl.borderColor = [UIColor ssj_colorWithHex:@"#cccccc"];
        _segmentControl.selectedBorderColor = [UIColor ssj_colorWithHex:@"#eb4a64"];
        [_segmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:@"#eb4a64"]} forState:UIControlStateSelected];
        [_segmentControl addTarget:self action:@selector(segmentControlValueDidChange) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentControl;
}

- (TPKeyboardAvoidingScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[TPKeyboardAvoidingScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor ssj_colorWithHex:@"F6F6F6"];
    }
    return _scrollView;
}

- (UILabel *)periodLabel {
    if (!_periodLabel) {
        _periodLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 30)];
        _periodLabel.textAlignment = NSTextAlignmentCenter;
        _periodLabel.font = [UIFont systemFontOfSize:15];
    }
    return _periodLabel;
}

- (SSJReportFormsCurveGraphView *)curveView {
    if (!_curveView) {
        _curveView = [[SSJReportFormsCurveGraphView alloc] initWithFrame:CGRectMake(0, 32, self.view.width, 384)];
        _curveView.delegate = self;
    }
    return _curveView;
}

@end
