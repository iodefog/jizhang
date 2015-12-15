//
//  SSJLayerAddition.h
//  MoneyMore
//
//  Created by old lang on 15-3-25.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface CALayer (SSJCategory)

//  左边间距
@property (nonatomic) CGFloat left;

//  顶部间距
@property (nonatomic) CGFloat top;

//  右边间距
@property (nonatomic) CGFloat right;

//  底部间距
@property (nonatomic) CGFloat bottom;

//  宽度
@property (nonatomic) CGFloat width;

//  高度
@property (nonatomic) CGFloat height;

//  原点
@property (nonatomic) CGPoint origin;

//  大小
@property (nonatomic) CGSize size;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

//  边框线类型
typedef NS_OPTIONS(NSUInteger, SSJBorderStyle) {
    SSJBorderStyleleNone  = 0,      //  没有边框线
    SSJBorderStyleTop     = 1 << 0, //  顶部边框线
    SSJBorderStyleLeft    = 1 << 1, //  左边边框线
    SSJBorderStyleBottom  = 1 << 2, //  底部边框线
    SSJBorderStyleRight   = 1 << 3, //  右边边框线
    SSJBorderStyleAll     = SSJBorderStyleTop | SSJBorderStyleLeft | SSJBorderStyleBottom | SSJBorderStyleRight //  所有边框线
};

@interface SSJBorderLayer : CALayer

//  边框线类型
@property (nonatomic, assign) SSJBorderStyle customBorderStyle;

//  边框线宽度 dufault 1.0
@property (nonatomic, assign) CGFloat customBorderWidth;

//  边框线颜色 default black
@property (nonatomic, strong) UIColor *customBorderColor;

//  边框线内凹
@property (nonatomic, assign) UIEdgeInsets borderInsets;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface CALayer (SSJScreenshot)

/**
 *  返回当前视图的截图
 *
 *  @return (UIImage *)
 */
- (UIImage *)ssj_takeScreenShot;

/**
 *  返回当前视图的截图
 *
 *  @param size 图片大小
 *  @param opaque  是否完全不透明
 *  @param scale  图片比率因素，值越大图片越清晰，如果为0，自动设置成主屏幕的比率
 *
 *  @return (UIImage *)
 */
- (UIImage *)ssj_takeScreenShotWithSize:(CGSize)size opaque:(BOOL)opaque scale:(CGFloat)scale;

@end
