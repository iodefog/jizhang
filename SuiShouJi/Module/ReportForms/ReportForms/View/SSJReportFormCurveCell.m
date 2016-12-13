//
//  SSJReportFormCurveCell.m
//  SuiShouJi
//
//  Created by old lang on 16/12/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormCurveCell.h"
#import "SCYSlidePagingHeaderView.h"
#import "SSJReportFormsCurveGraphView.h"
#import "SSJReportFormsCurveDescriptionView.h"
#import "SSJReportFormsCurveModel.h"

@interface SSJReportFormCurveCell () <SCYSlidePagingHeaderViewDelegate, SSJReportFormsCurveGraphViewDelegate>

//  日、周、月切换控件
@property (nonatomic, strong) SCYSlidePagingHeaderView *timePeriodSegmentControl;

@property (nonatomic, strong) SSJReportFormsCurveGraphView *curveView;

@property (nonatomic, strong) SSJReportFormsCurveDescriptionView *descView;

@property (nonatomic, strong) UIButton *questionBtn;

@end

@implementation SSJReportFormCurveCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.timePeriodSegmentControl];
        [self.contentView addSubview:self.curveView];
        [self.contentView addSubview:self.questionBtn];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _timePeriodSegmentControl.frame = CGRectMake(0, 0, self.contentView.width, 40);
    _curveView.frame = CGRectMake(0, _timePeriodSegmentControl.bottom, self.contentView.width, 330);
    _questionBtn.frame = CGRectMake(8, _curveView.bottom + 5, 30, 30);
}

- (void)setCellItem:(SSJReportFormCurveCellItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJReportFormCurveCellItem class]]) {
        return;
    }
    
    [super setCellItem:cellItem];
    
}

- (SSJReportFormCurveCellItem *)cellItem {
    return (SSJReportFormCurveCellItem *)[super cellItem];
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
}

#pragma mark - SCYSlidePagingHeaderViewDelegate
- (void)slidePagingHeaderView:(SCYSlidePagingHeaderView *)headerView didSelectButtonAtIndex:(NSUInteger)index {
    if (_changeTimePeriodHandle) {
        _changeTimePeriodHandle(self);
    }
    
//    if (_payAndIncomeSegmentControl.selectedIndex == 0) {
//        [MobClick event:@"form_out"];
//    } else if (_payAndIncomeSegmentControl.selectedIndex == 1) {
//        [MobClick event:@"form_in"];
//    } else {
//        
//    }
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

#pragma mark - Event
- (void)questionBtnAction {
    if (_descView.superview) {
        [_descView dismiss];
    } else {
        [_descView showInView:self.contentView atPoint:CGPointMake(_questionBtn.width * 0.5, _questionBtn.bottom)];
    }
}

#pragma mark - Lazy
- (SCYSlidePagingHeaderView *)timePeriodSegmentControl {
    if (!_timePeriodSegmentControl) {
        _timePeriodSegmentControl = [[SCYSlidePagingHeaderView alloc] init];
        _timePeriodSegmentControl.customDelegate = self;
        _timePeriodSegmentControl.buttonClickAnimated = YES;
        [_timePeriodSegmentControl setTabSize:CGSizeMake(_timePeriodSegmentControl.width * 0.3, 3)];
        _timePeriodSegmentControl.titles = @[@"日", @"周", @"月"];
        [_timePeriodSegmentControl ssj_setBorderWidth:1];
        [_timePeriodSegmentControl ssj_setBorderStyle:SSJBorderStyleBottom];
    }
    return _timePeriodSegmentControl;
}

- (SSJReportFormsCurveGraphView *)curveView {
    if (!_curveView) {
        _curveView = [[SSJReportFormsCurveGraphView alloc] init];
        _curveView.delegate = self;
    }
    return _curveView;
}

- (UIButton *)questionBtn {
    if (!_questionBtn) {
        _questionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _questionBtn.hidden = YES;
        [_questionBtn setImage:[UIImage imageNamed:@"reportForms_question"] forState:UIControlStateNormal];
        [_questionBtn addTarget:self action:@selector(questionBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _questionBtn;
}

- (SSJReportFormCurveCellItem *)item {
    return (SSJReportFormCurveCellItem *)self.cellItem;
}

@end
