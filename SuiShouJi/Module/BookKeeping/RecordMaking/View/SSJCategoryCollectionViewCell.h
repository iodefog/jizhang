//
//  SSJCategoryCollectionViewCell.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/21.
//  Copyright © 2015年 ___9188___. All rights reserved.
//?

#import <UIKit/UIKit.h>
#import "SSJRecordMakingCategoryItem.h"

@interface SSJCategoryCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *categoryImage;
@property (strong, nonatomic) UILabel *categoryName;
@property (nonatomic) BOOL EditeModel;
@property (nonatomic) BOOL categorySelected;
@property (nonatomic,strong) SSJRecordMakingCategoryItem *item;
typedef void (^removeCategoryBlock)();

@property(nonatomic,copy) removeCategoryBlock removeCategoryBlock;
@end
