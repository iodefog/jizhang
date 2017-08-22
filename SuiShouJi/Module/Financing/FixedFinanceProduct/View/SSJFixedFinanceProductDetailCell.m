//
//  SSJFixedFinanceProductDetailCell.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/22.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceProductDetailCell.h"

@implementation SSJFixedFinanceProductDetailCell
+ (SSJFixedFinanceProductDetailCell *)cellWithTableView:(UITableView *)tableView {
    static NSString *cellId = @"SSJFixedFinanceProductDetailCellId";

    SSJFixedFinanceProductDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SSJFixedFinanceProductDetailCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    return cell;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.amountL.right = self.contentView.width - 15;
    self.amountL.centerY = self.imageView.centerY;
    self.amountL.left = self.textLabel.right;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.amountL];
        self.amountL.font = self.textLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        self.detailTextLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return self;
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    self.textLabel.textColor = SSJ_MAIN_COLOR;
    self.detailTextLabel.textColor = SSJ_SECONDARY_COLOR;
}

- (UILabel *)amountL {
    if (!_amountL) {
        _amountL = [[UILabel alloc] init];
    }
    return _amountL;
}

@end
