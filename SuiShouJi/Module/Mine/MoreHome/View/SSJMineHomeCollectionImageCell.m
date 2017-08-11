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

@property (nonatomic, strong) UIView *dotView;
@end

@implementation SSJMineHomeCollectionImageCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.topImage];
       [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.bottomLabel];
        [self.contentView addSubview:self.dotView];
//        self.backgroundColor = [UIColor clearColor];
//        self.contentView.backgroundColor = [UIColor clearColor];
        [self ssj_setBorderStyle:SSJBorderStyleBottom];
        [self ssj_setBorderWidth:1];
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
    self.dotView.rightTop = CGPointMake(self.width * 0.5 + 17, 23);
}


//- (void)setAdItem:(SSJListAdItem *)adItem indexPath:(NSIndexPath *)indexPath
//{
//    if (adItem.url.length && adItem.imageUrl.length) {//是广告
//        [self.topImage sd_setImageWithURL:[NSURL URLWithString:adItem.imageUrl] placeholderImage:nil];
//    }else {
//        _topImage.image = [UIImage imageNamed:adItem.imageName];
//    }
//    _nameLabel.text = adItem.adTitle;
//    if ([adItem.adTitle isEqualToString:@"建议与咨询"]) {//显示附标题
//        _bottomLabel.text = @"反馈群:552563622";
//        self.nameLabel.frame = CGRectMake(0, CGRectGetMaxY(self.topImage.frame) + 10, self.width, 20);
//        self.bottomLabel.frame = CGRectMake(0, CGRectGetMaxY(self.nameLabel.frame), self.width, 15);
//    }else{
//        _bottomLabel.text = @"";
//        self.nameLabel.frame = CGRectMake(0, CGRectGetMaxY(self.topImage.frame) + 15, self.width, 20);
//        self.bottomLabel.frame = CGRectMake(0, CGRectGetMaxY(self.nameLabel.frame), self.width, 15);
//    }
//    //是否显示小红点
//    if ([adItem.adTitle isEqualToString:@"主题皮肤"] || [adItem.adTitle isEqualToString:@"建议与咨询"]) {
//        self.dotView.hidden = !adItem.isShowDot;
//    }else {
//        self.dotView.hidden = YES;
//    }
//}

#pragma mark - Lazy
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
        _nameLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_3];
        _nameLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
        _nameLabel.backgroundColor = [UIColor clearColor];
    }
    return _nameLabel;
}

- (UILabel *)bottomLabel
{
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc] init];
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
        _bottomLabel.font = [UIFont ssj_pingFangRegularFontOfSize:SSJ_FONT_SIZE_5];
        _bottomLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
        _bottomLabel.backgroundColor = [UIColor clearColor];
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _bottomLabel;
}

- (UIView *)dotView
{
    if (!_dotView) {
        _dotView = [[UIView alloc] init];
        _dotView.backgroundColor = [UIColor ssj_colorWithHex:@"EE4F4F"];
        _dotView.size = CGSizeMake(5, 5);
        _dotView.layer.cornerRadius = 2.5;
        _dotView.hidden = YES;
        [_dotView clipsToBounds];
    }
    return _dotView;
}

-(void)updateCellAppearanceAfterThemeChanged {
    self.backgroundColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainBackGroundColor alpha:SSJ_CURRENT_THEME.backgroundAlpha];
    self.nameLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.mainColor];
    self.bottomLabel.textColor = [UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.secondaryColor];
    [self ssj_setBorderColor:[UIColor ssj_colorWithHex:SSJ_CURRENT_THEME.cellSeparatorColor alpha:SSJ_CURRENT_THEME.cellSeparatorAlpha]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
