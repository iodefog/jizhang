//
//  SSJThemeSetting.h
//  SuiShouJi
//
//  Created by old lang on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSJThemeSetting : NSObject

+ (BOOL)addThemeModel:(SSJThemeModel *)model;

+ (BOOL)removeThemeModelWithID:(NSString *)ID;

+ (BOOL)switchToThemeID:(NSString *)ID;

+ (NSArray *)allThemeModels;

+ (SSJThemeModel *)currentThemeModel;

+ (SSJThemeModel *)defaultThemeModel;

+ (void)updateTabbarAppearance;

+ (SSJThemeModel *)ThemeModelForModelId:(NSString *)Id;

@end

NS_ASSUME_NONNULL_END
