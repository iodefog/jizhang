//
//  SSJSegmentedControl.h
//  SuiShouJi
//
//  Created by old lang on 15/12/31.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSJSegmentedControl : UIControl

//  选中的下标
@property (nonatomic) NSUInteger selectedSegmentIndex;

//
@property (nonatomic, strong) UIFont *font;

//
@property (null_resettable, nonatomic, strong) UIColor *tintColor;

/**
 *  初始化化方法
 *
 *  @param items 标题数组
 *  @return (instancetype) 返回实例对象
 */
- (nullable instancetype)initWithItems:(nullable NSArray<NSString *> *)items;

/**
 *  根据错误返回相应的提示，如果没有对应的错误提示，就返回nil
 *
 *  @param error 错误
 *  @return (NSString *) 错误提示
 */
- (nullable NSString *)titleForSegmentAtIndex:(NSUInteger)segment;

/**
 *  根据错误返回相应的提示，如果没有对应的错误提示，就返回nil
 *
 *  @param error 错误
 *  @return (NSString *) 错误提示
 */
- (void)setTitleTextAttributes:(nullable NSDictionary *)attributes forState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END