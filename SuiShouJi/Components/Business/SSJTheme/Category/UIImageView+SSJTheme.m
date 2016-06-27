//
//  UIImageView+SSJTheme.m
//  SuiShouJi
//
//  Created by old lang on 16/6/27.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "UIImageView+SSJTheme.h"
#import "NSString+SSJTheme.h"
#import "UIImage+SSJTheme.h"
#import "SSJThemeConst.h"

@implementation UIImageView (SSJTheme)

- (void)ssj_setThemeImageWithName:(NSString *)name {
    self.image = [UIImage ssj_themeImageWithName:name];
}

@end
