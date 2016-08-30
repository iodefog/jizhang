//
//  SSJCategoryEditableCollectionView.h
//  SuiShouJi
//
//  Created by old lang on 16/8/30.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSJRecordMakingCategoryItem;

@interface SSJCategoryEditableCollectionView : UIView

@property (nonatomic, strong) NSArray <SSJRecordMakingCategoryItem *>*items;

@property (nonatomic, strong, readonly) NSArray <SSJRecordMakingCategoryItem *>*selectedItems;

@property (nonatomic) BOOL editing;

@property (nonatomic, copy) void(^editStateChangeHandle)(SSJCategoryEditableCollectionView *view);

@property (nonatomic, copy) void(^selectedItemsChangeHandle)(SSJCategoryEditableCollectionView *view);

- (void)updateAppearance;

@end
