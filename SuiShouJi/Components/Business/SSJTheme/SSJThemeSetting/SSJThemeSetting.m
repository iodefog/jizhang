//
//  SSJThemeSetting.m
//  SuiShouJi
//
//  Created by old lang on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeSetting.h"
#import "SSJThemeModel.h"
#import "NSString+SSJTheme.h"

static NSString *const SSJThemeSettingListKey = @"SSJThemeSettingListKey";
static NSString *const SSJCurrentThemeIDKey = @"SSJCurrentThemeIDKey";

@implementation SSJThemeSetting

+ (BOOL)addThemeModel:(SSJThemeModel *)model {
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:model forKey:model.ID];
    [archiver finishEncoding];
    return [data writeToFile:[self settingFilePath] atomically:YES];
}

+ (BOOL)switchToThemeID:(NSString *)ID {
    if (!ID.length) {
        return NO;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:ID forKey:SSJCurrentThemeIDKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

+ (SSJThemeModel *)currentThemeModel {
    NSString *themeID = [[NSUserDefaults standardUserDefaults] objectForKey:SSJCurrentThemeIDKey];
    if (themeID.length) {
        NSKeyedUnarchiver *unarchiver = [NSKeyedUnarchiver unarchiveObjectWithFile:[self settingFilePath]];
        SSJThemeModel *model = [unarchiver decodeObjectForKey:themeID];
        if (model) {
            return model;
        }
    }
    
    return [self defaultThemeModel];
}

+ (NSArray *)allThemeModels {
    NSData *data = [NSData dataWithContentsOfFile:[self settingFilePath]];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSArray *models = [unarchiver decodeObjectForKey:SSJThemeSettingListKey];
    if (models) {
        return models;
    }
    
    return [NSArray arrayWithObject:[self defaultThemeModel]];
}

+ (NSString *)settingFilePath {
    NSString *settingPath = [[NSString ssj_themeDirectory] stringByAppendingString:@"settings"];
    return settingPath;
}

+ (SSJThemeModel *)defaultThemeModel {
    SSJThemeModel *model = [[SSJThemeModel alloc] init];
    return model;
}

@end
