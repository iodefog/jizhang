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
@property(nonatomic, strong) UILabel *memoLabel;
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
        
        [self.contentView addSubview:self.memoLabel];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageDiam = 40;
    
    self.memoLabel.width = 200;
    
    if (_item.chargeMemo.length == 0 && _item.chargeImage.length == 0){
        self.imageView.left = 10;
        self.imageView.size = CGSizeMake(imageDiam, imageDiam);
        self.imageView.leftTop = CGPointMake(10, (self.contentView.height - imageDiam) * 0.5);
        self.imageView.layer.cornerRadius = imageDiam * 0.5;
        self.imageView.contentScaleFactor = [UIScreen mainScreen].scale * self.imageView.image.size.width / (imageDiam * 0.75);
        self.typeLabel.left = self.imageView.right + 10;
        self.typeLabel.centerY = self.height * 0.5;
    }else{
        self.imageView.size = CGSizeMake(imageDiam, imageDiam);
        self.imageView.left = 10;
        self.imageView.layer.cornerRadius = imageDiam * 0.5;
        self.imageView.contentScaleFactor = [UIScreen mainScreen].scale * self.imageView.image.size.width / (imageDiam * 0.75);
        self.haveImage.size = CGSizeMake(19, 19);
        self.memoImage.size = CGSizeMake(19, 19);
        self.typeLabel.left = self.imageView.right + 10;

        if (_item.chargeMemo.length == 0 && _item.chargeImage.length != 0) {
            self.imageView.top = 27;
            self.typeLabel.bottom = self.imageView.centerY - 5;
            self.haveImage.left = self.typeLabel.left;
            self.haveImage.top = self.imageView.centerY + 5;
        }else if (_item.chargeImage.length == 0 && _item.chargeMemo.length != 0){
            self.imageView.top = 27;
            self.typeLabel.bottom = self.imageView.centerY - 5;
            self.memoImage.left = self.typeLabel.left;
            self.memoImage.top = self.imageView.centerY + 5;
            self.memoLabel.leftBottom = CGPointMake(self.memoImage.right + 10, self.memoImage.bottom);
        }else{
            self.imageView.top = 17;
            self.typeLabel.bottom = self.imageView.centerY - 5;
            self.haveImage.left = self.typeLabel.left;
            self.haveImage.top = self.imageView.centerY + 5;
            self.memoImage.left = self.haveImage.left;
            self.memoImage.top = self.haveImage.bottom + 5;
            self.memoLabel.leftBottom = CGPointMake(self.memoImage.right + 10, self.memoImage.bottom);
        }
    }
    self.moneyLab.right = self.contentView.width - 10;
    self.moneyLab.centerY = self.contentView.height * 0.5;
}

- (void)setItem:(SSJBillingChargeCellItem *)item {
    _item = item;
    self.imageView.tintColor = [UIColor ssj_colorWithHex:_item.colorValue];
    self.imageView.image = [[UIImage imageNamed:item.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:item.colorValue].CGColor;
    
    if ([item.typeName isEqualToString:@"平账收入"] || [item.typeName isEqualToString:@"平账支出"]) {
        self.typeLabel.text = [NSString stringWithFormat:@"余额变更(%@)",item.typeName];
    }else{
        self.typeLabel.text = item.typeName;
    }
    [self.typeLabel sizeToFit];
    if (item.chargeMemo.length != 0) {
        self.memoImage.hidden = NO;
        self.memoLabel.hidden = NO;
        self.memoLabel.text = _item.chargeMemo;
        [self.memoLabel sizeToFit];
    }else{
        self.memoImage.hidden = YES;
        self.memoLabel.hidden = NO;
    }
    if (item.chargeImage.length != 0) {
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
        _typeLabel.textColor = [UIColor ssj_colorWithHex:@"#393939"];
    }
    return _typeLabel;
}

-(UILabel *)memoLabel{
    if (!_memoLabel) {
        _memoLabel = [[UILabel alloc]init];
        _memoLabel.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];
        _memoLabel.font = [UIFont systemFontOfSize:13];
    }
    return _memoLabel;
}

@end
