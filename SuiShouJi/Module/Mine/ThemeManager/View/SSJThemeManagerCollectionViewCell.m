


//
//  SSJThemeManagerCollectionViewCell.m
//  SuiShouJi
//
//  Created by ricky on 16/7/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeManagerCollectionViewCell.h"

@interface SSJThemeManagerCollectionViewCell()

@property(nonatomic, strong) UILabel *themeSizeLabel;

@property(nonatomic, strong) UILabel *themeTitleLabel;

@property(nonatomic, strong) UIImageView *themeImage;

@property(nonatomic, strong) UIView *maskView;

@property(nonatomic, strong) UIButton *deleteButton;

@property(nonatomic, strong) UIImageView *inuseImage;

@end

@implementation SSJThemeManagerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.themeImage];
        [self.themeImage addSubview:self.maskView];
        [self.themeImage addSubview:self.inuseImage];
        [self.maskView addSubview:self.deleteButton];
        [self.contentView addSubview:self.themeTitleLabel];
        [self.contentView addSubview:self.themeSizeLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    float imageRatio = 220.f / 358;
    self.themeImage.size = CGSizeMake(self.width, self.width / imageRatio);
    self.themeImage.leftTop = CGPointMake(0, 0);
    self.maskView.frame = self.themeImage.bounds;
    self.themeTitleLabel.leftTop = CGPointMake(5, self.themeImage.bottom + 15);
    self.themeSizeLabel.leftBottom = CGPointMake(self.themeTitleLabel.right + 10, self.themeTitleLabel.bottom);
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

-(UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc]init];
        _maskView.backgroundColor = [UIColor ssj_colorWithHex:@"#000000" alpha:0.5];
    }
    return _maskView;
}

-(UIButton *)deleteButton{
    if (!_deleteButton) {
        _deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_deleteButton setImage:[UIImage imageNamed:@"ft_delete"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

-(UIImageView *)inuseImage{
    if (!_inuseImage) {
        _inuseImage = [[UIImageView alloc]init];
        _inuseImage.image = [UIImage imageNamed:@"biaoqian"];
    }
    return _inuseImage;
}

-(void)deleteButtonClicked:(id)sender{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSString ssj_themeDirectory] stringByAppendingPathComponent:self.item.ID]]) {
        if ([[NSFileManager defaultManager] removeItemAtPath:[[NSString ssj_themeDirectory] stringByAppendingPathComponent:self.item.ID] error:NULL]) {
            
        }
    }
}

@end
