//
//  SSJImageAddition.h
//  MoneyMore
//
//  Created by old lang on 15-3-27.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIImage (SSJColor)

/**
 *  改变图片颜色
 *
 *  @param color 图片要改变的颜色
 *
 *  @return (UIImage *) 改变颜色后的图片
 */
- (UIImage *)ssj_imageWithColor:(UIColor *)color;

/**
 *  颜色生成图片
 *
 *  @param color 颜色
 *  @param size  图片大小
 *
 *  @return (UIImage *)
 */
+ (UIImage *)ssj_imageWithColor:(UIColor *)color size:(CGSize)size;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIImage (SSJAdaptation)

/**
 *  返回用适配iphone5(5s)和iphone6的的UIImage对象，返回正确适配的图片，注意以下图片命名规则
 *  iphone4(4s) 640 × 960   imageName@2x.png    （系统命名规则）
 *  iphone5(5s) 640 × 1136  imageName-568@2x.png（自定义命名规则）
 *  iphone6     750 × 1334  imageName-667@2x.png（自定义命名规则）
 *  iphone6Plus 1242 × 2208 imageName@3x.png    （系统命名规则）
 *
 *  @param name 图片名称
 *
 *  @return (UIImage *)
 */
+ (UIImage *)ssj_compatibleImageNamed:(NSString *)name;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIImage (SSJResize)

/**
 *  按照比例压缩图片，使其大小在指定的size范围内
 *
 *  @param color 颜色
 *  @param size  图片大小
 *
 *  @return (UIImage *)
 */
- (UIImage *)ssj_compressWithinSize:(CGSize)size;

/**
 *  改变图片到指定大小
 *
 *  @param Size 要改变成的大小
 *
 *  @return (UIImage *) 缩放后的图片
 */
- (UIImage *)ssj_scaleImageWithSize:(CGSize)size;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIImage (SSJProcessing)

/**
 *  @brief 对图片做高斯模糊
 *
 *  @param radius 模糊半径，为0时不模糊,值越大越脱离原来外形(越看不出原来形状)
 *  @param iterations 模糊程度，为0时不模糊,值越大越模糊
 *  @param tintColor 模糊蒙版颜色,一般设为白色
 *
 *  @return (UIImage *) 高斯模糊后的图片
 */
- (UIImage *)ssj_blurredImageWithRadius:(CGFloat)radius iterations:(NSUInteger)iterations tintColor:(UIColor *)tintColor;

/**
 获取图片中某个点的颜色
 
 @param point 需要获取的位置
 @return (UIColor *)获取到的颜色
 */
- (UIColor *)ssj_getPixelColorAtLocation:(CGPoint)point;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIImage (SSJClip)

/**
 圆角图片
 */
- (UIImage *)ssj_circleImage;

/**
 将图片insets之外的区域裁剪掉
 
 @param insets 剪掉区域
 @return 裁剪后的图片
 */
- (UIImage *)ssj_imageWithClipInsets:(UIEdgeInsets)insets;

/**
 将图片insets之外的区域裁剪掉，并压缩成指定大小

 @param insets 剪掉区域
 @param size 裁剪后压缩成指定的大小
 @return 处理后的图片
 */
- (UIImage *)ssj_imageWithClipInsets:(UIEdgeInsets)insets toSize:(CGSize)size;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIImage (SSJAssets)

/**
 从assets中读取启动图片

 @return UIImage *
 */
+ (UIImage *)ssj_launchImage;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIImage (SSJLoad)

/**
 加载网络图片或者沙盒图片

 @param url 图片路径
 @param compeltion 加载完成的回调
 */
+ (void)ssj_loadUrl:(NSURL *)url compeltion:(void(^)(NSError *error, UIImage *image))compeltion;

@end

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIImage (SSJImageCompound)

+ (UIImage *)verticalImageFromArray:(NSArray *)imagesArray;

/**
 根据拍照图片的方向返回一张正确方向的图片

 @return <#return value description#>
 */
- (UIImage *)fixOrientation;
@end

