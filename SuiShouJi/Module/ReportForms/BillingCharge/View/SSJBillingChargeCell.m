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

@property(nonatomic, strong) UILabel *memoLab;

@end

@implementation SSJBillingChargeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.textLabel.font = [UIFont systemFontOfSize:15];
        self.textLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        
        self.imageView.contentMode = UIViewContentModeCenter;
        self.imageView.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
        
        _photo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mark_pic"]];
        _photo.size = CGSizeMake(16, 16);
        [self.contentView addSubview:_photo];
        
        _memo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mark_jilu"]];
        _memo.size = CGSizeMake(16, 16);
        [self.contentView addSubview:_memo];
        
        [self.contentView addSubview:self.moneyLab];
        [self.contentView addSubview:self.memoLab];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageDiam = 40;
    
    self.imageView.left = 10;
    self.imageView.size = CGSizeMake(imageDiam, imageDiam);
    self.imageView.left = 10;
    self.imageView.layer.cornerRadius = imageDiam * 0.5;
    self.imageView.contentScaleFactor = [UIScreen mainScreen].scale * self.imageView.image.size.width / (imageDiam * 0.75);

    self.moneyLab.right = self.contentView.width - 10;
    self.moneyLab.centerY = self.contentView.height * 0.5;
    
    [self.textLabel sizeToFit];
    self.textLabel.left = self.imageView.right + 10;
    
    if (self.photo.hidden && self.memo.hidden) {
        self.imageView.centerY = self.contentView.height * 0.5;
        self.textLabel.left = self.imageView.right + 10;
        self.textLabel.centerY = self.contentView.height * 0.5;
    } else if (self.photo.hidden || self.memo.hidden) {
        self.imageView.top = 27;
        self.textLabel.bottom = self.imageView.centerY - 5;
        UIImageView *displayedView = self.photo.hidden ? self.memo : self.photo;
        displayedView.leftTop = CGPointMake(self.imageView.right + 10, self.imageView.centerY + 5);
        if (!self.memoLab.hidden) {
            self.memoLab.width = 100;
            self.memoLab.leftBottom = CGPointMake(displayedView.right + 12, displayedView.bottom);
        }
    } else {
        self.imageView.top = 17;
        self.textLabel.bottom = self.imageView.centerY - 5;
        self.photo.leftTop = CGPointMake(self.imageView.right + 10, self.imageView.centerY + 5);
        self.memo.leftTop = CGPointMake(self.photo.left , self.photo.bottom + 10);
        self.memoLab.width = 200;
        self.memoLab.leftBottom = CGPointMake(self.memo.right + 12, self.memo.bottom);
    }
}

- (void)setCellItem:(SSJBaseItem *)cellItem {
    [super setCellItem:cellItem];
    if (![cellItem isKindOfClass:[SSJBillingChargeCellItem class]]) {
        return;
    }
    
    SSJBillingChargeCellItem *item = (SSJBillingChargeCellItem *)cellItem;
    
    self.imageView.image = [[UIImage imageNamed:item.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imageView.tintColor = [UIColor ssj_colorWithHex:item.colorValue];
    self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:item.colorValue].CGColor;
    
    self.textLabel.text = item.typeName;
    
    self.moneyLab.text = [NSString stringWithFormat:@"%@%@", item.incomeOrExpence ? @"－" : @"＋", item.money];
    [self.moneyLab sizeToFit];
    
    _photo.hidden = item.chargeImage.length == 0;
    _memo.hidden = item.chargeMemo.length == 0;
    
    self.memoLab.text = item.chargeMemo;
    [self.memoLab sizeToFit];
    
    [self setNeedsLayout];
}

- (UILabel *)moneyLab {
    if (!_moneyLab) {
        _moneyLab = [[UILabel alloc] init];
        _moneyLab.backgroundColor = [UIColor clearColor];
        _moneyLab.font = [UIFont systemFontOfSize:20];
    }
    return _moneyLab;
}

-(UILabel *)memoLab{
    if (!_memoLab) {
        _memoLab = [[UILabel alloc]init];
        _memoLab.backgroundColor = [UIColor clearColor];
        _memoLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _memoLab.font = [UIFont systemFontOfSize:13];
    }
    return _memoLab;
}

@end
