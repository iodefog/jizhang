//
//  SSJThemeHomeCollectionViewCell.m
//  SuiShouJi
//
//  Created by ricky on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeHomeCollectionViewCell.h"

@interface SSJThemeHomeCollectionViewCell()
@property(nonatomic, strong) UIImageView *themeImage;
@property(nonatomic, strong) UILabel *themeTitleLabel;
@property(nonatomic, strong) UILabel *themeSizeLabel;
@property(nonatomic, strong) UILabel *themeStatusLabel;
@property(nonatomic, strong) UIButton *themeStatusButton;
@end

@implementation SSJThemeHomeCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.themeImage];
        [self.contentView addSubview:self.themeTitleLabel];
        [self.contentView addSubview:self.themeSizeLabel];
        [self.contentView addSubview:self.themeStatusLabel];
        [self.contentView addSubview:self.themeStatusButton];
    }
    return self;
}

-(float)cellHeight{
    float height = 225 + [self.themeTitleLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}].height;
    return height;
}

-(void)layoutSubviews{
    self.themeImage.size = CGSizeMake(self.width, 179);
    self.themeImage.leftTop = CGPointMake(0, 0);
    self.themeTitleLabel.leftTop = CGPointMake(5, 15);
    self.themeSizeLabel.leftBottom = CGPointMake(self.themeTitleLabel.right + 10, self.themeTitleLabel.bottom);
    self.themeStatusLabel.leftTop = CGPointMake(self.themeTitleLabel.left, self.themeTitleLabel.bottom + 10);
    self.themeStatusButton.leftTop =  self.themeStatusLabel.leftTop;
}

-(UIImageView *)themeImage{
    if (!_themeImage) {
        _themeImage = [[UIImageView alloc]init];
        _themeImage.layer.cornerRadius = 4.f;
        _themeImage.layer.masksToBounds = YES;
    }
    return _themeImage;
}

-(UILabel *)themeTitleLabel{
    if (!_themeTitleLabel) {
        _themeTitleLabel = [[UILabel alloc]init];
        _themeTitleLabel.font = [UIFont systemFontOfSize:16];
        _themeTitleLabel.textColor = [UIColor ssj_colorWithHex:@"393939"];
    }
    return _themeTitleLabel;
}

-(UILabel *)themeSizeLabel{
    if (!_themeSizeLabel) {
        _themeSizeLabel = [[UILabel alloc]init];
        _themeSizeLabel.font = [UIFont systemFontOfSize:13];
        _themeSizeLabel.textColor = [UIColor ssj_colorWithHex:@"929292"];
    }
    return _themeSizeLabel;
}

-(UILabel *)themeStatusLabel{
    if (!_themeStatusLabel) {
        _themeStatusLabel = [[UILabel alloc]init];
        _themeStatusLabel.font = [UIFont systemFontOfSize:13];
        _themeStatusLabel.textColor = [UIColor ssj_colorWithHex:@"929292"];
    }
    return _themeStatusLabel;
}

-(UIButton *)themeStatusButton{
    if (!_themeStatusButton) {
        _themeStatusButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 57, 21)];
        _themeStatusButton.layer.cornerRadius = 4.f;
        _themeStatusButton.layer.borderColor = [UIColor colorWithRed:235.f / 255 green:74.f / 255 blue:100.f / 255 alpha:0.5].CGColor;
        _themeStatusButton.layer.borderWidth = 1.f;
        [_themeStatusButton addTarget:self action:@selector(statusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _themeStatusButton;
}

-(void)statusButtonClicked:(id)sender{
    
}

-(void)setItem:(SSJThemeItem *)item{
    
}

@end
