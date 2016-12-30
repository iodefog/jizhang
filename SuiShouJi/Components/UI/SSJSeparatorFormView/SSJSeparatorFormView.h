//
//  SSJSeparatorFormView.h
//  SuiShouJi
//
//  Created by old lang on 16/11/7.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SSJSeparatorFormView;
@class SSJSeparatorFormViewCellItem;

@protocol SSJSeparatorFormViewDataSource <NSObject>

@required
- (NSUInteger)numberOfRowsInSeparatorFormView:(SSJSeparatorFormView *)view;

- (NSUInteger)separatorFormView:(SSJSeparatorFormView *)view numberOfCellsInRow:(NSUInteger)row;

- (nullable SSJSeparatorFormViewCellItem *)separatorFormView:(SSJSeparatorFormView *)view itemForCellAtIndex:(NSIndexPath *)index;

@end

@interface SSJSeparatorFormView : UIView

@property (nonatomic, weak, nullable) id<SSJSeparatorFormViewDataSource> dataSource;

@property (nonatomic, strong, nullable) UIColor *separatorColor;

@property (nonatomic) UIEdgeInsets horizontalSeparatorInset;

@property (nonatomic) UIEdgeInsets verticalSeparatorInset;

- (void)reloadData;

- (void)showTopLoadingIndicatorAtRowIndex:(NSUInteger)rowIndex cellIndex:(NSUInteger)cellIndex;

- (void)hideTopLoadingIndicatorAtRowIndex:(NSUInteger)rowIndex cellIndex:(NSUInteger)cellIndex;

- (void)showBottomLoadingIndicatorAtRowIndex:(NSUInteger)rowIndex cellIndex:(NSUInteger)cellIndex;

- (void)hideBottomLoadingIndicatorAtRowIndex:(NSUInteger)rowIndex cellIndex:(NSUInteger)cellIndex;

@end

@interface SSJSeparatorFormViewCellItem : NSObject

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
