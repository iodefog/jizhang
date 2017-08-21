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
        self.textLabel.font =  [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        self.textLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.checkMark];
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(10, (self.contentView.height - 24) * 0.5, 24, 24);
    if (self.imageView.image) {
        self.textLabel.frame = CGRectMake(self.imageView.right + 10, 0, self.contentView.width - self.imageView.right - 10, self.contentView.height);
    } else {
        self.textLabel.frame = CGRectMake(17, 0, self.contentView.width - self.imageView.right - 10, self.contentView.height);
    }
    self.checkMark.centerY = self.contentView.height * 0.5;
    self.checkMark.right = self.width - 10;
}

- (void)setCellItem:(SSJBaseCellItem *)cellItem {
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
        _checkMark = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    }
    return _checkMark;
}

@end
