//
//  NSString+SSJTheme.m
//  SuiShouJi
//
//  Created by old lang on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "NSString+SSJTheme.h"

@implementation NSString (SSJTheme)

+ (NSString *)ssj_themeDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *directory = [docPath stringByAppendingPathComponent:@"theme"];
    
    BOOL isDirectory = YES;
    BOOL isExisted = [[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDirectory];
    if (!isExisted || !isDirectory) {
        NSError *error = nil;
        if ([[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error]) {
            SSJPRINT(@"创建主题包路径发生错误,error:%@", [error localizedDescription]);
            return nil;
        }
    }
    return directory;
}

@end
