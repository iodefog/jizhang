//
//  SSJThemePlugin.m
//  SuiShouJi
//
//  Created by old lang on 16/7/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJCustomThemeManager.h"
#import "SSJCustomKeyboard.h"
#import "SSZipArchive.h"
#import "SSJThemeModel.h"

@implementation SSJCustomThemeManager

+ (void)initializeCustomTheme {
    NSString *firstThemeDirectPath = [[NSString ssj_themeDirectory] stringByAppendingPathComponent:@"1000"];
    NSString *secondThemeDirectPath = [[NSString ssj_themeDirectory] stringByAppendingPathComponent:@"1001"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:firstThemeDirectPath] && ![[NSFileManager defaultManager] fileExistsAtPath:secondThemeDirectPath]) {
        // 将两个主题解压
        NSString *firstThemePath = [[NSBundle mainBundle] pathForResource:@"1001" ofType:@"zip"];
        NSString *secondThemePath = [[NSBundle mainBundle] pathForResource:@"1000" ofType:@"zip"];
        [SSZipArchive unzipFileAtPath:firstThemePath toDestination:[NSString ssj_themeDirectory] overwrite:NO password:nil error:nil];
        [SSZipArchive unzipFileAtPath:secondThemePath toDestination:[NSString ssj_themeDirectory] overwrite:NO password:nil error:nil];
        // 将两个默认主题写入主题配置文件中
        NSData *firstThemeData = [NSData dataWithContentsOfFile:[firstThemeDirectPath stringByAppendingPathComponent:@"themeSettings.json"]];
        NSData *secondThemeData = [NSData dataWithContentsOfFile:[secondThemeDirectPath stringByAppendingPathComponent:@"themeSettings.json"]];
        NSDictionary *firstDic = [NSJSONSerialization JSONObjectWithData:firstThemeData options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *secondDic = [NSJSONSerialization JSONObjectWithData:secondThemeData options:NSJSONReadingMutableContainers error:nil];
        SSJThemeModel *firstModel = [SSJThemeModel mj_objectWithKeyValues:firstDic];
        SSJThemeModel *secondModel = [SSJThemeModel mj_objectWithKeyValues:secondDic];
        [SSJThemeSetting addThemeModel:firstModel];
        [SSJThemeSetting addThemeModel:secondModel];
    }
}

+ (void)changeThemeWithDefaultImageName:(NSString *)name {
    NSString *themeId = [[name componentsSeparatedByString:@"_"] objectAtIndex:1];
    if ([name hasSuffix:@"light"]) {
        SSJSetCurrentThemeID(@"1001");
    } else if ([name hasSuffix:@"dark"]) {
        SSJSetCurrentThemeID(@"1000");
    }
    NSString *backGroudImageFullName = themeId;
    NSString *backGroudImageName;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        if (CGSizeEqualToSize(screenSize, CGSizeMake(320.0, 568.0))) {
            backGroudImageFullName = [NSString stringWithFormat:@"%@-568",themeId];
            backGroudImageName = [NSString stringWithFormat:@"%@-568@2x",@"background"];
        } else if (CGSizeEqualToSize(screenSize, CGSizeMake(375.0, 667.0))) {
            backGroudImageFullName = [NSString stringWithFormat:@"%@-667",themeId];
            backGroudImageName = [NSString stringWithFormat:@"%@-667@2x",@"background"];
        } else {
            backGroudImageFullName = [NSString stringWithFormat:@"%@@%dx", themeId, (int)[UIScreen mainScreen].scale];
            backGroudImageName = [NSString stringWithFormat:@"%@@%dx", @"background", (int)[UIScreen mainScreen].scale];

        }
    }
    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        CGSize screenSize = [UIScreen mainScreen].bounds.size;
//        if (CGSizeEqualToSize(screenSize, CGSizeMake(768.0, 1024.0))) {
//            imageName = [NSString stringWithFormat:@"%@-1024",name];
//        } else if (CGSizeEqualToSize(screenSize, CGSizeMake(1536.0, 2048.0))) {
//            imageName = [NSString stringWithFormat:@"%@-2048",name];
//        }
//    }
    UIImage *backImage = [UIImage imageNamed:backGroudImageFullName];
    if (!backImage) {
        SSJPRINT(@"图片名称不正确");
    }
    NSString *currentThemeID = [SSJThemeSetting currentThemeModel].ID;
    NSString *imagePath = [[[[NSString ssj_themeDirectory] stringByAppendingPathComponent:currentThemeID] stringByAppendingPathComponent:@"Img"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",backGroudImageName]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        [[UIImage memoCache] removeObjectForKey:imagePath];
    }
    [UIImagePNGRepresentation(backImage) writeToFile:imagePath atomically:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SSJThemeDidChangeNotification object:nil userInfo:nil];
}

+ (void)changeThemeWithLocalImage:(UIImage *)image {

}

@end


