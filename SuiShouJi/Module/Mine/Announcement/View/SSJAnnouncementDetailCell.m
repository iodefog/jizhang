//
//  SSJAnnouncementDetailCell.m
//  SuiShouJi
//
//  Created by ricky on 2017/2/24.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJAnnouncementDetailCell.h"
#import "SSJAnnoucementItem.h"

@interface SSJAnnouncementDetailCell()

@property(nonatomic, strong) UILabel *titleLab;

@property(nonatomic, strong) UILabel *dateLab;

@property(nonatomic, strong) UILabel *contentLab;

@end


@implementation SSJAnnouncementDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self addSubview:self.titleLab];
        [self addSubview:self.dateLab];
        [self addSubview:self.contentLab];
        [self setUpConstraints];

    }
    return self;
}


- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _titleLab.font = [UIFont systemFontOfSize:16];
    }
    return _titleLab;
}

- (UILabel *)dateLab {
    if (!_dateLab) {
        _dateLab = [[UILabel alloc] init];
        _dateLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _dateLab.font = [UIFont systemFontOfSize:12];
    }
    return _dateLab;
}

- (UILabel *)contentLab {
    if (!_contentLab) {
        _contentLab = [[UILabel alloc] init];
        _contentLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _contentLab.font = [UIFont systemFontOfSize:13];
    }
    return _contentLab;
}

- (void)setUpConstraints {
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.left).with.offset(10);
        make.width.mas_lessThanOrEqualTo(self.contentView.mas_width).with.offset(10);
        make.bottom.mas_equalTo(self.contentView.mas_centerY).with.offset(-10);
    }];
    
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.left).with.offset(10);
        make.top.mas_equalTo(self.contentView.mas_centerY).with.offset(10);
    }];
    
    [self.dateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.right).with.offset(-10);
        make.top.mas_equalTo(self.contentView.mas_centerY);
    }];
}

- (void)setCellItem:(__kindof SSJBaseItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJAnnoucementItem class]]) {
        return;
    }
    SSJAnnoucementItem *item = (SSJAnnoucementItem *)cellItem;
    self.titleLab.text = item.announcementTitle;
    self.dateLab.text = item.announcementDate;
    self.contentLab.text = item.announcementContent;
    if (!item.haveReaded) {
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    } else {
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
}

- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    SSJAnnoucementItem *item = (SSJAnnoucementItem *)self.cellItem;
    if (!item.haveReaded) {
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    } else {
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    _dateLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    _contentLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
