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
#import "SSJThemeConst.h"

@implementation SSJThemeSetting

+ (BOOL)addThemeModel:(SSJThemeModel *)model {
    NSDictionary *modelInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:[self settingFilePath]];
    NSMutableDictionary *newModelInfo = [NSMutableDictionary dictionaryWithCapacity:modelInfo.count + 1];
    [newModelInfo addEntriesFromDictionary:modelInfo];
    [newModelInfo setObject:model forKey:model.ID];
    
    return [NSKeyedArchiver archiveRootObject:newModelInfo toFile:[self settingFilePath]];
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
        NSDictionary *modelInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:[self settingFilePath]];
        SSJThemeModel *model = [modelInfo objectForKey:themeID];
        if (model) {
            return model;
        }
    }
    
    return [self defaultThemeModel];
}

+ (NSArray *)allThemeModels {
    NSDictionary *modelInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:[self settingFilePath]];
    return [modelInfo allValues];
}

+ (NSString *)settingFilePath {
    NSString *settingPath = [[NSString ssj_themeDirectory] stringByAppendingPathComponent:@"settings"];
    return settingPath;
}

+ (SSJThemeModel *)defaultThemeModel {
    SSJThemeModel *model = [[SSJThemeModel alloc] init];
    return model;
}

@end
