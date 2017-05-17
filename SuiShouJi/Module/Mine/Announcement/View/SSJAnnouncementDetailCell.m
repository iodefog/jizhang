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

@property (nonatomic, strong) UIImageView *readImage;

@property (nonatomic, strong) UILabel *readNumLab;

@end


@implementation SSJAnnouncementDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.leftImageView];
        [self.contentView addSubview:self.titleLab];
        [self.contentView addSubview:self.dateLab];
        [self.contentView addSubview:self.contentLab];
        [self.contentView addSubview:self.readImage];
        [self.contentView addSubview:self.readNumLab];
//        [self setUpConstraints];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

#pragma mark - lazy
- (UIImageView *)leftImageView
{
    if (!_leftImageView) {
        _leftImageView = [[UIImageView alloc] init];
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 100, 80) cornerRadius:4].CGPath;
        _leftImageView.layer.mask = layer;
    }
    return _leftImageView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _titleLab.numberOfLines = 0;
    }
    return _titleLab;
}

- (UILabel *)dateLab {
    if (!_dateLab) {
        _dateLab = [[UILabel alloc] init];
        _dateLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _dateLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
    }
    return _dateLab;
}

- (UILabel *)contentLab {
    if (!_contentLab) {
        _contentLab = [[UILabel alloc] init];
        _contentLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _contentLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_4];
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

- (UIImageView *)readImage
{
    if (!_readImage) {
        _readImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"more_message_readyanjing"]];
        [_readImage sizeToFit];
    }
    return _readImage;
}

- (void)updateConstraints
{
    [self setUpConstraints];
    [super updateConstraints];
}

- (void)setUpConstraints {
//    [self mas_updateConstraints:^(MASConstraintMaker *make) {
//        [make.height uninstall];
//    }];
    [self.leftImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 80));
        make.left.offset(15);
        make.centerY.mas_equalTo(self);
        
    }];
    
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(18);
        make.left.mas_equalTo(self.leftImageView.mas_right).with.offset(10);
//        make.width.mas_lessThanOrEqualTo(self.contentView.mas_width).with.offset(-10);
//        make.bottom.mas_equalTo(self.contentView.mas_centerY).with.offset(-10);
        make.right.mas_equalTo(-10);
    }];
    
    [self.contentLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLab);
        make.top.mas_equalTo(self.titleLab.mas_bottom).with.offset(8);
    }];
    
    [self.dateLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.right).with.offset(-10);
//        make.bottom.mas_equalTo(-18);
        make.top.mas_equalTo(self.contentLab.mas_bottom).offset(8);
        make.bottom.mas_equalTo(self.contentView).offset(-18);
    }];
    
    [self.readImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentLab);
        make.bottom.mas_equalTo(self.dateLab).offset(-4);
    }];
    
    [self.readNumLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.readImage.mas_right).offset(5);
        make.bottom.mas_equalTo(self.dateLab);
    }];
}

- (void)setCellItem:(__kindof SSJBaseCellItem *)cellItem {
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
    _readNumLab.text = item.announcementNumber;
    [self setNeedsLayout];
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

@end
