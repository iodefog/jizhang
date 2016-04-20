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

@property (nonatomic, strong) UIImageView *photo;

@property (nonatomic, strong) UIImageView *memo;

@end

@implementation SSJBillingChargeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.textLabel.font = [UIFont systemFontOfSize:15];
        self.textLabel.textColor = [UIColor blackColor];
//        self.textLabel.textColor = [UIColor ssj_colorWithHex:@"#a7a7a7"];
        
        self.imageView.contentMode = UIViewContentModeCenter;
        self.imageView.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
        
        _photo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mark_pic"]];
        _photo.size = CGSizeMake(16, 16);
        [self.contentView addSubview:_photo];
        
        _memo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mark_jilu"]];
        _memo.size = CGSizeMake(16, 16);
        [self.contentView addSubview:_memo];
        
//        self.textLabel.layer.borderColor = [UIColor orangeColor].CGColor;
//        self.textLabel.layer.borderWidth = 1;
//        _photo.layer.borderColor = [UIColor redColor].CGColor;
//        _photo.layer.borderWidth = 1;
//        _memo.layer.borderColor = [UIColor redColor].CGColor;
//        _memo.layer.borderWidth = 1;
        
        [self.contentView addSubview:self.moneyLab];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageDiam = 40;
    
    self.imageView.left = 10;
    self.imageView.size = CGSizeMake(imageDiam, imageDiam);
    self.imageView.leftTop = CGPointMake(10, (self.contentView.height - imageDiam) * 0.5);
    self.imageView.layer.cornerRadius = imageDiam * 0.5;
    self.imageView.contentScaleFactor = [UIScreen mainScreen].scale * self.imageView.image.size.width / (imageDiam * 0.75);

    self.moneyLab.right = self.contentView.width - 10;
    self.moneyLab.centerY = self.contentView.height * 0.5;
    
    [self.textLabel sizeToFit];
    self.textLabel.left = self.imageView.right + 10;
    
    if (self.photo.hidden && self.memo.hidden) {
        self.textLabel.left = self.imageView.right + 10;
        self.textLabel.centerY = self.contentView.height * 0.5;
    } else if (self.photo.hidden || self.memo.hidden) {
        CGFloat gap = 10;
        CGFloat top = (self.contentView.height - self.textLabel.height - self.photo.height - gap) * 0.5;
        self.textLabel.top = top;
        UIImageView *displayedView = self.photo.hidden ? self.memo : self.photo;
        displayedView.leftTop = CGPointMake(self.imageView.right + 10, self.textLabel.bottom + gap);
    } else {
        CGFloat gap = 10;
        CGFloat top = (self.contentView.height - self.textLabel.height - self.photo.height - gap) * 0.5;
        self.textLabel.top = top;
        self.photo.leftTop = CGPointMake(self.imageView.right + 10, self.textLabel.bottom + gap);
        self.memo.leftTop = CGPointMake(self.photo.right + 10, self.textLabel.bottom + gap);
    }
}

- (void)setCellItem:(SSJBaseItem *)cellItem {
    [super setCellItem:cellItem];
    if (![cellItem isKindOfClass:[SSJBillingChargeCellItem class]]) {
        return;
    }
    
    SSJBillingChargeCellItem *item = (SSJBillingChargeCellItem *)cellItem;
    
    self.imageView.image = [UIImage imageNamed:item.imageName];
    self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:item.colorValue].CGColor;
    
    self.textLabel.text = item.typeName;
    
    self.moneyLab.text = [NSString stringWithFormat:@"%@%@", item.incomeOrExpence ? @"－" : @"＋", item.money];
    [self.moneyLab sizeToFit];
    
    _photo.hidden = item.chargeImage.length == 0;
    _memo.hidden = item.chargeMemo.length == 0;
    
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
