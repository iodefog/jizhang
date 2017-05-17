//
//  SSJBudgetBillTypeSelectionCell.m
//  SuiShouJi
//
//  Created by old lang on 16/9/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBudgetBillTypeSelectionCell.h"

@interface SSJBudgetBillTypeSelectionCell ()

@property (nonatomic, strong) UIImageView *checkMark;

@end

@implementation SSJBudgetBillTypeSelectionCell

- (void)dealloc {
    [self.cellItem removeObserver:self forKeyPath:@"selected"];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        
        _checkMark = [[UIImageView alloc] init];
        [self.contentView addSubview:_checkMark];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.size = CGSizeMake(20, 20);
    [self.textLabel sizeToFit];
    [self.checkMark sizeToFit];
    
    self.imageView.left = 15;
    if (self.imageView.image) {
        self.textLabel.left = self.imageView.right + 15;
    } else {
        self.textLabel.left = 15;
    }
    self.checkMark.right = self.contentView.width - 27;
    self.imageView.centerY = self.textLabel.centerY = self.checkMark.centerY = self.contentView.height * 0.5;
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.selectionStyle = SSJ_CURRENT_THEME.cellSelectionStyle;
}

- (void)setCellItem:(SSJBaseCellItem *)cellItem {
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
    self.selectionStyle = item.canSelect ? SSJ_CURRENT_THEME.cellSelectionStyle : UITableViewCellSelectionStyleNone;
    self.checkMark.image = [UIImage imageNamed:(item.selected ? @"book_sel" : @"book_xuanzhong")];
    self.checkMark.hidden = !item.canSelect;
}

@end
