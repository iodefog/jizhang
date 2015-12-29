//
//  SSJCategoryCollectionViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/21.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCategoryCollectionViewCell.h"

@interface SSJCategoryCollectionViewCell()
@property (strong, nonatomic) UIButton *editButton;
@end
@implementation SSJCategoryCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //        self.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:self.categoryImage];
        [self.contentView addSubview:self.categoryName];
        //        [self addSubview:self.editButton];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.categoryImage.centerX = self.width / 2;
    self.categoryName.top = self.categoryImage.bottom + 10;
    self.categoryName.centerX = self.width / 2;
}

-(UIImageView*)categoryImage{
    if (!_categoryImage) {
        _categoryImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        _categoryImage.image = [UIImage imageNamed:self.item.categoryImage];
        _categoryImage.layer.cornerRadius = 25;
        _categoryImage.layer.masksToBounds = YES;
        _categoryImage.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _categoryImage;
}

-(UILabel*)categoryName{
    if (!_categoryName) {
        _categoryName = [[UILabel alloc]init];
        _categoryName.text = _item.categoryTitle;
        [_categoryName sizeToFit];
        _categoryName.font = [UIFont systemFontOfSize:15];
        _categoryName.textColor = [UIColor ssj_colorWithHex:@"a7a7a7"];

    }
    return _categoryName;
}

-(UIButton *)editButton{
    if (!_editButton) {
        _editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 12, 12)];
        [_editButton setImage:[UIImage imageNamed:@"edit test"] forState:UIControlStateNormal];
        _editButton.layer.cornerRadius = 6.0f;
        _editButton.layer.masksToBounds = YES;
    }
    return _editButton;
}
@end
