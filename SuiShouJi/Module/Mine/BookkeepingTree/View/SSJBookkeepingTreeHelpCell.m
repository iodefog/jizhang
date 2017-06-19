//
//  SSJBookkeepingTreeHelpCell.m
//  SuiShouJi
//
//  Created by old lang on 16/4/13.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJBookkeepingTreeHelpCell.h"
#import "SSJBookkeepingTreeHelpCellItem.h"

@interface SSJBookkeepingTreeHelpCell ()

@property (nonatomic, strong) UILabel *daysLab;

@property (nonatomic, strong) UIView *verticalLine;

@end

@implementation SSJBookkeepingTreeHelpCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _daysLab = [[UILabel alloc] init];
        _daysLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _daysLab.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_daysLab];
        
        self.textLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        
        self.imageView.layer.borderColor = SSJ_DEFAULT_SEPARATOR_COLOR.CGColor;
        self.imageView.layer.borderWidth = 1;
        self.imageView.layer.cornerRadius = 2;
        
        _verticalLine = [[UIView alloc] init];
        _verticalLine.backgroundColor = SSJ_DEFAULT_SEPARATOR_COLOR;
        [self.contentView addSubview:_verticalLine];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(SSJ_SCALE_WIDTH(25), 10, 44, 44);
    [self.textLabel sizeToFit];
    self.textLabel.leftTop = CGPointMake(self.imageView.right + SSJ_SCALE_WIDTH(17), (self.contentView.height - self.textLabel.height) * 0.5);
    
    self.daysLab.frame = CGRectMake(self.contentView.width * 0.5, 0, self.contentView.width * 0.5, self.contentView.height);
    self.verticalLine.frame = CGRectMake(self.contentView.width * 0.5, 0, 1 / [UIScreen mainScreen].scale, self.contentView.height);
}

- (void)setCellItem:(SSJBaseCellItem *)cellItem {
    SSJBookkeepingTreeHelpCellItem *item = (SSJBookkeepingTreeHelpCellItem *)cellItem;
    if (![item isKindOfClass:[SSJBookkeepingTreeHelpCellItem class]]) {
        return;
    }
    
    self.imageView.image = [UIImage imageNamed:item.imageName];
    self.textLabel.text = item.treeLevelName;
    self.daysLab.text = item.treeLevelDays;
    [self setNeedsLayout];
}

@end
