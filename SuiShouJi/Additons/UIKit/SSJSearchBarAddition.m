//
//  SSJSearchBarAddition.m
//  SuiShouJi
//
//  Created by ricky on 16/9/29.
//  Copyright © 2016年 ___9188___. All rights reserved.
//

#import "SSJSearchBarAddition.h"

@implementation UISearchBar (SSJCategory)

- (UIView *)searchBackgroundView {
    for (UIView *view in self.subviews) {
        // for before iOS7.0
        if ([view isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            return (view);
        }
        // for later iOS7.0(include)
        if ([view isKindOfClass:NSClassFromString(@"UIView")] && view.subviews.count > 0) {
            return ([view.subviews firstObject]);
        }
    }
    return (nil);
}

- (UITextField *)searchTextFieldView {
    for(UIView *view in self.subviews) {
        if([view isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
            return ((UITextField *)view);
        }
        for(UIView *subview in view.subviews) {
            if([subview isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
                return ((UITextField *)subview);
            }
        }
    }
    return (nil);
}

@end
