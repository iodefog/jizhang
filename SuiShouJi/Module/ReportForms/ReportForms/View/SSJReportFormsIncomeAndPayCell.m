//
//  SSJReportFormsIncomeAndPayCell.m
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJReportFormsIncomeAndPayCell.h"
#import "SSJReportFormsItem.h"

static const CGFloat imageDiam = 26;

@interface SSJReportFormsIncomeAndPayCell ()

@property (nonatomic, strong) UILabel *percentLabel;

@property (nonatomic, strong) UILabel *moneyLabel;

@property (nonatomic, strong) UILabel *memberNameLabel;

@end

@implementation SSJReportFormsIncomeAndPayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.customAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        self.imageView.contentMode = UIViewContentModeCenter;
        self.imageView.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
        
        self.textLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        self.textLabel.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.memberNameLabel];
        [self.contentView addSubview:self.percentLabel];
        [self.contentView addSubview:self.moneyLabel];
        
        self.textLabel.textColor = _percentLabel.textColor = _moneyLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.size = CGSizeMake(imageDiam, imageDiam);
    self.imageView.leftTop = CGPointMake(10, (self.contentView.height - imageDiam) * 0.5);
    self.imageView.layer.cornerRadius = imageDiam * 0.5;
    self.imageView.contentScaleFactor = [UIScreen mainScreen].scale * self.imageView.image.size.width / (imageDiam * 0.75);
    
    self.memberNameLabel.leftTop = CGPointMake(10, (self.contentView.height - imageDiam) * 0.5);
    
    if (self.percentLabel.hidden) {
        [self.textLabel sizeToFit];
        self.textLabel.left = 46;
        self.textLabel.centerY = self.contentView.height * 0.5;
        
        [self.moneyLabel sizeToFit];
        self.moneyLabel.left = self.textLabel.right + 10;
        self.moneyLabel.width = self.contentView.width - self.moneyLabel.left;
        self.moneyLabel.centerY = self.contentView.height * 0.5;
    } else {
        [self.percentLabel sizeToFit];
        self.percentLabel.centerX = self.width * 0.5;
        self.percentLabel.centerY = self.contentView.height * 0.5;
        
        [self.textLabel sizeToFit];
        self.textLabel.left = 46;
        self.textLabel.width = self.percentLabel.left - self.textLabel.left - 10;
        self.textLabel.centerY = self.contentView.height * 0.5;
        
        [self.moneyLabel sizeToFit];
        self.moneyLabel.left = self.percentLabel.right + 10;
        self.moneyLabel.width = self.contentView.width - self.moneyLabel.left;
        self.moneyLabel.centerY = self.contentView.height * 0.5;
    }
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    self.textLabel.textColor = _percentLabel.textColor = _moneyLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
}

- (void)setCellItem:(SSJBaseCellItem *)cellItem {
    if (cellItem) {
        SSJReportFormsItem *item = (SSJReportFormsItem *)cellItem;
        
        if (item.isMember) {
            self.imageView.hidden = YES;
            self.memberNameLabel.hidden = NO;
            self.memberNameLabel.text = item.name.length >= 1 ? [item.name substringToIndex:1] : @"";
            self.memberNameLabel.layer.borderColor = [UIColor ssj_colorWithHex:item.colorValue].CGColor;
            self.memberNameLabel.textColor = [UIColor ssj_colorWithHex:item.colorValue];
        } else {
            self.imageView.hidden = NO;
            self.memberNameLabel.hidden = YES;
            self.imageView.image = [[UIImage imageNamed:item.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.imageView.tintColor = [UIColor ssj_colorWithHex:item.colorValue];
            self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:item.colorValue].CGColor;
        }
        
        self.textLabel.text = item.name;
        self.percentLabel.text = [NSString stringWithFormat:@"%.1f％",item.scale * 100];
        self.moneyLabel.text = [NSString stringWithFormat:@"%.2f",item.money];
        
        self.percentLabel.hidden = item.percentHiden;
        
        [self setNeedsLayout];
    }
}

- (UILabel *)percentLabel {
    if (!_percentLabel) {
        _percentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _percentLabel.backgroundColor = [UIColor clearColor];
        _percentLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
    }
    return _percentLabel;
}

- (UILabel *)moneyLabel {
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _moneyLabel.backgroundColor = [UIColor clearColor];
        _moneyLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _moneyLabel.textAlignment = NSTextAlignmentRight;
    }
    return _moneyLabel;
}

- (UILabel *)memberNameLabel {
    if (!_memberNameLabel) {
        _memberNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, imageDiam, imageDiam)];
        _memberNameLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
        _memberNameLabel.textAlignment = NSTextAlignmentCenter;
        _memberNameLabel.layer.borderWidth = 1 / [UIScreen mainScreen].scale;
        _memberNameLabel.layer.cornerRadius = imageDiam * 0.5;
    }
    return _memberNameLabel;
}

@end
