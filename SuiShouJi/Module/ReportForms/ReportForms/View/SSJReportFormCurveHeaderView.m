//
//  SSJReportFormCurveHeaderView.m
//  SuiShouJi
//
//  Created by old lang on 16/12/14.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormCurveHeaderView.h"
#import "SCYSlidePagingHeaderView.h"
#import "SSJReportFormsCurveGraphView.h"
#import "SSJReportFormsCurveDescriptionView.h"
#import "SSJSeparatorFormView.h"
#import "SSJReportFormsCurveModel.h"

@interface SSJReportFormCurveHeaderView () <SCYSlidePagingHeaderViewDelegate, SSJReportFormsCurveGraphViewDelegate, SSJSeparatorFormViewDataSource>

//  日、周、月切换控件
@property (nonatomic, strong) SCYSlidePagingHeaderView *timePeriodSegmentControl;

@property (nonatomic, strong) SSJReportFormsCurveGraphView *curveView;

@property (nonatomic, strong) SSJReportFormsCurveDescriptionView *descView;

@property (nonatomic, strong) SSJSeparatorFormView *separatorFormView;

@property (nonatomic, strong) UIButton *questionBtn;

@property (nonatomic, strong) UIView *topContainerView;

@property (nonatomic, strong) SSJSeparatorFormViewCellItem *incomeItem;

@property (nonatomic, strong) SSJSeparatorFormViewCellItem *paymentItem;

@property (nonatomic, strong) SSJSeparatorFormViewCellItem *dailyCostItem;

@end

@implementation SSJReportFormCurveHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.topContainerView];
        [self addSubview:self.separatorFormView];
        [self.topContainerView addSubview:self.timePeriodSegmentControl];
        [self.topContainerView addSubview:self.curveView];
        [self.topContainerView addSubview:self.questionBtn];
        [self updateAppearanceAccordingToTheme];
        [self sizeToFit];
    }
    return self;
}

- (void)layoutSubviews {
    _topContainerView.frame = CGRectMake(0, 10, self.width, 410);
    _separatorFormView.frame = CGRectMake(0, _topContainerView.bottom + 10, self.width, 88);
    _timePeriodSegmentControl.frame = CGRectMake(0, 0, self.width, 40);
    [_timePeriodSegmentControl setTabSize:CGSizeMake(_timePeriodSegmentControl.width * 0.33, 2)];
    _curveView.frame = CGRectMake(0, _timePeriodSegmentControl.bottom, self.width, 330);
    [_curveView ssj_relayoutBorder];
    _questionBtn.frame = CGRectMake(8, _curveView.bottom, 30, 30);
}

- (CGSize)sizeThatFits:(CGSize)size {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    return CGSizeMake(window.width, 530);
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    if (index == 0) {
        _item.timeDimension = SSJTimeDimensionDay;
    } else if (index == 1) {
        _item.timeDimension = SSJTimeDimensionWeek;
    } else if (index == 2) {
        _item.timeDimension = SSJTimeDimensionMonth;
    } else {
        SSJPRINT(@"未定义选中下标执行的逻辑");
        return;
    }
    
    if (_changeTimePeriodHandle) {
        _changeTimePeriodHandle(self);
    }
}

#pragma mark - SSJReportFormsCurveGraphViewDelegate
- (NSUInteger)numberOfAxisXInCurveGraphView:(SSJReportFormsCurveGraphView *)graphView {
    return self.item.curveModels.count;
}

- (NSString *)curveGraphView:(SSJReportFormsCurveGraphView *)graphView titleAtAxisXIndex:(NSUInteger)index {
    SSJReportFormsCurveModel *model = [self.item.curveModels ssj_safeObjectAtIndex:index];
    return model.time;
}

- (CGFloat)curveGraphView:(SSJReportFormsCurveGraphView *)graphView paymentValueAtAxisXIndex:(NSUInteger)index {
    SSJReportFormsCurveModel *model = [self.item.curveModels ssj_safeObjectAtIndex:index];
    return [model.payment floatValue];
}

- (CGFloat)curveGraphView:(SSJReportFormsCurveGraphView *)graphView incomeValueAtAxisXIndex:(NSUInteger)index {
    SSJReportFormsCurveModel *model = [self.item.curveModels ssj_safeObjectAtIndex:index];
    return [model.income floatValue];
}

- (void)curveGraphView:(SSJReportFormsCurveGraphView *)graphView didScrollToAxisXIndex:(NSUInteger)index {
    [MobClick event:@"form_curve_move"];
}

#pragma mark - SSJSeparatorFormViewDataSource
- (NSUInteger)numberOfRowsInSeparatorFormView:(SSJSeparatorFormView *)view {
    return 1;
}

- (NSUInteger)separatorFormView:(SSJSeparatorFormView *)view numberOfCellsInRow:(NSUInteger)row {
    return 3;
}

- (SSJSeparatorFormViewCellItem *)separatorFormView:(SSJSeparatorFormView *)view itemForCellAtIndex:(NSIndexPath *)index {
    if (index.row == 0) {
        return _incomeItem;
    } else if (index.row == 1) {
        return _paymentItem;
    } else if (index.row == 2) {
        return _dailyCostItem;
    } else {
        return nil;
    }
}

#pragma mark - Public
- (void)setItem:(SSJReportFormCurveHeaderViewItem *)item {
//    if ([_item isEqualToItem:item]) {
//        return;
//    }
    
    _item = item;
    
    switch (_item.timeDimension) {
        case SSJTimeDimensionDay:
            [_timePeriodSegmentControl setSelectedIndex:0 animated:NO];
            break;
            
        case SSJTimeDimensionWeek:
            [_timePeriodSegmentControl setSelectedIndex:1 animated:NO];
            break;
            
        case SSJTimeDimensionMonth:
            [_timePeriodSegmentControl setSelectedIndex:2 animated:NO];
            break;
    }
    
    [_curveView reloadData];
    
    _incomeItem = [SSJSeparatorFormViewCellItem itemWithTopTitle:_item.generalIncome
                                                     bottomTitle:@"总收入"
                                                   topTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeColor]
                                                bottomTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]
                                                    topTitleFont:[UIFont systemFontOfSize:18]
                                                 bottomTitleFont:[UIFont systemFontOfSize:12]
                                                   contentInsets:UIEdgeInsetsZero];
    
    _paymentItem = [SSJSeparatorFormViewCellItem itemWithTopTitle:_item.generalPayment
                                                      bottomTitle:@"总支出"
                                                    topTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor]
                                                 bottomTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]
                                                     topTitleFont:[UIFont systemFontOfSize:18]
                                                  bottomTitleFont:[UIFont systemFontOfSize:12]
                                                    contentInsets:UIEdgeInsetsZero];
    
    _dailyCostItem = [SSJSeparatorFormViewCellItem itemWithTopTitle:_item.dailyCost
                                                        bottomTitle:@"日均花费（元）"
                                                      topTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]
                                                   bottomTitleColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]
                                                       topTitleFont:[UIFont systemFontOfSize:18]
                                                    bottomTitleFont:[UIFont systemFontOfSize:12]
                                                      contentInsets:UIEdgeInsetsZero];
    [_separatorFormView reloadData];
}

- (void)updateAppearanceAccordingToTheme {
    _topContainerView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    
    _separatorFormView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    _separatorFormView.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    
    _timePeriodSegmentControl.titleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _timePeriodSegmentControl.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    _timePeriodSegmentControl.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    
    [_curveView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    _questionBtn.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    
    _incomeItem.topTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurveIncomeColor];
    _incomeItem.bottomTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _paymentItem.topTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.reportFormsCurvePaymentColor];
    _paymentItem.bottomTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _dailyCostItem.topTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _dailyCostItem.bottomTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

#pragma mark - Event
- (void)questionBtnAction {
    if (_descView.superview) {
        [_descView dismiss];
    } else {
        [_descView showInView:self atPoint:CGPointMake(_questionBtn.width * 0.5, _questionBtn.bottom)];
    }
}

#pragma mark - LazyLoading
- (SCYSlidePagingHeaderView *)timePeriodSegmentControl {
    if (!_timePeriodSegmentControl) {
        _timePeriodSegmentControl = [[SCYSlidePagingHeaderView alloc] init];
        _timePeriodSegmentControl.customDelegate = self;
        _timePeriodSegmentControl.buttonClickAnimated = YES;
        _timePeriodSegmentControl.titles = @[@"日", @"周", @"月"];
    }
    return _timePeriodSegmentControl;
}

- (SSJReportFormsCurveGraphView *)curveView {
    if (!_curveView) {
        _curveView = [[SSJReportFormsCurveGraphView alloc] init];
        [_curveView ssj_setBorderWidth:1];
        [_curveView ssj_setBorderStyle:SSJBorderStyleTop];
        _curveView.delegate = self;
    }
    return _curveView;
}

- (UIButton *)questionBtn {
    if (!_questionBtn) {
        _questionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _questionBtn.hidden = YES;
        [_questionBtn setImage:[[UIImage imageNamed:@"reportForms_question"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_questionBtn addTarget:self action:@selector(questionBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _questionBtn;
}

- (SSJSeparatorFormView *)separatorFormView {
    if (!_separatorFormView) {
        _separatorFormView = [[SSJSeparatorFormView alloc] init];
        _separatorFormView.separatorColor = [UIColor whiteColor];
        _separatorFormView.dataSource = self;
    }
    return _separatorFormView;
}

- (UIView *)topContainerView {
    if (!_topContainerView) {
        _topContainerView = [[UIView alloc] init];
    }
    return _topContainerView;
}

@end
