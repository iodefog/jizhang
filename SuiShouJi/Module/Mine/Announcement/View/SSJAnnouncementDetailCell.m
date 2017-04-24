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

@property(nonatomic, strong) UIImageView *leftImageView;

@property(nonatomic, strong) UILabel *titleLab;

@property(nonatomic, strong) UILabel *dateLab;

@property(nonatomic, strong) UILabel *contentLab;

@property (nonatomic, strong) UILabel *readNumLab;

@end


@implementation SSJAnnouncementDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self addSubview:self.leftImageView];
        [self addSubview:self.titleLab];
        [self addSubview:self.dateLab];
        [self addSubview:self.contentLab];
        [self addSubview:self.readNumLab];
        [self setUpConstraints];

    }
    return self;
}

#pragma mark - lazy
- (UIImageView *)leftImageView
{
    if (!_leftImageView) {
        _leftImageView = [[UIImageView alloc] init];
//        _leftImageView.contentMode = UIViewContentModeScaleAspectFit;
        _leftImageView.layer.cornerRadius = 4;
        _leftImageView.layer.masksToBounds = YES;
        [_leftImageView clipsToBounds];
    }
    return _leftImageView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.numberOfLines = 0;
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

- (UILabel *)readNumLab
{
    if (!_readNumLab) {
        _readNumLab = [[UILabel alloc] init];
        _readNumLab.font = self.dateLab.font;
        _readNumLab.textColor = self.dateLab.textColor;
    }
    return _readNumLab;
}

- (void)setUpConstraints {
    
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 80));
        make.left.offset(15);
        make.centerY.mas_equalTo(self);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(18);
        make.left.mas_equalTo(self.leftImageView.mas_right).with.offset(10);
//        make.width.mas_lessThanOrEqualTo(self.contentView.mas_width).with.offset(-10);
//        make.bottom.mas_equalTo(self.contentView.mas_centerY).with.offset(-10);
        make.right.mas_equalTo(-10);
    }];
    
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLab);
        make.top.mas_equalTo(self.titleLab.mas_bottom).with.offset(8);
    }];
    
    [self.dateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.right).with.offset(-10);
        make.bottom.mas_equalTo(-18);
    }];
    
    [self.readNumLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentLab);
        make.bottom.mas_equalTo(self.dateLab);
    }];
}

- (void)setCellItem:(__kindof SSJBaseItem *)cellItem {
    if (![cellItem isKindOfClass:[SSJAnnoucementItem class]]) {
        return;
    }
    SSJAnnoucementItem *item = (SSJAnnoucementItem *)cellItem;
    [self.leftImageView sd_setImageWithURL:[NSURL URLWithString:item.announcementImg] placeholderImage:[UIImage imageNamed:@"noneThumbImage"]];
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
    _contentLab.textColor = _readNumLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
