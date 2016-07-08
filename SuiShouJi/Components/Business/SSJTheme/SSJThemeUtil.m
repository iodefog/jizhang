//
//  SSJThemeUtil.m
//  SuiShouJi
//
//  Created by old lang on 16/7/6.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJThemeUtil.h"

NSString *const SSJThemeDidChangeNotification = @"SSJThemeDidChangeNotification";

static NSString *const SSJCurrentThemeIDKey = @"SSJCurrentThemeIDKey";

NSString *const SSJDefaultThemeID = @"0";

void SSJSetCurrentThemeID(NSString *ID) {
    [[NSUserDefaults standardUserDefaults] setObject:ID forKey:SSJCurrentThemeIDKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString *SSJCurrentThemeID(void) {
    NSString *themeID = [[NSUserDefaults standardUserDefaults] objectForKey:SSJCurrentThemeIDKey];
    if (themeID) {
        return themeID;
    } else {
        SSJSetCurrentThemeID(SSJDefaultThemeID);
        return SSJDefaultThemeID;
    }
}
