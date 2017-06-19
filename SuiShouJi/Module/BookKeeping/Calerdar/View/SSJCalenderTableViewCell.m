//
//  SSJCalenderTableViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCalenderTableViewCell.h"
#import "SSJBillingChargeCellItem.h"

@implementation SSJCalenderTableViewCellItem

@end

@interface SSJCalenderTableViewCell ()

@property (nonatomic, strong) UILabel *moneyLab;

@end

@implementation SSJCalenderTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.textLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        
        self.imageView.contentMode = UIViewContentModeCenter;
        self.imageView.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
        
        [self.contentView addSubview:self.moneyLab];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageDiam = 26;
    
    self.imageView.left = 10;
    self.imageView.size = CGSizeMake(imageDiam, imageDiam);
    self.imageView.leftTop = CGPointMake(10, (self.contentView.height - imageDiam) * 0.5);
    self.imageView.layer.cornerRadius = imageDiam * 0.5;
    self.imageView.contentScaleFactor = [UIScreen mainScreen].scale * self.imageView.image.size.width / (imageDiam * 0.75);
    
    [self.textLabel sizeToFit];
    self.textLabel.left = self.imageView.right + 10;
    self.textLabel.centerY = self.height / 2;
    
    self.moneyLab.right = self.contentView.width - 10;
    self.moneyLab.centerY = self.contentView.height * 0.5;
}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
    
    if (![cellItem isKindOfClass:[SSJCalenderTableViewCellItem class]]) {
        return;
    }
    
    SSJCalenderTableViewCellItem *item = cellItem;
    self.imageView.image = item.billImage;
    self.imageView.tintColor = item.billColor;
    self.imageView.layer.borderColor = item.billColor.CGColor;
    self.textLabel.text = item.billName;
    [self.textLabel sizeToFit];
    double money = [item.money doubleValue];
    self.moneyLab.text = [NSString stringWithFormat:@"%.2f", money];
    [self.moneyLab sizeToFit];
    [self setNeedsLayout];
}

- (UILabel *)moneyLab {
    if (!_moneyLab) {
        _moneyLab = [[UILabel alloc] init];
        _moneyLab.backgroundColor = [UIColor clearColor];
        _moneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _moneyLab.font = [UIFont ssj_helveticaRegularFontOfSize:SSJ_FONT_SIZE_1];
    }
    return _moneyLab;
}

@end
