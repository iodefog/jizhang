//
//  SSJFixedFinanceDetailTableViewCell.m
//  SuiShouJi
//
//  Created by yi cai on 2017/8/25.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJFixedFinanceDetailTableViewCell.h"
#import "SSJFixedFinanceDetailCellItem.h"
#import "SSJFixedFinanceProductChargeItem.h"

@interface SSJFixedFinanceDetailTableViewCell()

@property (nonatomic, strong) UILabel *timeL;

@property (nonatomic, strong) UILabel *subTitleL;

@end

@implementation SSJFixedFinanceDetailTableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *cellId = @"SSJFixedFinanceDetailTableViewCellId";
    SSJFixedFinanceDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[SSJFixedFinanceDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
        
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.timeL];
        [self.contentView addSubview:self.subTitleL];
        self.textLabel.font = self.detailTextLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([self.cellItem isKindOfClass:[SSJFixedFinanceProductChargeItem class]]) {
        SSJFixedFinanceProductChargeItem *model = self.cellItem;
        [self.imageView sizeToFit];
        if (!model.isHiddenTime) {//显示时间
            self.timeL.left = self.imageView.left = 15;
            self.timeL.top = 15;
            self.timeL.width = self.contentView.width - 30;
            self.timeL.height = 25;
            self.imageView.centerY = 65;
        } else {
            self.imageView.centerY = 25 ;
        }
        
        self.textLabel.centerY = self.detailTextLabel.centerY = self.imageView.centerY;
        self.textLabel.left = CGRectGetMaxX(self.imageView.frame) + 10;
        
        if (model.memo.length) {
            self.subTitleL.frame = CGRectMake(self.textLabel.left, CGRectGetMaxY(self.textLabel.frame), self.contentView.width - self.textLabel.left, 25);
        }
    }
}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    [super setCellItem:cellItem];
    if ([cellItem isKindOfClass:[SSJFixedFinanceProductChargeItem class]]) {
        SSJFixedFinanceProductChargeItem *model = cellItem;
        SSJFixedFinanceDetailCellItem *item = [SSJFixedFinanceDetailCellItem cellItemWithChargeModel:model];
        self.timeL.text = [item.titmeStr ssj_dateStringFromFormat:@"yyyy-MM-dd" toFormat:@"MM月dd日 EEE"];
        self.imageView.image = [UIImage imageNamed:item.iconStr];
        self.textLabel.text = item.nameStr;
        self.subTitleL.text = item.subStr;
        self.detailTextLabel.text = item.amountStr;
        if (model.isHiddenTime) {//隐藏时间
            self.timeL.hidden = YES;
        } else {
            self.timeL.hidden = NO;
        }
        
        if (model.memo.length) {
            self.subTitleL.hidden = NO;
        } else {
            self.subTitleL.hidden = YES;
        }
        
        if (model.memo.length) {
            if (model.isHiddenTime) {
                model.rowHeight = 75;
            } else {
            model.rowHeight = 115;
            }
        } else {
            if (model.isHiddenTime) {
                model.rowHeight = 50;
            } else {
                model.rowHeight = 90;
            }
        }
    }
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)updateAppearance {
    self.textLabel.textColor = self.detailTextLabel.textColor =  [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.timeL.textColor = self.subTitleL.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.imageView.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

#pragma mark - Lazy
- (UILabel *)timeL {
    if (!_timeL) {
        _timeL = [[UILabel alloc] init];
        _timeL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _timeL.contentMode = UIViewContentModeBottomLeft;
    }
    return _timeL;
}

- (UILabel *)subTitleL {
    if (!_subTitleL) {
        _subTitleL = [[UILabel alloc] init];
        _subTitleL.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
    }
    return _subTitleL;
}

@end
