//
//  SSJCategoryCollectionViewCell.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/18.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCategoryCollectionViewCell.h"

@interface SSJCategoryCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *categoryImage;
@property (weak, nonatomic) IBOutlet UILabel *categoryName;
@end
@implementation SSJCategoryCollectionViewCell

- (void)awakeFromNib {
    self.categoryImage.layer.cornerRadius = 20;
    self.categoryImage.layer.masksToBounds = YES;
}

@end
