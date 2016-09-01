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

@property (nonatomic, strong, readonly) NSArray <SSJRecordMakingCategoryItem *>*selectedItems;

// default NO
@property (nonatomic) BOOL editing;

// default YES
@property (nonatomic) BOOL editable;

@property (nonatomic) CGSize itemSize;

@property (nonatomic) UIEdgeInsets contentInset;

@property (nonatomic, copy) void(^editStateChangeHandle)(SSJCategoryEditableCollectionView *view);

@property (nonatomic, copy) void(^selectedItemsChangeHandle)(SSJCategoryEditableCollectionView *view);

@property (nonatomic, copy) void(^didScrollHandle)(SSJCategoryEditableCollectionView *view, CGPoint velocity);

- (void)updateAppearance;

- (void)deleteItems:(NSArray <SSJRecordMakingCategoryItem *>*)items;

@end
