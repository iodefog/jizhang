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
        
        self.imageView.contentMode = UIViewContentModeCenter;
        self.imageView.layer.borderWidth = 0.5;
        
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
    
    self.textLabel.left = self.imageView.right + 10;

    self.moneyLab.right = self.contentView.width - 10;
    self.moneyLab.centerY = self.contentView.height * 0.5;
}

- (void)setCellItem:(SSJBaseItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJBillingChargeCellItem class]]) {
        return;
    }
    
    SSJBillingChargeCellItem *item = (SSJBillingChargeCellItem *)cellItem;
    
    self.imageView.image = [UIImage imageNamed:item.imageName];
    self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:item.colorValue].CGColor;
    
    self.textLabel.text = item.typeName;
    [self.textLabel sizeToFit];
    
    self.moneyLab.text = [NSString stringWithFormat:@"%@%@", item.incomeOrExpence ? @"－" : @"＋", item.money];
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
