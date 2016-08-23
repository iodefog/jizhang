//
//  SSJLoanFundAccountSelectionCell.m
//  SuiShouJi
//
//  Created by old lang on 16/8/23.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanFundAccountSelectionCell.h"
#import "SSJLoanFundAccountSelectionCellItem.h"

@interface SSJLoanFundAccountSelectionCell ()

@property (nonatomic,strong) UIImageView *checkMark;

@end

@implementation SSJLoanFundAccountSelectionCell

- (void)dealloc {
    [self.cellItem removeObserver:self forKeyPath:@"showCheckMark"];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textLabel.font = [UIFont systemFontOfSize:15];
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(10, (self.contentView.height - 24) * 0.5, 24, 24);
    self.textLabel.frame = CGRectMake(self.imageView.right + 10, 0, self.contentView.width - self.imageView.right - 10, self.contentView.height);
}

- (void)setCellItem:(SSJBaseItem *)cellItem {
    [self.cellItem removeObserver:self forKeyPath:@"showCheckMark"];
    
    [super setCellItem:cellItem];
    
    [self.cellItem addObserver:self forKeyPath:@"showCheckMark" options:NSKeyValueObservingOptionNew context:NULL];
    
    SSJLoanFundAccountSelectionCellItem *item = (SSJLoanFundAccountSelectionCellItem *)self.cellItem;
    self.imageView.image = [UIImage imageNamed:item.image];
    self.textLabel.text = item.title;
    self.checkMark.hidden = !item.showCheckMark;
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _checkMark.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    if ([keyPath isEqualToString:@"showCheckMark"] && object == self.cellItem) {
        self.checkMark.hidden = !((SSJLoanFundAccountSelectionCellItem *)self.cellItem).showCheckMark;
    }
}

-(UIImageView *)checkMark {
    if (!_checkMark) {
        _checkMark = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 17, 17)];
        _checkMark.image = [[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _checkMark.hidden = YES;
    }
    return _checkMark;
}

@end
