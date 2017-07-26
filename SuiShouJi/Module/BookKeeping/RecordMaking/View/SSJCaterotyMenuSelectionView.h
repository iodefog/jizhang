//
//  SSJCreateOrEditBillTypeIconSelectionView.h
//  SuiShouJi
//
//  Created by old lang on 2017/7/21.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SSJCaterotyMenuSelectionView;
@class SSJCaterotyMenuSelectionCellItem;
@class SSJCaterotyMenuSelectionViewIndexPath;

@protocol SSJCaterotyMenuSelectionViewDataSource <NSObject>

@required

- (NSUInteger)numberOfMenuTitlesInSelectionView:(SSJCaterotyMenuSelectionView *)selectionView;

- (NSString *)selectionView:(SSJCaterotyMenuSelectionView *)selectionView titleForLeftMenuAtIndex:(NSInteger)index;

- (NSUInteger)selectionView:(SSJCaterotyMenuSelectionView *)selectionView numberOfCategoriesAtMenuIndex:(NSInteger)index;

- (NSString *)selectionView:(SSJCaterotyMenuSelectionView *)selectionView titleForCategoryAtIndex:(NSInteger)categoryIndex menuIndex:(NSInteger)menuIndex;

- (NSUInteger)selectionView:(SSJCaterotyMenuSelectionView *)selectionView numberOfItemsAtCategoryIndex:(NSInteger)categoryIndex menuIndex:(NSInteger)menuIndex;

- (SSJCaterotyMenuSelectionCellItem *)selectionView:(SSJCaterotyMenuSelectionView *)selectionView itemAtIndexPath:(SSJCaterotyMenuSelectionViewIndexPath *)indexPath;

@end


@protocol SSJCaterotyMenuSelectionViewDelegate <NSObject>

@optional
- (void)selectionView:(SSJCaterotyMenuSelectionView *)selectionView didSelectMenuAtIndex:(NSInteger)menuIndex;

- (void)selectionView:(SSJCaterotyMenuSelectionView *)selectionView didSelectItemAtIndexPath:(SSJCaterotyMenuSelectionViewIndexPath *)indexPath;

@end

@interface SSJCaterotyMenuSelectionView : UIView

// 只有top、bottom有效
@property (nonatomic) UIEdgeInsets contentInsets;

// default NO
@property (nonatomic) BOOL needToCacheData;

@property (nonatomic, weak) id<SSJCaterotyMenuSelectionViewDataSource> dataSource;

@property (nonatomic, weak) id<SSJCaterotyMenuSelectionViewDelegate> delegate;

@property (nonatomic, strong) SSJCaterotyMenuSelectionViewIndexPath *selectedIndexPath;

- (void)setSelectedIndexPath:(SSJCaterotyMenuSelectionViewIndexPath *)selectedIndexPath animated:(BOOL)animated;

- (void)reloadAllData;

- (void)updateAppearanceAccordingToTheme;

- (SSJCaterotyMenuSelectionCellItem *)itemAtIndexPath:(SSJCaterotyMenuSelectionViewIndexPath *)indexPath;

@end



@interface SSJCaterotyMenuSelectionCellItem : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, strong) UIImage *icon;

@property (nonatomic, strong) UIColor *color;

+ (instancetype)itemWithTitle:(NSString *)title icon:(UIImage *)icon color:(UIColor *)color;

@end



@interface SSJCaterotyMenuSelectionViewIndexPath : NSObject

@property (nonatomic, readonly) NSInteger menuIndex;

@property (nonatomic, readonly) NSInteger categoryIndex;

@property (nonatomic, readonly) NSInteger itemIndex;

+ (instancetype)indexPathWithMenuIndex:(NSInteger)menuIndex categoryIndex:(NSInteger)categoryIndex itemIndex:(NSInteger)itemIndex;

@end

NS_ASSUME_NONNULL_END
