//
//  SSJCategoryCollectionView.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/18.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJRecordMakingCategoryItem.h"

@interface SSJCategoryCollectionView : UIView<UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic,strong)UICollectionView *collectionView;

typedef void (^ItemClickedBlock)(SSJRecordMakingCategoryItem *item);

typedef void (^removeFromCategoryListBlock)();

@property(nonatomic, copy)removeFromCategoryListBlock removeFromCategoryListBlock;

@property (nonatomic, copy) ItemClickedBlock ItemClickedBlock;

@property (nonatomic) int page;

@property (nonatomic) long totalPage;

@property (nonatomic) BOOL incomeOrExpence;

@property (nonatomic,strong) NSString *selectedId;
@end
