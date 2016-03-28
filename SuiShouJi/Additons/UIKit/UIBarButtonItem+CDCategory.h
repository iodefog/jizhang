//
//  UIBarButtonItem+CDCategory.h
//  CDAppDemo
//
//  Created by cdd on 15/11/13.
//  Copyright © 2015年 Cheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (CDCategory)

+ (UIBarButtonItem *)barButtonWidth:(CGFloat)width Title:(NSString *)title ImageName:(NSString *)imageName Target:(id)target Action:(SEL)action;

@end
