//
//  SSJFundingDetailCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/20.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJFundingDetailCell.h"
#import "SSJBillingChargeCellItem.h"

@interface SSJFundingDetailCell()

@property (nonatomic, strong) UILabel *moneyLab;
@property(nonatomic, strong) UIImageView *memoImage;
@property(nonatomic, strong) UIImageView *haveImage;
@property(nonatomic, strong) UILabel *typeLabel;
@end

@implementation SSJFundingDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.imageView.contentMode = UIViewContentModeCenter;
        self.imageView.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
    
        self.textLabel.textColor = [UIColor blackColor];
        
        
        [self.contentView addSubview:self.moneyLab];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.typeLabel];
        
        [self.contentView addSubview:self.haveImage];
        
        [self.contentView addSubview:self.memoImage];

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
    if (([_item.chargeMemo isEqualToString:@""] || _item.chargeMemo == nil) && ([_item.chargeImage isEqualToString:@""] || _item.chargeImage == nil)){
        self.typeLabel.left = self.imageView.right + 10;
        self.typeLabel.centerY = self.height * 0.5;
    }else{
        self.haveImage.size = CGSizeMake(19, 19);
        self.memoImage.size = CGSizeMake(19, 19);
        self.typeLabel.left = self.imageView.right + 10;
        self.typeLabel.bottom = self.height * 0.5 - 5;
        if (([_item.chargeMemo isEqualToString:@""] || _item.chargeMemo == nil) && (![_item.chargeImage isEqualToString:@""] && _item.chargeImage != nil)) {
            self.haveImage.left = self.typeLabel.left;
            self.haveImage.top = self.contentView.height * 0.5 + 5;
        }else if (([_item.chargeImage isEqualToString:@""] || _item.chargeImage == nil) && (![_item.chargeMemo isEqualToString:@""] && _item.chargeMemo != nil)){
            self.memoImage.left = self.typeLabel.left;
            self.memoImage.top = self.contentView.height * 0.5 + 5;
        }else{
            self.haveImage.left = self.typeLabel.left;
            self.haveImage.top = self.contentView.height * 0.5 + 5;
            self.memoImage.left = self.haveImage.right + 10;
            self.memoImage.top = self.contentView.height * 0.5 + 5;
        }
    }
    self.moneyLab.right = self.contentView.width - 10;
    self.moneyLab.centerY = self.contentView.height * 0.5;
}

- (void)setItem:(SSJBillingChargeCellItem *)item {
    _item = item;
    self.imageView.image = [UIImage imageNamed:item.imageName];
    self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:item.colorValue].CGColor;
    
    if ([item.typeName isEqualToString:@"平账收入"] || [item.typeName isEqualToString:@"平账支出"]) {
        self.typeLabel.text = [NSString stringWithFormat:@"余额变更(%@)",item.typeName];
    }else{
        self.typeLabel.text = item.typeName;
    }
    [self.typeLabel sizeToFit];
    if (![item.chargeMemo isEqualToString:@""] && item.chargeMemo != nil) {
        self.memoImage.hidden = NO;
    }else{
        self.memoImage.hidden = YES;
    }
    if (![item.chargeImage isEqualToString:@""] && item.chargeImage != nil) {
        self.haveImage.hidden = NO;
    }else{
        self.haveImage.hidden = YES;
    }
    [self.textLabel sizeToFit];
    
    self.moneyLab.text = [NSString stringWithFormat:@"%@",item.money];
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

-(UIImageView *)memoImage{
    if (!_memoImage) {
        _memoImage = [[UIImageView alloc]init];
        _memoImage.image = [UIImage imageNamed:@"mark_jilu"];
    }
    return _memoImage;
}

-(UIImageView *)haveImage{
    if (!_haveImage) {
        _haveImage = [[UIImageView alloc]init];
        _haveImage.image = [UIImage imageNamed:@"mark_pic"];
    }
    return _haveImage;
}

-(UILabel *)typeLabel{
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc]init];
        _typeLabel.font = [UIFont systemFontOfSize:15];
        _typeLabel.textColor = [UIColor ssj_colorWithHex:@"#a7a7a7"];
    }
    return _typeLabel;
}

@end
