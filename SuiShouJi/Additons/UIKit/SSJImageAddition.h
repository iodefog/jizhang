//
//  SSJImageAddition.h
//  MoneyMore
//
//  Created by old lang on 15-3-27.
//  Copyright (c) 2015年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+WebP.h"


@interface UIImage (SSJCategory)

/**
 *  返回用适配iphone5(5s)和iphone6的的UIImage对象，返回正确适配的图片，注意以下图片命名规则
 *  iphone4(4s) imageName@2x.png    （系统命名规则）
 *  iphone5(5s) imageName-568@2x.png（自定义命名规则）
 *  iphone6     imageName-667@2x.png（自定义命名规则）
 *  iphone6Plus imageName@3x.png    （系统命名规则）
 *
 *  @param name 图片名称
 *
 *  @return (UIImage *)
 */
+ (UIImage *)ssj_compatibleImageNamed:(NSString *)name;

/**
 *  颜色生成图片
 *
 *  @param color 颜色
 *  @param size  图片大小
 *
 *  @return (UIImage *)
 */
+ (UIImage *)ssj_imageWithColor:(UIColor *)color size:(CGSize)size;

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
 *  图片转换成webp格式
 *
 *  @param quality 图片的质量 [0, 100]
 *  @param alpha   图片透明度 [0, 1]
 *  @param completionBlock 完成的回调
 *  @param failureBlock    失败的回调
 */
-(void)ssj_convertToWebpImageWithquality:(CGFloat)quality alpha:(CGFloat)alpha completionBlock:(void (^)(NSData *result))completionBlock failureBlock:(void (^)(NSError *error))failureBlock;
@end

