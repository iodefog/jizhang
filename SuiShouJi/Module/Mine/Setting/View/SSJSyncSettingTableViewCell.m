//
//  SSJSyncSettingTableViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 16/1/22.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSyncSettingTableViewCell.h"

@interface SSJSyncSettingTableViewCell()
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIImageView *checkMarkImage;
@end

@implementation SSJSyncSettingTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.checkMarkImage];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.left = 10;
    self.titleLabel.centerY = self.height / 2;
    self.checkMarkImage.size = CGSizeMake(17, 17);
    self.checkMarkImage.right = self.width - 10;
    self.checkMarkImage.centerY = self.height / 2;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    }
    return _titleLabel;
}

-(UIImageView *)checkMarkImage{
    if (!_checkMarkImage) {
        _checkMarkImage = [[UIImageView alloc]init];
        _checkMarkImage.image = [[UIImage imageNamed:@"checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _checkMarkImage.tintColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.marcatoColor];
    }
    return _checkMarkImage;
}

-(void)setCellTitle:(NSString *)cellTitle{
    _cellTitle = cellTitle;
    _titleLabel.text = _cellTitle;
    [_titleLabel sizeToFit];
}

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.checkMarkImage.hidden = NO;
    }else{
        self.checkMarkImage.hidden = YES;
    }
}

@end
