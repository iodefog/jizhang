//
//  UIImage+SSJTheme.m
//  SuiShouJi
//
//  Created by old lang on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "UIImage+SSJTheme.h"
#import "NSString+SSJTheme.h"

@implementation UIImage (SSJTheme)

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCache) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

+ (void)clearCache {
    [[self memoCache] removeAllObjects];
}

+ (NSCache *)memoCache {
    static NSCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!cache) {
            cache = [[NSCache alloc] init];
        }
    });
    return cache;
}

+ (instancetype)ssj_themeImageWithName:(NSString *)name {
    
    NSString *themeID = SSJCurrentThemeID();
    
    // 如果是默认主题，就从bundle中读图片；反之，从相应的沙盒目录中读取图片
    if ([themeID isEqualToString:SSJDefaultThemeID]) {
        UIImage *image = [UIImage imageNamed:name];
        return image;
    }
    
    // 按照屏幕分辨率拼接图片名称，例如：320x640 imgName.png；640x960 imgName@2x.png；1242x2208 imgName@3x.png
    NSString *imgName = name;
    if ([UIScreen mainScreen].scale == 2 || [UIScreen mainScreen].scale == 3) {
        imgName = [NSString stringWithFormat:@"%@@%dx.png", name, (int)[UIScreen mainScreen].scale];
    }
    
    NSString *imagePath = [[NSString ssj_themeDirectory] stringByAppendingPathComponent:themeID];
    imagePath = [imagePath stringByAppendingPathComponent:@"Img"];
    imagePath = [imagePath stringByAppendingPathComponent:imgName];
    
    UIImage *image = [[self memoCache] objectForKey:imagePath];
    if (image) {
        return image;
    }
    
    image = [UIImage imageWithContentsOfFile:imagePath];
    if (image) {
        [[self memoCache] setObject:image forKey:imagePath];
    } else {
        SSJPRINT(@"imge在指定路径下不存在 %@", imagePath);
        image = [UIImage imageNamed:name];
    }
    
    return image;
}

+ (instancetype)ssj_themeImageWithName:(NSString *)name renderingMode:(UIImageRenderingMode)mode {
    return [[self ssj_themeImageWithName:name] imageWithRenderingMode:mode];
}

+ (instancetype)ssj_compatibleThemeImageNamed:(NSString *)name {
    NSString *imageName = [name stringByDeletingPathExtension];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        if (CGSizeEqualToSize(screenSize, CGSizeMake(320.0, 568.0))) {
            imageName = [NSString stringWithFormat:@"%@-568",imageName];
        } else if (CGSizeEqualToSize(screenSize, CGSizeMake(375.0, 667.0))) {
            imageName = [NSString stringWithFormat:@"%@-667",imageName];
        }
    }
    
    return [self ssj_themeImageWithName:imageName];
}

+ (instancetype)ssj_themeLocalBackGroundImageName:(NSString *)name {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        if (CGSizeEqualToSize(screenSize, CGSizeMake(320.0, 568.0))) {
            name = [NSString stringWithFormat:@"%@-568",name];
        } else if (CGSizeEqualToSize(screenSize, CGSizeMake(375.0, 667.0))) {
            name = [NSString stringWithFormat:@"%@-667",name];
        }
        
        if ([UIScreen mainScreen].scale == 2 || [UIScreen mainScreen].scale == 3) {
            name = [NSString stringWithFormat:@"%@@%dx.png", name, (int)[UIScreen mainScreen].scale];
        }
    }

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        if (CGSizeEqualToSize(screenSize, CGSizeMake(768.0, 1024.0))) {
            name = [NSString stringWithFormat:@"%@-1024.png",name];
        } else if (CGSizeEqualToSize(screenSize, CGSizeMake(1536.0, 2048.0))) {
            name = [NSString stringWithFormat:@"%@-2048.png",name];
        }
    }
    
    NSString *imagePath = [[NSString ssj_themeDirectory] stringByAppendingPathComponent:@"customBackGround"];
    imagePath = [imagePath stringByAppendingPathComponent:name];
    UIImage *image = [[self memoCache] objectForKey:imagePath];
    if (image) {
        return image;
    }
    
    image = [UIImage imageWithContentsOfFile:imagePath];
    if (image) {
        [[self memoCache] setObject:image forKey:imagePath];
    } else {
        SSJPRINT(@"imge在指定路径下不存在 %@", imagePath);
        image = [UIImage imageNamed:name];
    }
    
    return image;
}
@end
