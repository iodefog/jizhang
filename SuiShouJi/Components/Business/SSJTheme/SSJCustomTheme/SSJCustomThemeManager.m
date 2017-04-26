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

@implementation SSJCustomThemeManager

+ (void)initializeCustomTheme {
    NSString *firstThemeDirectPath = [[NSString ssj_themeDirectory] stringByAppendingPathComponent:@"1000"];
    NSString *secondThemeDirectPath = [[NSString ssj_themeDirectory] stringByAppendingPathComponent:@"1001"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:firstThemeDirectPath] && ![[NSFileManager defaultManager] fileExistsAtPath:secondThemeDirectPath]) {
        NSString *firstThemePath = [[NSBundle mainBundle] pathForResource:@"1001" ofType:@"zip"];
        NSString *secondThemePath = [[NSBundle mainBundle] pathForResource:@"1000" ofType:@"zip"];
        [SSZipArchive unzipFileAtPath:firstThemePath toDestination:[NSString ssj_themeDirectory] overwrite:NO password:nil error:nil];
        [SSZipArchive unzipFileAtPath:secondThemePath toDestination:[NSString ssj_themeDirectory] overwrite:NO password:nil error:nil];
    }
}




@end


