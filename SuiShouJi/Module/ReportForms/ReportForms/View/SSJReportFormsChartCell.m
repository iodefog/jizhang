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

- (void)setCellItem:(SSJBaseCellItem *)cellItem {
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
    _chartView.addtionTextColor = SSJ_SECONDARY_COLOR;
    _chartView.topTitleAttribute = @{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_1],
                                     NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor]};
    _chartView.bottomTitleAttribute = @{NSFontAttributeName:[UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5],
                                        NSForegroundColorAttributeName:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor]};
    
    [self.listMenu updateAppearance];
    for (SSJListMenuItem *item in self.listMenu.items) {
        item.normalTitleColor = SSJ_MAIN_COLOR;
        item.selectedTitleColor = SSJ_MARCATO_COLOR;
        item.normalImageColor = SSJ_SECONDARY_COLOR;
        item.selectedImageColor = SSJ_MARCATO_COLOR;
    }
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
        if (SSJSCREENWITH == 320) {
            _chartView = [[SSJPercentCircleView alloc] initWithFrame:CGRectZero radius:65 thickness:20 lineLength1:10 lineLength2:5];
        } else {
            _chartView = [[SSJPercentCircleView alloc] initWithFrame:CGRectZero radius:80 thickness:20 lineLength1:15 lineLength2:10];
        }
        _chartView.dataSource = self;
        _chartView.backgroundColor = [UIColor clearColor];
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
        _listMenu.items = @[[SSJListMenuItem itemWithImageName:@"reportForms_category"
                                                         title:@"分类"
                                              normalTitleColor:SSJ_MAIN_COLOR
                                            selectedTitleColor:SSJ_MARCATO_COLOR
                                              normalImageColor:SSJ_SECONDARY_COLOR
                                            selectedImageColor:SSJ_MARCATO_COLOR
                                               backgroundColor:SSJ_MAIN_BACKGROUND_COLOR
                                                attributedText:nil],
                            [SSJListMenuItem itemWithImageName:@"reportForms_member"
                                                         title:@"成员"
                                              normalTitleColor:SSJ_MAIN_COLOR
                                            selectedTitleColor:SSJ_MARCATO_COLOR
                                              normalImageColor:SSJ_SECONDARY_COLOR
                                            selectedImageColor:SSJ_MARCATO_COLOR
                                               backgroundColor:SSJ_MAIN_BACKGROUND_COLOR
                                                attributedText:nil]];
        _listMenu.width = 104;
        [_listMenu addTarget:self action:@selector(listMenuSelectAction) forControlEvents:UIControlEventValueChanged];
    }
    return _listMenu;
}

- (SSJReportFormsChartCellItem *)chartCellItem {
    return (SSJReportFormsChartCellItem *)self.cellItem;
}

@end
