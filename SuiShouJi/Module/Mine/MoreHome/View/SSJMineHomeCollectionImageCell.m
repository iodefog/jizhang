//
//  SSJMineHomeCollectionImageCell.m
//  SuiShouJi
//
//  Created by yi cai on 2016/12/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJMineHomeCollectionImageCell.h"
#import "SSJListAdItem.h"
@interface SSJMineHomeCollectionImageCell()
@property (nonatomic, strong) UIImageView *topImage;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *bottomLabel;
//@property (nonatomic, strong) SSJListAdItem *adItem;
@end

@implementation SSJMineHomeCollectionImageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.topImage];
       [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.bottomLabel];
        self.bottomLabel.textAlignment = NSTextAlignmentCenter;
        self.bottomLabel.font = [UIFont systemFontOfSize:12];
        [self ssj_setBorderStyle:SSJBorderStyleBottom | SSJBorderStyleRight];
        [self ssj_setBorderWidth:0.5];
        [self ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
       self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCellAppearanceAfterThemeChanged) name:SSJThemeDidChangeNotification object:nil];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.topImage.frame = CGRectMake(0, 25, self.width, 22);
    
    self.nameLabel.frame = CGRectMake(0, CGRectGetMaxY(self.topImage.frame) + 15, self.width, 20);
    self.bottomLabel.frame = CGRectMake(0, CGRectGetMaxY(self.nameLabel.frame), self.width, 15);
}


- (void)setAdItem:(SSJListAdItem *)adItem indexPath:(NSIndexPath *)indexPath
{
    if (adItem.url.length && adItem.imageUrl.length) {//是广告
        [self.topImage sd_setImageWithURL:[NSURL URLWithString:adItem.imageUrl] placeholderImage:nil];
//            [self.topImage sd_setImageWithURL:[NSURL URLWithString:adItem.imageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                if (image) {
//                    
//                }
//            }];
    
    }else {
        _topImage.image = [UIImage imageNamed:adItem.imageName];
    }
    _nameLabel.text = adItem.adTitle;
    if ([adItem.adTitle isEqualToString:@"建议与咨询"]) {//显示附标题
        _bottomLabel.text = @"反馈交流群:552563622";
        self.nameLabel.frame = CGRectMake(0, CGRectGetMaxY(self.topImage.frame) + 10, self.width, 20);
        self.bottomLabel.frame = CGRectMake(0, CGRectGetMaxY(self.nameLabel.frame), self.width, 15);
    }else{
        _bottomLabel.text = @"";
        self.nameLabel.frame = CGRectMake(0, CGRectGetMaxY(self.topImage.frame) + 15, self.width, 20);
        self.bottomLabel.frame = CGRectMake(0, CGRectGetMaxY(self.nameLabel.frame), self.width, 15);
    }
    
    //边框
//    if ((indexPath.row + 1) % kColum == 0) {
//        //第三列
//        self.vLineView.hidden = YES;
//    }else{
//        self.vLineView.hidden = NO;
//    }
    
//    else if ((indexPath.row + 1) % kColum == 1){
//        //第一列
//        
//    }
}
#pragma mark Lazy
- (UIImageView *)topImage
{
    if (!_topImage) {
        _topImage = [[UIImageView alloc] init];
        _topImage.contentMode = UIViewContentModeScaleAspectFit;
        _topImage.backgroundColor = [UIColor clearColor];
    }
    return _topImage;
}


- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
//        [_nameLabel sizeToFit];
        _nameLabel.backgroundColor = [UIColor clearColor];
    }
    return _nameLabel;
}

- (UILabel *)bottomLabel
{
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc] init];
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
        _bottomLabel.font = [UIFont systemFontOfSize:12];
        _bottomLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _bottomLabel.backgroundColor = [UIColor clearColor];
//        [_bottomLabel sizeToFit];
    }
    return _bottomLabel;
}


-(void)updateCellAppearanceAfterThemeChanged{
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    self.nameLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.bottomLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    [self ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
}
@end
