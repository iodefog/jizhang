//
//  SSJButtonAddition.h
//  MoneyMore
//
//  Created by old lang on 15-3-24.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

/**
 *  图片和标题布局方式，仅在图片和标题都存在的情况下有效
 */
typedef NS_ENUM(NSUInteger, SSJButtonLayoutType){
    /**
     *  默认，图片左标题右
     */
    SSJButtonLayoutTypeDefault = 0,
    /**
     *  图片右标题左
     */
    SSJButtonLayoutTypeImageRightTitleLeft,
    /**
     *  图片上标题下
     */
    SSJButtonLayoutTypeImageTopTitleBottom,
    /**
     *  图片下标题上
     */
    SSJButtonLayoutTypeImageBottomTitleTop
};

@interface UIButton (SSJContentLayout)

//  布局方式
@property (nonatomic, assign) SSJButtonLayoutType contentLayoutType;

//  标题和图片之间的距离
@property (nonatomic, assign) CGFloat spaceBetweenImageAndTitle;

//  重新调整标题和图片布局
- (void)ssj_layoutContent;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIButton (SSJBackgroundColor)

//  设置相应状态下的背景颜色
- (void)ssj_setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
