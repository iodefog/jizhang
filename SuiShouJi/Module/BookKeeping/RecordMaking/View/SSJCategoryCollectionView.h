//
//  SSJCategoryCollectionView.h
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/18.
//  Copyright © 2015年 ___9188___. All rights reserved.
//
//每页的记账类型

#import <UIKit/UIKit.h>
#import "SSJRecordMakingCategoryItem.h"

@interface SSJCategoryCollectionView : UIView<UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic,strong)UICollectionView *collectionView;

//选择记账类型回调
typedef void (^ItemClickedBlock)(SSJRecordMakingCategoryItem *item);

typedef void (^removeFromCategoryListBlock)();

//删除记账类型回调
@property(nonatomic, copy)removeFromCategoryListBlock removeFromCategoryListBlock;

@property (nonatomic, copy) ItemClickedBlock ItemClickedBlock;

@property(nonatomic, strong) NSArray *items;

//当前页数
@property (nonatomic) int page;

//总页数
@property (nonatomic) long totalPage;

//输入还是支出
@property (nonatomic) BOOL incomeOrExpence;

//当前选中的记账类型id
@property (nonatomic,strong) NSString *selectedId;
@end
