//
//  SSJNewCategoryCollectionView.h
//  SuiShouJi
//
//  Created by 赵天立 on 16/3/26.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJRecordMakingCategoryItem.h"

@interface SSJNewCategoryCollectionView : UIView<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,strong) NSMutableArray *items;
@property(nonatomic, assign) CGSize                itemSize;
@property(nonatomic, assign) NSUInteger            lineCount;
@property(nonatomic, assign) NSUInteger            columnCount;
@property(nonatomic, assign) UIEdgeInsets          pageContentInsets;
@property(nonatomic, strong) NSString              *pageContentInsetsString;
@property(nonatomic, strong)  NSString *selectId;

- (void)reloadData;


//选择记账类型回调
typedef void (^ItemClickedBlock)(SSJRecordMakingCategoryItem *item);

typedef void (^removeFromCategoryListBlock)();

//删除记账类型回调
@property(nonatomic, copy)removeFromCategoryListBlock removeFromCategoryListBlock;

@property (nonatomic, copy) ItemClickedBlock ItemClickedBlock;
@end
