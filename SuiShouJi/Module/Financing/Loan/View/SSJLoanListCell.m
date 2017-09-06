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

@property (nonatomic, strong) UILabel *memoLab;

@property (nonatomic, strong) UILabel *moneyLab;

@property (nonatomic, strong) UILabel *dateLab;

@property (nonatomic, strong) UIImageView *stamp;

/**stateLabel*/
@property (nonatomic, strong) UILabel *stateLabel;

@end

@implementation SSJLoanListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.stateLabel];
        _stamp = [[UIImageView alloc] initWithImage:[UIImage ssj_themeImageWithName:@"loan_stamp"]];
        _stamp.size = CGSizeMake(72, 72);
//        _stamp.alpha = 0.4;
        [self.contentView addSubview:_stamp];
        
        _icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [self.contentView addSubview:_icon];
        
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_7];
        [self.contentView addSubview:_titleLab];
        
        _memoLab = [[UILabel alloc] init];
        _memoLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [self.contentView addSubview:_memoLab];
        
        _moneyLab = [[UILabel alloc] init];
        _moneyLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        [self.contentView addSubview:_moneyLab];
        
        _dateLab = [[UILabel alloc] init];
        _dateLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        [self.contentView addSubview:_dateLab];
//        [self.contentView clipsToBounds];
        
        [self updateAppearance];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat maxWidth = (self.contentView.width - 64 - 20 - 10) * 0.5;
    
    _stamp.rightTop = CGPointMake(self.contentView.width - 105, 7);
    
    if (_memoLab.text.length) {
        _icon.leftTop = CGPointMake(22, 15);
        
        [_titleLab sizeToFit];
        _titleLab.width = MIN(maxWidth, _titleLab.width);
        _titleLab.leftTop = CGPointMake(64, 22);
        
        [_memoLab sizeToFit];
        _memoLab.leftTop = CGPointMake(64, 56);
    } else {
        _icon.left = 22;
        _icon.centerY = self.contentView.height * 0.5;
        
        [_titleLab sizeToFit];
        _titleLab.width = MIN(maxWidth, _titleLab.width);
        _titleLab.left = 64;
        _titleLab.centerY = self.contentView.height * 0.5;
    }
    
    [_moneyLab sizeToFit];
    _moneyLab.width = MIN(maxWidth, _moneyLab.width);
    _moneyLab.rightTop = CGPointMake(self.contentView.width - 18, 20);
    
    [_dateLab sizeToFit];
    _dateLab.rightTop = CGPointMake(self.contentView.width - 18, 56);
    
    _memoLab.width = (_dateLab.left - _memoLab.left - 10);
    
    self.stateLabel.size = CGSizeMake(100, 70);
    self.stateLabel.centerX = self.contentView.width - 20;
    self.stateLabel.centerY = 20;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.transform = CGAffineTransformMakeRotation(M_PI_4);
        _stateLabel.layer.anchorPoint = CGPointMake(0.5, 0.5);
        _stateLabel.text = @"已到期";
    }
    return _stateLabel;
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    [self updateAppearance];
}

- (void)setCellItem:(SSJBaseCellItem *)cellItem {
    SSJLoanListCellItem *item = (SSJLoanListCellItem *)cellItem;
    _icon.image = [UIImage imageNamed:item.icon];
    _titleLab.text = item.loanTitle;
    _memoLab.text = item.memo;
    _moneyLab.text = item.money;
    _dateLab.text = item.date;
    _stamp.hidden = !item.showStamp;
    if (item.imageName.length) {
        _stamp.image = [UIImage imageNamed:item.imageName];
        [_stamp sizeToFit];
    }

    if (_stamp.hidden == NO) {
        self.stateLabel.hidden = YES;
    } else {
        self.stateLabel.hidden = !item.showStateL;
    }
    [self setNeedsLayout];
}

- (void)updateAppearance {
    _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _stateLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    _memoLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _moneyLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _dateLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    self.stateLabel.backgroundColor = [UIColor ssj_colorWithHex:[SSJThemeSetting defaultThemeModel].borderColor];
}

@end
