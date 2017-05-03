//
//  SSJCategoryEditableCollectionView.h
//  SuiShouJi
//
//  Created by old lang on 16/8/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJRecordMakingCategoryItem.h"

@interface SSJCategoryEditableCollectionView : UIView

@property (nonatomic, strong) NSArray <SSJRecordMakingCategoryItem *>*items;

@property (nonatomic, strong) NSArray *selectedIndexs;

// default NO
@property (nonatomic) BOOL editing;

// default YES
@property (nonatomic) BOOL editable;

@property (nonatomic) CGSize itemSize;

// default (0, 10, 94, 10)
@property (nonatomic) UIEdgeInsets contentInset;

@property (nonatomic, copy) void(^editStateChangeHandle)(SSJCategoryEditableCollectionView *view);

@property (nonatomic, copy) void(^selectedItemsChangeHandle)(SSJCategoryEditableCollectionView *view);

@property (nonatomic, copy) void(^didScrollHandle)(SSJCategoryEditableCollectionView *view, CGPoint velocity);

- (void)updateAppearance;

- (NSArray <SSJRecordMakingCategoryItem *>*)selectedItems;

- (void)deleteItems:(NSArray <SSJRecordMakingCategoryItem *>*)items;

@end
