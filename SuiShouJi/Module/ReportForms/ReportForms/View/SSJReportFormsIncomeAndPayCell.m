//
//  SSJReportFormsIncomeAndPayCell.m
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJReportFormsIncomeAndPayCell.h"
#import "SSJReportFormsItem.h"

@interface SSJReportFormsIncomeAndPayCell ()

@property (nonatomic, strong) UILabel *percentLabel;

@property (nonatomic, strong) UILabel *moneyLabel;

@end

@implementation SSJReportFormsIncomeAndPayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.imageView.contentMode = UIViewContentModeCenter;
        self.imageView.layer.borderWidth = 0.5;
        self.textLabel.font = [UIFont systemFontOfSize:18];
        self.textLabel.textColor = [UIColor ssj_colorWithHex:@"#a7a7a7"];
        [self.contentView addSubview:self.percentLabel];
        [self.contentView addSubview:self.moneyLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageDiam = MAX(self.imageView.image.size.width, self.imageView.image.size.height) + 10;
    
    self.imageView.size = CGSizeMake(imageDiam, imageDiam);
    self.imageView.leftTop = CGPointMake(10, (self.contentView.height - imageDiam) * 0.5);
    self.imageView.layer.cornerRadius = imageDiam * 0.5;
    
    self.textLabel.left = self.imageView.right + 10;
    
    self.percentLabel.centerX = self.width * 0.5;
    self.percentLabel.centerY = self.contentView.height * 0.5;
    
    self.moneyLabel.right = self.contentView.width;
    self.moneyLabel.centerY = self.contentView.height * 0.5;
}

- (void)setCellItem:(SSJBaseItem *)cellItem {
    if (cellItem) {
        SSJReportFormsItem *item = (SSJReportFormsItem *)cellItem;
        
        self.imageView.image = [UIImage imageNamed:item.imageName];
        self.imageView.layer.borderColor = [UIColor ssj_colorWithHex:item.colorValue].CGColor;
        
        self.textLabel.text = item.incomeOrPayName;
        self.percentLabel.text = [NSString stringWithFormat:@"%.1f％",item.scale * 100];
        self.moneyLabel.text = [NSString stringWithFormat:@"%.2f",item.money];
        
        [self.percentLabel sizeToFit];
        [self.moneyLabel sizeToFit];
        
        [self setNeedsLayout];
    }
}

- (UILabel *)percentLabel {
    if (!_percentLabel) {
        _percentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _percentLabel.backgroundColor = [UIColor whiteColor];
        _percentLabel.font = [UIFont systemFontOfSize:18];
        _percentLabel.textColor = [UIColor ssj_colorWithHex:@"#a7a7a7"];
    }
    return _percentLabel;
}

- (UILabel *)moneyLabel {
    if (!_moneyLabel) {
        _moneyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _moneyLabel.backgroundColor = [UIColor whiteColor];
        _moneyLabel.font = [UIFont systemFontOfSize:18];
        _moneyLabel.textColor = [UIColor blackColor];
    }
    return _moneyLabel;
}

@end
