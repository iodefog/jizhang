//
//  SSJReportFormsPercentCircle.h
//  SuiShouJi
//
//  Created by old lang on 15/12/28.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SSJPercentCircleView;
@class SSJPercentCircleViewItem;

@protocol SSJReportFormsPercentCircleDataSource <NSObject>

@required

/**
 返回多少个圆环组件

 @param circle 圆环控件
 @return 组件个数
 */
- (NSUInteger)numberOfComponentsInPercentCircle:(SSJPercentCircleView *)circle;

/**
 返回对应下标的圆环组件模型；根据组建模型创建组件

 @param circle 圆环控件
 @param index 组建对应的下标
 @return 组件模型
 */
- (SSJPercentCircleViewItem *)percentCircle:(SSJPercentCircleView *)circle itemForComponentAtIndex:(NSUInteger)index;

@end

@interface SSJPercentCircleView : UIView

/**
 标准的初始化方法

 @param frame 大小、位置
 @param radius 圆环半径
 @param thickness 圆环厚度
 @param lineLength1 折线第一个线段长度
 @param lineLength2 折线第二个线段长度
 @return 圆环控件
 */
- (instancetype)initWithFrame:(CGRect)frame
                       radius:(CGFloat)radius
                    thickness:(CGFloat)thickness
                  lineLength1:(CGFloat)lineLength1
                  lineLength2:(CGFloat)lineLength2;

/**
 圆环半径（注意：包含了厚度）
 */
@property (nonatomic, readonly) CGFloat radius;

/**
 圆环厚度
 */
@property (nonatomic, readonly) CGFloat thickness;

/**
 折线第一个线段长度
 */
@property (nonatomic, readonly) CGFloat lineLength1;

/**
 折线第二个线段长度
 */
@property (nonatomic, readonly) CGFloat lineLength2;

/**
 起始角度，默认0
 */
@property (nonatomic) CGFloat startAngle;

/**
 圆环中间顶部标题和底部标题之间间隔
 */
@property (nonatomic) CGFloat gapBetweenTitles;

/**
 圆环中间顶部标题
 */
@property (nonatomic, copy, nullable) NSString *topTitle;

/**
 圆环中间底部标题
 */
@property (nonatomic, copy, nullable) NSString *bottomTitle;

/**
 圆环中间顶部标题样式，只有NSFontAttributeName、NSForegroundColorAttributeName有效
 */
@property (nonatomic, copy, nullable) NSDictionary *topTitleAttribute;

/**
 圆环中间底部标题样式，只有NSFontAttributeName、NSForegroundColorAttributeName有效
 */
@property (nonatomic, copy, nullable) NSDictionary *bottomTitleAttribute;

/**
 圆环周围的文字字体，默认系统12号字；如果percentCircle:itemForComponentAtIndex:返回的SSJPercentCircleViewItem对象中设置了font，就会忽略此属性
 */
@property (nonatomic, strong, nullable) UIFont *addtionTextFont;

/**
 圆环周围的文字颜色，默认light gray
 */
@property (nonatomic, strong, nullable) UIColor *addtionTextColor;

/**
 数据源协议
 */
@property (nonatomic, weak) id <SSJReportFormsPercentCircleDataSource> dataSource;

/**
 重载数据；此方法会触发numberOfComponentsInPercentCircle:和percentCircle:itemForComponentAtIndex:
 */
- (void)reloadData;

@end


@interface SSJPercentCircleViewItem : NSObject

// 圆环组件比例值，在0～1之间
@property (nonatomic) double scale;

// 圆环组件颜色
@property (nonatomic, strong) UIColor *color;

// 附加文本
@property (nonatomic, copy) NSString *text;

@end

NS_ASSUME_NONNULL_END

