//
//  SSJLoanListCell.m
//  SuiShouJi
//
//  Created by old lang on 16/8/19.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJLoanListCell.h"

@interface SSJLoanListCell ()

@property (nonatomic, strong) UIImageView *icon;

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UILabel *subtitleLab;

@property (nonatomic, strong) UILabel *moneyLab;

@property (nonatomic, strong) UILabel *dateLab;

@property (nonatomic, strong) UIImageView *stamp;

@end

@implementation SSJLoanListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _stamp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        [self.contentView addSubview:_stamp];
        
        _icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [self.contentView addSubview:_icon];
        
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:14];
        _titleLab.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_titleLab];
        
        _subtitleLab = [[UILabel alloc] init];
        _subtitleLab.font = [UIFont systemFontOfSize:13];
        _subtitleLab.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_subtitleLab];
        
        _moneyLab = [[UILabel alloc] init];
        _moneyLab.font = [UIFont systemFontOfSize:16];
        _moneyLab.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:_moneyLab];
        
        _dateLab = [[UILabel alloc] init];
        _dateLab.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_dateLab];
        
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _stamp.rightTop = CGPointMake(self.contentView.width - 105, 7);
    _icon.leftTop = CGPointMake(22, 12);
    
    [_titleLab sizeToFit];
    _titleLab.leftTop = CGPointMake(64, 22);
    
    [_subtitleLab sizeToFit];
    _subtitleLab.leftTop = CGPointMake(64, 56);
    
    [_moneyLab sizeToFit];
    _moneyLab.rightTop = CGPointMake(self.contentView.width - 18, 20);
    
    [_dateLab sizeToFit];
    _dateLab.rightTop = CGPointMake(self.contentView.width - 18, 56);
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)setCellItem:(SSJBaseItem *)cellItem {
    SSJLoanListCellItem *item = (SSJLoanListCellItem *)cellItem;
    _icon.image = [UIImage imageNamed:item.icon];
    _titleLab.text = item.loanTitle;
    _subtitleLab.text = item.memo;
    _moneyLab.text = item.money;
    _dateLab.text = item.date;
    _stamp.hidden = !item.showStamp;
    [self setNeedsLayout];
}

- (void)updateAppearance {
    _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _subtitleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _moneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _dateLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

@end
