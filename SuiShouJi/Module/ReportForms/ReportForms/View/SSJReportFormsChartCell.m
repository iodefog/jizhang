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

@interface SSJReportFormsChartCell () <SSJReportFormsPercentCircleDataSource>

@property (nonatomic, strong) SSJPercentCircleView *chartView;

@property (nonatomic, strong) UIButton *categoryBtn;

@property (nonatomic, strong) SSJListMenu *listMenu;

@end

@implementation SSJReportFormsChartCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.chartView];
        [self.contentView addSubview:self.categoryBtn];
        [self updateAppearance];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _chartView.frame = self.contentView.bounds;
    _categoryBtn.size = CGSizeMake(50, 50);
    _categoryBtn.rightTop = CGPointMake(self.contentView.width, 10);
}

#pragma mark - Overwrite
- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)setCellItem:(SSJBaseItem *)cellItem {
    SSJReportFormsChartCellItem *item = (SSJReportFormsChartCellItem *)cellItem;
    if (![item isKindOfClass:[SSJReportFormsChartCellItem class]]) {
        return;
    }
    
    if (![self.chartCellItem isEqualToItem:item]) {
        [super setCellItem:cellItem];
        [_chartView reloadData];
        _chartView.topTitle = self.chartCellItem.amount;
        _chartView.bottomTitle = self.chartCellItem.title;
    }
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

#pragma mark - Private
- (void)updateAppearance {
    _chartView.backgroundColor = [UIColor clearColor];
    [_chartView ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
    _chartView.topTitleAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:16],
                                     NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]};
    _chartView.bottomTitleAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                        NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]};
    
    self.listMenu.normalTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.listMenu.selectedTitleColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    self.listMenu.fillColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryFillColor];
    self.listMenu.separatorColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha];
    self.listMenu.normalImageColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.listMenu.selectedImageColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
}

#pragma mark - Event
- (void)categoryBtnAction {
    [self.listMenu showInView:self atPoint:CGPointMake(CGRectGetMidX(_categoryBtn.frame), CGRectGetMaxY(_categoryBtn.frame) - 10)];
}

- (void)listMenuSelectAction {
    _option = _listMenu.selectedIndex;
    
    switch (_option) {
        case SSJReportFormsMemberAndCategoryOptionCategory:
            [_categoryBtn setImage:[UIImage imageNamed:@"reportForms_category_button"] forState:UIControlStateNormal];
            break;
            
        case SSJReportFormsMemberAndCategoryOptionMember:
            [_categoryBtn setImage:[UIImage imageNamed:@"reportForms_member_button"] forState:UIControlStateNormal];
            break;
    }
    
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
            [_categoryBtn setImage:[UIImage imageNamed:@"reportForms_category_button"] forState:UIControlStateNormal];
            break;
            
        case SSJReportFormsMemberAndCategoryOptionMember:
            self.listMenu.selectedIndex = 1;
            [_categoryBtn setImage:[UIImage imageNamed:@"reportForms_member_button"] forState:UIControlStateNormal];
            break;
    }
}

#pragma mark - Getter
- (SSJPercentCircleView *)chartView {
    if (!_chartView) {
        _chartView = [[SSJPercentCircleView alloc] initWithFrame:CGRectZero insets:UIEdgeInsetsMake(80, 80, 80, 80) thickness:39];
        _chartView.dataSource = self;
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

- (SSJReportFormsChartCellItem *)chartCellItem {
    return (SSJReportFormsChartCellItem *)self.cellItem;
}

@end
