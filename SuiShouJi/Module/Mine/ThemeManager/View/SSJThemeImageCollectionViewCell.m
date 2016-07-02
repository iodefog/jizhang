
//
//  SSJThemeImageCollectionViewCell.m
//  SuiShouJi
//
//  Created by ricky on 16/6/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeImageCollectionViewCell.h"

@interface SSJThemeImageCollectionViewCell()
@property(nonatomic, strong) UIImageView *cellImageView;
@end

@implementation SSJThemeImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.cellImageView];
    }
    return self;
}

-(UIImageView *)cellImageView{
    if (!_cellImageView) {
        _cellImageView = [[UIImageView alloc]initWithFrame:self.contentView.bounds];
        _cellImageView.layer.cornerRadius = 3.f;
        _cellImageView.layer.masksToBounds = YES;
//        _cellImageView.image = [UIImage ssj_imageWithColor:[UIColor redColor] size:self.contentView.size];
    }
    return _cellImageView;
}

-(void)setImageUrl:(NSString *)imageUrl{
    _imageUrl = imageUrl;
    [self.cellImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"noneDetailImage"]];
}

-(void)setImageName:(NSString *)imageName{
    _imageName = imageName;
    self.cellImageView.image = [UIImage imageNamed:_imageName];
}

@end
