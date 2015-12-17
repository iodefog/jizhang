//
//  cunstomtextfield.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/17.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCunstomtextField.h"

@implementation SSJCunstomtextField

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender

{
    
    if ([UIMenuController sharedMenuController]) {
        
        [UIMenuController sharedMenuController].menuVisible = NO;
        
    }
    
    return NO;
    
}

-(void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
    {
        gestureRecognizer.enabled = NO;
    }
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
    {
        if (((UITapGestureRecognizer*)gestureRecognizer).numberOfTapsRequired >=  2) {
            gestureRecognizer.enabled = NO;
        }
    }
    [super addGestureRecognizer:gestureRecognizer];
}

@end
