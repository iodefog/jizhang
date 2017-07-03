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


// 当前皮肤最新版本号
static const int kCustomThemeVersion = 2;

@implementation SSJCustomThemeManager
    
+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializeCustomTheme) name:UIApplicationDidFinishLaunchingNotification object:nil];
}


+ (void)initializeCustomTheme {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *firstThemeDirectPath = [[NSString ssj_themeDirectory] stringByAppendingPathComponent:@"1000"];
        NSString *secondThemeDirectPath = [[NSString ssj_themeDirectory] stringByAppendingPathComponent:@"1001"];
        
        NSString *currentThemeId = SSJCurrentThemeID();
        NSString *currentBackGround = SSJ_CURRENT_THEME.customThemeBackImage;
        
        if ([[SSJThemeSetting ThemeModelForModelId:@"1000"].version integerValue] < kCustomThemeVersion || [[SSJThemeSetting ThemeModelForModelId:@"1001"].version integerValue] < kCustomThemeVersion) {
            [[NSFileManager defaultManager] removeItemAtPath:firstThemeDirectPath error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:secondThemeDirectPath error:nil];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:firstThemeDirectPath] && ![[NSFileManager defaultManager] fileExistsAtPath:secondThemeDirectPath]) {
            // 将两个主题解压和背景图
            NSString *firstThemePath = [[NSBundle mainBundle] pathForResource:@"1001" ofType:@"zip"];
            NSString *secondThemePath = [[NSBundle mainBundle] pathForResource:@"1000" ofType:@"zip"];
            
            [SSZipArchive unzipFileAtPath:firstThemePath toDestination:[NSString ssj_themeDirectory] overwrite:YES password:nil error:nil];
            [SSZipArchive unzipFileAtPath:secondThemePath toDestination:[NSString ssj_themeDirectory] overwrite:YES password:nil error:nil];
            
            // 将两个默认主题写入主题配置文件中
            NSData *firstThemeData = [NSData dataWithContentsOfFile:[firstThemeDirectPath stringByAppendingPathComponent:@"themeSettings.json"]];
            NSData *secondThemeData = [NSData dataWithContentsOfFile:[secondThemeDirectPath stringByAppendingPathComponent:@"themeSettings.json"]];
            NSDictionary *firstDic = [NSJSONSerialization JSONObjectWithData:firstThemeData options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *secondDic = [NSJSONSerialization JSONObjectWithData:secondThemeData options:NSJSONReadingMutableContainers error:nil];
            SSJThemeModel *firstModel = [SSJThemeModel mj_objectWithKeyValues:firstDic];
            SSJThemeModel *secondModel = [SSJThemeModel mj_objectWithKeyValues:secondDic];
            if ([currentThemeId isEqualToString:@"1000"]) {
                firstModel.customThemeBackImage = currentBackGround;
            } else {
                secondModel.customThemeBackImage = currentBackGround;
            }
            [SSJThemeSetting addThemeModel:firstModel];
            [SSJThemeSetting addThemeModel:secondModel];
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:[[NSString ssj_themeDirectory] stringByAppendingPathComponent:@"customBackGround"]]) {
            //        [[NSFileManager defaultManager] createDirectoryAtPath:[[NSString ssj_themeDirectory] stringByAppendingPathComponent:@"customBackGround"] withIntermediateDirectories:YES attributes:nil error:nil];
            NSString *themeBackPath = [[NSBundle mainBundle] pathForResource:@"customBackGround" ofType:@"zip"];
            NSError *error = nil;
            [SSZipArchive unzipFileAtPath:themeBackPath toDestination:[NSString ssj_themeDirectory] overwrite:YES password:nil error:&error];
        }
    });
}

+ (void)changeThemeWithDefaultImageName:(NSString *)name type:(BOOL)type{
    NSString *themeId = [[name componentsSeparatedByString:@"_"] objectAtIndex:1];
    
    if (!type) {
        SSJSetCurrentThemeID(@"1001");
    } else {
        SSJSetCurrentThemeID(@"1000");
    }
    
    [SSJThemeSetting updateTabbarAppearance];
    
    SSJThemeModel *model = [SSJThemeSetting currentThemeModel];
    model.customThemeBackImage = themeId;
    model.darkOrLight = type;
    [SSJThemeSetting addThemeModel:model];
    
//    NSString *backGroudImageFullName = themeId;
//    NSString *backGroudImageName;
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//        CGSize screenSize = [UIScreen mainScreen].bounds.size;
//        if (CGSizeEqualToSize(screenSize, CGSizeMake(320.0, 568.0))) {
//            backGroudImageFullName = [NSString stringWithFormat:@"%@-568",themeId];
//            backGroudImageName = [NSString stringWithFormat:@"%@-568@2x",@"background"];
//        } else if (CGSizeEqualToSize(screenSize, CGSizeMake(375.0, 667.0))) {
//            backGroudImageFullName = [NSString stringWithFormat:@"%@-667",themeId];
//            backGroudImageName = [NSString stringWithFormat:@"%@-667@2x",@"background"];
//        } else {
//            backGroudImageFullName = themeId;
//            backGroudImageName = [NSString stringWithFormat:@"%@@%dx", @"background", (int)[UIScreen mainScreen].scale];
//        }
//    }
//    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        CGSize screenSize = [UIScreen mainScreen].bounds.size;
//        if (CGSizeEqualToSize(screenSize, CGSizeMake(768.0, 1024.0))) {
//            imageName = [NSString stringWithFormat:@"%@-1024",name];
//        } else if (CGSizeEqualToSize(screenSize, CGSizeMake(1536.0, 2048.0))) {
//            imageName = [NSString stringWithFormat:@"%@-2048",name];
//        }
//    }
//    UIImage *backImage = [UIImage imageNamed:backGroudImageFullName];
//    if (!backImage) {
//        SSJPRINT(@"图片名称不正确");
//    }
//    NSString *currentThemeID = [SSJThemeSetting currentThemeModel].ID;
//    NSString *imagePath = [[[[NSString ssj_themeDirectory] stringByAppendingPathComponent:currentThemeID] stringByAppendingPathComponent:@"Img"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",backGroudImageName]];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
//        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
//        [[UIImage memoCache] removeObjectForKey:imagePath];
//    }
//    [UIImagePNGRepresentation(backImage) writeToFile:imagePath atomically:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SSJThemeDidChangeNotification object:nil userInfo:nil];
}

+ (void)changeThemeWithLocalImage:(UIImage *)image type:(BOOL)type {
    
    if (!type) {
        SSJSetCurrentThemeID(@"1001");
    } else {
        SSJSetCurrentThemeID(@"1000");
    }
    
    [SSJThemeSetting updateTabbarAppearance];
    
    SSJThemeModel *model = [SSJThemeSetting currentThemeModel];
    model.customThemeBackImage = @"background";
    model.darkOrLight = type;
    [SSJThemeSetting addThemeModel:model];
    
    NSString *backGroudImageName;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        if (CGSizeEqualToSize(screenSize, CGSizeMake(320.0, 568.0))) {
            backGroudImageName = [NSString stringWithFormat:@"%@-568@2x",@"background"];
        } else if (CGSizeEqualToSize(screenSize, CGSizeMake(375.0, 667.0))) {
            backGroudImageName = [NSString stringWithFormat:@"%@-667@2x",@"background"];
        } else {
            backGroudImageName = [NSString stringWithFormat:@"%@@%dx", @"background", (int)[UIScreen mainScreen].scale];
        }
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        if (CGSizeEqualToSize(screenSize, CGSizeMake(768.0, 1024.0))) {
            backGroudImageName = [NSString stringWithFormat:@"%@-1024",@"background"];
        } else if (CGSizeEqualToSize(screenSize, CGSizeMake(1536.0, 2048.0))) {
            backGroudImageName = [NSString stringWithFormat:@"%@-2048",@"background"];
        }
    }
    if (image) {
        NSString *backImageFolder = [[NSString ssj_themeDirectory] stringByAppendingPathComponent:@"customBackGround"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:backImageFolder]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:backImageFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
//        NSString *currentThemeID = [SSJThemeSetting currentThemeModel].ID;
        NSString *imagePath = [backImageFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",backGroudImageName]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
            [[UIImage ssj_memoCache] removeObjectForKey:imagePath];
        }
        
        [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:SSJThemeDidChangeNotification object:nil userInfo:nil];
}

@end


