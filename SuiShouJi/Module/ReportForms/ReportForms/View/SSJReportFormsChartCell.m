//
//  SSJReportFormsChartCell.m
//  SuiShouJi
//
//  Created by old lang on 16/12/9.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsChartCell.h"
#import "SSJPercentCircleView.h"
#import "SSJListMenu.h"

@interface SSJReportFormsChartCell ()

@property (nonatomic, strong) SSJPercentCircleView *chartView;

@property (nonatomic, strong) UIButton *categoryBtn;

@property (nonatomic, strong) SSJListMenu *listMenu;

//  圆环中间顶部的总收入、总支出
@property (nonatomic, strong) UILabel *incomeAndPaymentTitleLab;

//  圆环中间顶部的总收入、总支出金额
@property (nonatomic, strong) UILabel *incomeAndPaymentMoneyLab;

@end

@implementation SSJReportFormsChartCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.chartView];
        [self.contentView addSubview:self.categoryBtn];
        [self.contentView addSubview:self.incomeAndPaymentTitleLab];
        [self.contentView addSubview:self.incomeAndPaymentMoneyLab];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _chartView.frame = self.contentView.bounds;
    _categoryBtn.size = CGSizeMake(50, 50);
    _categoryBtn.center = CGPointMake(self.contentView.width * 0.9, 0.12);
    
    CGRect hollowFrame = UIEdgeInsetsInsetRect(self.chartView.circleFrame, UIEdgeInsetsMake(self.chartView.circleThickness, self.chartView.circleThickness, self.chartView.circleThickness, self.chartView.circleThickness));
    _incomeAndPaymentTitleLab.frame = CGRectMake(hollowFrame.origin.x, (hollowFrame.size.height - 38) * 0.5 + hollowFrame.origin.y, hollowFrame.size.width, 15);
    _incomeAndPaymentMoneyLab.frame = CGRectMake(hollowFrame.origin.x, (hollowFrame.size.height - 38) * 0.5 + hollowFrame.origin.y + 20, hollowFrame.size.width, 18);
}

#pragma mark - SSJReportFormsPercentCircleDataSource
- (NSUInteger)numberOfComponentsInPercentCircle:(SSJPercentCircleView *)circle {
    return self.chartCellItem.chartItems.count;
}

- (SSJPercentCircleViewItem *)percentCircle:(SSJPercentCircleView *)circle itemForComponentAtIndex:(NSUInteger)index {
    if (index < self.chartCellItem.chartItems.count) {
        return self.chartCellItem.chartItems[index];
    }
    return nil;
}

#pragma mark - Overwrite
- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    
    _chartView.contentView.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    [_chartView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    
    _incomeAndPaymentTitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _incomeAndPaymentMoneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
}

- (void)setCellItem:(SSJBaseItem *)cellItem {
    SSJReportFormsChartCellItem *item = (SSJReportFormsChartCellItem *)cellItem;
    if (![item isKindOfClass:[SSJReportFormsChartCellItem class]]) {
        return;
    }
    
    if (![self.chartCellItem isEqualToItem:item]) {
        [super setCellItem:cellItem];
        [_chartView reloadData];
        _incomeAndPaymentTitleLab.text = self.chartCellItem.title;
        _incomeAndPaymentMoneyLab.text = self.chartCellItem.amount;
    }
}

- (SSJReportFormsChartCellItem *)chartCellItem {
    return (SSJReportFormsChartCellItem *)self.cellItem;
}

#pragma mark - Event
- (void)categoryBtnAction {
    [self.listMenu showInView:self atPoint:CGPointMake(CGRectGetMidX(_categoryBtn.frame), CGRectGetMaxY(_categoryBtn.frame))];
}

- (void)listMenuSelectAction {
    _option = _listMenu.selectedIndex;
    if (_selectOptionHandle) {
        _selectOptionHandle(self);
    }
}

#pragma mark - Public
- (void)setOption:(SSJReportFormsMemberAndCategoryOption)option {
    _option = option;
    switch (_option) {
        case SSJReportFormsMemberAndCategoryOptionCategory:
            self.listMenu.selectedIndex = 0;
            break;
            
        case SSJReportFormsMemberAndCategoryOptionMember:
            self.listMenu.selectedIndex = 1;
            break;
    }
}

#pragma mark - Getter
- (SSJPercentCircleView *)chartView {
    if (!_chartView) {
        _chartView = [[SSJPercentCircleView alloc] initWithFrame:CGRectZero insets:UIEdgeInsetsMake(80, 80, 80, 80) thickness:39];
        [_chartView ssj_setBorderStyle:SSJBorderStyleBottom];
        [_chartView ssj_setBorderWidth:1];
    }
    return _chartView;
}

- (UIButton *)categoryBtn {
    if (!_categoryBtn) {
        _categoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_categoryBtn addTarget:self action:@selector(categoryBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _categoryBtn;
}

- (SSJListMenu *)listMenu {
    if (!_listMenu) {
        _listMenu = [[SSJListMenu alloc] init];
        _listMenu.items = @[[SSJListMenuItem itemWithImageName:@"reportForms_category" title:@"分类"],
                            [SSJListMenuItem itemWithImageName:@"reportForms_member" title:@"成员"]];
        _listMenu.width = 104;
        [_listMenu addTarget:self action:@selector(listMenuSelectAction) forControlEvents:UIControlEventValueChanged];
    }
    return _listMenu;
}

- (UILabel *)incomeAndPaymentTitleLab {
    if (!_incomeAndPaymentTitleLab) {
        _incomeAndPaymentTitleLab = [[UILabel alloc] init];
        _incomeAndPaymentTitleLab.backgroundColor = [UIColor clearColor];
        _incomeAndPaymentTitleLab.font = [UIFont systemFontOfSize:15];
        _incomeAndPaymentTitleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _incomeAndPaymentTitleLab;
}

- (UILabel *)incomeAndPaymentMoneyLab {
    if (!_incomeAndPaymentMoneyLab) {
        _incomeAndPaymentMoneyLab = [[UILabel alloc] init];
        _incomeAndPaymentMoneyLab.backgroundColor = [UIColor clearColor];
        _incomeAndPaymentMoneyLab.font = [UIFont systemFontOfSize:18];
        _incomeAndPaymentMoneyLab.minimumScaleFactor = 0.66;
        _incomeAndPaymentMoneyLab.adjustsFontSizeToFitWidth = YES;
        _incomeAndPaymentMoneyLab.textAlignment = NSTextAlignmentCenter;
    }
    return _incomeAndPaymentMoneyLab;
}

@end
