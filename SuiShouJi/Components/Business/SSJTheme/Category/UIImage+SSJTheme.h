//
//  UIImage+SSJTheme.h
//  SuiShouJi
//
//  Created by old lang on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SSJTheme)

+ (instancetype)ssj_themeImageWithName:(NSString *)name;

+ (instancetype)ssj_themeImageWithName:(NSString *)name renderingMode:(UIImageRenderingMode)mode;

+ (instancetype)ssj_compatibleThemeImageNamed:(NSString *)name;

+ (instancetype)ssj_themeLocalBackGroundImage;

+ (NSCache *)memoCache;

@end
