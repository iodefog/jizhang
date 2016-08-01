


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
        [self.themeImage addSubview:self.inuseImage];
        [self.themeImage addSubview:self.maskView];
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
    self.inuseImage.leftTop = CGPointMake(0, 10);
    self.maskView.frame = self.themeImage.bounds;
    self.deleteButton.rightBottom = CGPointMake(self.themeImage.right, self.themeImage.bottom - 10);
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
        [_inuseImage sizeToFit];
    }
    return _inuseImage;
}

-(void)deleteButtonClicked:(id)sender{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[NSString ssj_themeDirectory] stringByAppendingPathComponent:self.item.ID]]) {
        if ([[NSFileManager defaultManager] removeItemAtPath:[[NSString ssj_themeDirectory] stringByAppendingPathComponent:self.item.ID] error:NULL]) {
            if (self.deleteThemeBlock) {
                self.deleteThemeBlock();
            }
        }
    }
}

-(void)setItem:(SSJThemeModel *)item{
    _item = item;
    if ([_item.ID isEqualToString:SSJDefaultThemeID]) {
        self.themeImage.image = [UIImage imageNamed:@"defualtImage"];
    }else{
        [self.themeImage sd_setImageWithURL:[NSURL URLWithString:item.previewUrlStr]];
    }
    self.themeTitleLabel.text = item.name;
    [self.themeTitleLabel sizeToFit];
    self.themeSizeLabel.text = item.size;
    [self.themeSizeLabel sizeToFit];
    [self setNeedsLayout];
}

-(void)setEditeModel:(BOOL)editeModel{
    _editeModel = editeModel;
    if (_editeModel && self.canEdite) {
        self.maskView.hidden = NO;
    }else{
        self.maskView.hidden = YES;
    }
}

-(void)setCanEdite:(BOOL)canEdite{
    _canEdite = canEdite;
}

-(void)setInUse:(BOOL)inUse{
    _inUse = inUse;
    self.inuseImage.hidden = !_inUse;
}

@end
