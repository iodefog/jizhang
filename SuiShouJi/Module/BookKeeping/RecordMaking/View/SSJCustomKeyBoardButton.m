//
//  SSJCustomKeyBoardButton.m
//  SuiShouJi
//
//  Created by 赵天立 on 15/12/16.
//  Copyright © 2015年 ___9188___. All rights reserved.
//

#import "SSJCustomKeyBoardButton.h"

@implementation SSJCustomKeyBoardButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:104.0/255 green:104.0/255 blue:104.0/255 alpha:1.0];
        [self ssj_setBorderStyle:SSJBorderStyleAll];
        [self ssj_setBorderColor:[UIColor blackColor]];
        [self ssj_setBorderWidth:1];
    }
    return self;
}

@end
