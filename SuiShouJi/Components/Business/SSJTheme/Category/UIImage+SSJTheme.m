//
//  UIImage+SSJTheme.m
//  SuiShouJi
//
//  Created by old lang on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "UIImage+SSJTheme.h"
#import "NSString+SSJTheme.h"
#import "SSJThemeConst.h"

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
    NSString *themeID = [[NSUserDefaults standardUserDefaults] objectForKey:SSJCurrentThemeIDKey];
    NSString *imagePath = [[NSString ssj_themeDirectory] stringByAppendingPathComponent:themeID];
    imagePath = [imagePath stringByAppendingPathComponent:name];
    
    UIImage *image = [[self memoCache] objectForKey:imagePath];
    if (image) {
        return image;
    }
    
    image = [UIImage imageWithContentsOfFile:imagePath];
    [[self memoCache] setObject:image forKey:imagePath];
    
    return image;
}

@end
