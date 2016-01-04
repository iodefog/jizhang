//
//  SSJBillingChargeCell.m
//  SuiShouJi
//
//  Created by old lang on 16/1/4.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBillingChargeCell.h"

@interface SSJBillingChargeCell ()

@property (nonatomic, strong) UILabel *moneyLab;

@end

@implementation SSJBillingChargeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.textLabel.font = [UIFont systemFontOfSize:15];
        self.textLabel.textColor = [UIColor ssj_colorWithHex:@"#a7a7a7"];
        [self.contentView addSubview:self.moneyLab];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.left = 10;
    self.textLabel.left = self.imageView.right + 10;
    self.moneyLab.right = self.contentView.width - 10;
    self.imageView.centerY = self.textLabel.centerY = self.moneyLab.centerY = self.contentView.height * 0.5;
}

- (void)setCellItem:(SSJBaseItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJBillingChargeCellItem class]]) {
        return;
    }
    
    SSJBillingChargeCellItem *item = (SSJBillingChargeCellItem *)cellItem;
    self.imageView.image = [UIImage imageNamed:item.imageName];
    self.textLabel.text = item.typeName;
    self.moneyLab.text = item.money;
    [self.textLabel sizeToFit];
    [self.moneyLab sizeToFit];
    [self setNeedsLayout];
}

- (UILabel *)moneyLab {
    if (!_moneyLab) {
        _moneyLab = [[UILabel alloc] init];
        _moneyLab.backgroundColor = [UIColor whiteColor];
        _moneyLab.font = [UIFont systemFontOfSize:20];
    }
    return _moneyLab;
}

@end
