//
//  SSJThemePlugin.h
//  SuiShouJi
//
//  Created by old lang on 16/7/8.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSJCustomThemeManager : NSObject

+ (void)initializeCustomTheme;

+ (void)changeThemeWithDefaultImageName:(NSString *)name type:(BOOL)type;

+ (void)changeThemeWithLocalImage:(UIImage *)image type:(BOOL)type;

@end
