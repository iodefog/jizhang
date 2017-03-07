//
//  SSJFinancingDetailHeadeView.h
//  SuiShouJi
//
//  Created by ricky on 2017/3/7.
//  Copyright © 2017年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSJFinancingGradientColorItem.h"

NS_ASSUME_NONNULL_BEGIN

@class SSJFinancingDetailHeadeView;
@class SSJFinancingDetailHeadeViewCellItem;

@protocol SSJFinancingDetailHeadeViewDataSource <NSObject>

@required
- (NSUInteger)numberOfRowsInSeparatorFormView:(SSJFinancingDetailHeadeView *)view;

- (NSUInteger)separatorFormView:(SSJFinancingDetailHeadeView *)view numberOfCellsInRow:(NSUInteger)row;

- (nullable SSJFinancingDetailHeadeViewCellItem *)separatorFormView:(SSJFinancingDetailHeadeView *)view itemForCellAtIndex:(NSIndexPath *)index;

@end

@interface SSJFinancingDetailHeadeView : UIView

@property (nonatomic, weak, nullable) id<SSJFinancingDetailHeadeViewDataSource> dataSource;

@property (nonatomic, strong, nullable) UIColor *separatorColor;

@property (nonatomic) UIEdgeInsets horizontalSeparatorInset;

@property (nonatomic) UIEdgeInsets verticalSeparatorInset;

@property(nonatomic, strong) SSJFinancingGradientColorItem *colorItem;

- (void)reloadData;

- (void)showTopLoadingIndicatorAtRowIndex:(NSUInteger)rowIndex cellIndex:(NSUInteger)cellIndex;

- (void)hideTopLoadingIndicatorAtRowIndex:(NSUInteger)rowIndex cellIndex:(NSUInteger)cellIndex;

- (void)showBottomLoadingIndicatorAtRowIndex:(NSUInteger)rowIndex cellIndex:(NSUInteger)cellIndex;

- (void)hideBottomLoadingIndicatorAtRowIndex:(NSUInteger)rowIndex cellIndex:(NSUInteger)cellIndex;

@end

@interface SSJFinancingDetailHeadeViewCellItem : NSObject

@property (nonatomic, copy, nullable) NSString *topTitle;

@property (nonatomic, copy, nullable) NSString *bottomTitle;

@property (nonatomic, strong, nullable) UIColor *topTitleColor;

@property (nonatomic, strong, nullable) UIColor *bottomTitleColor;

@property (nonatomic, strong, nullable) UIFont *topTitleFont;

@property (nonatomic, strong, nullable) UIFont *bottomTitleFont;

@property (nonatomic) UIEdgeInsets contentInsets;

+ (instancetype)itemWithTopTitle:(NSString *)topTitle
                     bottomTitle:(NSString *)bottomTitle
                   topTitleColor:(UIColor *)topTitleColor
                bottomTitleColor:(UIColor *)bottomTitleColor
                    topTitleFont:(UIFont *)topTitleFont
                 bottomTitleFont:(UIFont *)bottomTitleFont
                   contentInsets:(UIEdgeInsets)contentInsets;

@end

NS_ASSUME_NONNULL_END
