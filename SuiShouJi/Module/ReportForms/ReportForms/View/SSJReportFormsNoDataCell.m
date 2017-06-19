//
//  SSJReportFormsNoDataCell.m
//  SuiShouJi
//
//  Created by old lang on 16/12/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJReportFormsNoDataCell.h"
#import "SSJBudgetNodataRemindView.h"

@interface SSJReportFormsNoDataCell ()

@property (nonatomic, strong) SSJBudgetNodataRemindView *noDataRemindView;

@end

@implementation SSJReportFormsNoDataCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.noDataRemindView];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _noDataRemindView.frame = self.contentView.bounds;
}

- (void)updateCellAppearanceAfterThemeChanged {
}

- (void)setCellItem:(SSJBaseCellItem *)cellItem {
    SSJReportFormsNoDataCellItem *item = (SSJReportFormsNoDataCellItem *)cellItem;
    _noDataRemindView.title = item.remindDesc;
}

- (SSJBudgetNodataRemindView *)noDataRemindView {
    if (!_noDataRemindView) {
        _noDataRemindView = [[SSJBudgetNodataRemindView alloc] init];
        _noDataRemindView.image = @"budget_no_data";
    }
    return _noDataRemindView;
}

@end
