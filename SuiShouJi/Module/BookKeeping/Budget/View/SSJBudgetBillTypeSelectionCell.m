//
//  SSJBudgetBillTypeSelectionCell.m
//  SuiShouJi
//
//  Created by old lang on 16/9/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetBillTypeSelectionCell.h"

@implementation SSJBudgetBillTypeSelectionCell

- (void)dealloc {
    [self.cellItem removeObserver:self forKeyPath:@"selected"];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textLabel.font = [UIFont systemFontOfSize:18];
        self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        self.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.imageView sizeToFit];
    [self.textLabel sizeToFit];
    
    self.imageView.left = 15;
    self.textLabel.left = self.imageView.right + 15;
    self.imageView.centerY = self.textLabel.centerY = self.contentView.height * 0.5;
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
}

- (void)setCellItem:(SSJBaseItem *)cellItem {
    [self.cellItem removeObserver:self forKeyPath:@"selected"];
    [super setCellItem:cellItem];
    [self.cellItem addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:NULL];
    [self updateAppearance];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context {
    if (object == self.cellItem) {
        [self updateAppearance];
    }
}

- (void)updateAppearance {
    SSJBudgetBillTypeSelectionCellItem *item = (SSJBudgetBillTypeSelectionCellItem *)self.cellItem;
    self.imageView.image = [[UIImage imageNamed:item.leftImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imageView.tintColor = [UIColor ssj_colorWithHex:item.billTypeColor];
    self.textLabel.text = item.billTypeName;
}

@end
