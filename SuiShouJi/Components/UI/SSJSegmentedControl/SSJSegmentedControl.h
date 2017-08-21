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

//  标题字体
@property (nonatomic, strong) UIFont *font;

//  边框颜色、标题默认颜色
@property (null_resettable, nonatomic, strong) UIColor *borderColor;

@property (null_resettable, nonatomic, strong) UIColor *selectedBorderColor;

/**选中的背景颜色*/
@property (null_resettable, nonatomic, strong) UIColor *selectedbgColor;

/**
 *  指定初始化化方法
 *
 *  @param items 标题数组
 *  @return (instancetype) 返回实例对象
 */
- (nullable instancetype)initWithItems:(nullable NSArray<NSString *> *)items;

/**
 *  返回下标对应的标题
 *
 *  @param segment 下表
 *  @return (NSString *) 标题
 */
- (nullable NSString *)titleForSegmentAtIndex:(NSUInteger)segment;

/**
 *  设置对应状态下的文本属性，attributes中存储相应的属性，目前只有文本颜色NSForegroundColorAttributeName有效
 *
 *  @param attributes 存储文本属性的字典
 *  @param state 相应的状态
 */
- (void)setTitleTextAttributes:(nullable NSDictionary *)attributes forState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END
