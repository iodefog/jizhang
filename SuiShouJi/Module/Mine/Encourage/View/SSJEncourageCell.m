//
//  SSJEncourageCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 2017/7/1.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import "SSJEncourageCell.h"

@interface SSJEncourageCell()

@property (nonatomic , strong) UILabel *titleLab;

@property (nonatomic , strong) UILabel *detailLab;

@property (nonatomic,strong) UILabel *subdetailLab;

@property (nonatomic,strong) UIImageView *celldetailImage;

@end

@implementation SSJEncourageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLab];
        [self.contentView addSubview:self.detailLab];
        [self.contentView addSubview:self.subdetailLab];
        [self.contentView addSubview:self.celldetailImage];
    }
    
    return self;
}

- (void)updateConstraints {
    [self.titleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(15);
    }];
    
    [self.detailLab mas_updateConstraints:^(MASConstraintMaker *make) {
        if (!_item.cellSubTitle.length) {
            make.centerY.mas_equalTo(self);
            make.right.mas_equalTo(self.mas_right).offset(-15);
        } else {
            make.bottom.mas_equalTo(self.mas_centerY).offset(-2);
            make.right.mas_equalTo(self.mas_right).offset(- 15);
        }
    }];
    
    [self.subdetailLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_centerY).offset(2);
        make.right.mas_equalTo(self.mas_right).offset(- 15);
    }];
    
    [self.celldetailImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self.mas_right).offset(-15);
    }];
    
    [super updateConstraints];
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _titleLab;
}

- (UILabel *)detailLab {
    if (!_detailLab) {
        _detailLab = [[UILabel alloc] init];
        _detailLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _detailLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _detailLab;
}

- (UILabel *)subdetailLab {
    if (!_subdetailLab) {
        _subdetailLab = [[UILabel alloc] init];
        _subdetailLab.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _subdetailLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    }
    return _subdetailLab;
}

- (UIImageView *)celldetailImage {
    if (!_celldetailImage) {
        _celldetailImage = [[UIImageView alloc] init];
    }
    return _celldetailImage;
}

- (void)setItem:(SSJEncourageCellModel *)item {
    _item = item;
    self.titleLab.text = _item.cellTitle;
    self.detailLab.text = _item.cellDetail;
    self.subdetailLab.text = _item.cellSubTitle;
    self.celldetailImage.image = [UIImage imageNamed:_item.cellImage];
    [self updateConstraintsIfNeeded];
}


- (void)updateCellAppearanceAfterThemeChanged {
    [super updateCellAppearanceAfterThemeChanged];
    _titleLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _detailLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    _subdetailLab.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
