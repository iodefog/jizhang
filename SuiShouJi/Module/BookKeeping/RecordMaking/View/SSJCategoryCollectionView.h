//
//  SSJCategoryCollectionView.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/18.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSJCategoryCollectionView : UIView<UICollectionViewDataSource,UICollectionViewDelegate>

typedef void (^ItemClickedBlock)(NSString *categoryTitle , UIImage *categoryImage);

@property (nonatomic, copy) ItemClickedBlock ItemClickedBlock;

@end
